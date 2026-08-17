// File: src/utils/anomalyPipeline.js

// 1. Import Supabase Client (Sesuaikan path ini dengan lokasi file config supabase Anda)
const supabase = require('../config/supabaseClient'); 

// 2. Import dateUtils (Gunakan './' karena sekarang berada di folder 'utils' yang sama)
const { getWIBISOString } = require('./dateUtils'); 

/**
 * Pipeline Generate Model 1 Summary
 * Menghasilkan ringkasan anomali transaksi 7 hari terakhir.
 * 
 * @param {string} familyId - ID dari keluarga yang ingin dianalisis
 * @returns {object} JSON object berisi metrik agregasi anomali
 */
async function generateModel1Summary(familyId) {
    // 1. Setup Timeframes dengan referensi WIB
    const nowWIB = new Date(getWIBISOString());
    const msPerDay = 24 * 60 * 60 * 1000;
    
    const date7DaysAgo = new Date(nowWIB.getTime() - (7 * msPerDay));
    const date90DaysAgo = new Date(nowWIB.getTime() - (90 * msPerDay));

    // 2. Ambil Current Balance dari tabel Users (untuk menghitung rasio penurunan)
    const { data: users, error: userError } = await supabase
        .from('users')
        .select('balance')
        .eq('family_id', familyId);

    if (userError) throw new Error(`Gagal mengambil data user: ${userError.message}`);
    
    let currentBalance = 0;
    (users || []).forEach(user => {
        currentBalance += Number(user.balance || 0);
    });

    // 3. Tarik seluruh transaksi 90 hari terakhir (Efisiensi memori)
    const { data: txHistory, error: txError } = await supabase
        .from('transactions')
        .select('id, transaction_at, amount, direction, counterparty_name, confirmation_status, anomaly')
        .eq('family_id', familyId)
        .gte('transaction_at', date90DaysAgo.toISOString())
        .order('transaction_at', { ascending: true });

    if (txError) throw new Error(`Gagal mengambil transaksi: ${txError.message}`);

    // Pisahkan transaksi menjadi historical (90-8 hari lalu) dan recent (7 hari terakhir)
    const txHistorical = [];
    const tx7d = [];

    (txHistory || []).forEach(tx => {
        const txDate = new Date(tx.transaction_at);
        if (txDate >= date7DaysAgo) {
            tx7d.push(tx);
        } else {
            txHistorical.push(tx);
        }
    });

    // --- AGREGASI METRIK ---
    let confirmed_unusual_count_7d = 0;
    let confirmed_unusual_value_7d = 0;
    let unconfirmed_anomaly_count_7d = 0;
    let anomaly_score_max_7d = 0;
    
    let validModelEvaluations = 0;
    
    // Variabel untuk rollback saldo
    let balance_7d_ago = currentBalance;

    // Helper Function untuk mengecek apakah tergolong anomali (berdasarkan JSONB)
    const isAnomaly = (anomalyObj) => {
        if (!anomalyObj) return false;
        const obj = typeof anomalyObj === 'string' ? JSON.parse(anomalyObj) : anomalyObj;
        
        const attention = obj.attention_level;
        const score = obj.anomaly_score || 0;
        
        // Dianggap anomali jika attention bukan normal atau score tinggi (> 0.7)
        return (attention && attention !== 'normal') || (score >= 0.7);
    };

    // A. Iterasi Transaksi 7 Hari Terakhir
    tx7d.forEach(tx => {
        const amount = Number(tx.amount);
        const anomalyData = typeof tx.anomaly === 'string' ? JSON.parse(tx.anomaly) : tx.anomaly;
        
        // 1. Rollback Saldo ke 7 hari lalu
        if (tx.direction === 'income' || tx.direction === 'debt_increase') {
            balance_7d_ago -= amount;
        } else if (tx.direction === 'expense' || tx.direction === 'debt_payment') {
            balance_7d_ago += amount;
        }

        // 2. Evaluasi Anomali
        if (anomalyData) {
            // Cek Data Coverage (apakah model berhasil mengevaluasi)
            const hasServiceError = anomalyData.reason_codes && anomalyData.reason_codes.includes("MODEL_SERVICE_UNAVAILABLE");
            if (!hasServiceError) validModelEvaluations++;

            // Update Max Score
            if (anomalyData.anomaly_score && anomalyData.anomaly_score > anomaly_score_max_7d) {
                anomaly_score_max_7d = anomalyData.anomaly_score;
            }

            // Hitung Unusuality
            if (isAnomaly(anomalyData)) {
                if (tx.confirmation_status === 'confirmed') {
                    confirmed_unusual_count_7d++;
                    confirmed_unusual_value_7d += amount;
                } else if (tx.confirmation_status === 'unconfirmed') {
                    unconfirmed_anomaly_count_7d++;
                }
            }
        }
    });

    // B. Deteksi Penerima Baru (New Recipient)
    // Kumpulkan semua nama counterparty masa lalu
    const historicalCounterparties = new Set(
        txHistorical
            .filter(tx => tx.counterparty_name)
            .map(tx => tx.counterparty_name.trim().toLowerCase())
    );

    const newRecipients = new Set();
    tx7d.forEach(tx => {
        // Hanya hitung uang keluar
        if (tx.counterparty_name && (tx.direction === 'expense' || tx.direction === 'debt_payment')) {
            const nameStr = tx.counterparty_name.trim().toLowerCase();
            if (!historicalCounterparties.has(nameStr)) {
                newRecipients.add(nameStr);
            }
        }
    });

    // C. Deteksi Rapid Repeat (Kurun 3 Hari)
    const rapidRepeatTxIds = new Set();
    for (let i = 0; i < tx7d.length; i++) {
        for (let j = i + 1; j < tx7d.length; j++) {
            const txA = tx7d[i];
            const txB = tx7d[j];

            if (txA.counterparty_name && (txA.counterparty_name === txB.counterparty_name) && txA.amount === txB.amount) {
                const timeDiff = Math.abs(new Date(txA.transaction_at) - new Date(txB.transaction_at));
                const daysDiff = timeDiff / msPerDay;

                if (daysDiff <= 3) {
                    rapidRepeatTxIds.add(txA.id);
                    rapidRepeatTxIds.add(txB.id);
                }
            }
        }
    }

    // D. Kalkulasi Ratio & Coverage
    let balance_drop_ratio_7d = 0;
    if (balance_7d_ago > 0 && currentBalance < balance_7d_ago) {
        // Hanya dihitung jika saldo hari ini LEBIH KECIL dari 7 hari lalu
        balance_drop_ratio_7d = (balance_7d_ago - currentBalance) / balance_7d_ago;
    }

    const totalTx7d = tx7d.length;
    const model1_data_coverage = totalTx7d > 0 
        ? (validModelEvaluations / totalTx7d) * 100 
        : 0;

    // 4. Menyusun JSON Output Akhir
    const model1_summary = {
        confirmed_unusual_count_7d,
        confirmed_unusual_value_7d,
        unconfirmed_anomaly_count_7d,
        anomaly_score_max_7d: Number(anomaly_score_max_7d.toFixed(4)),
        new_recipient_count_7d: newRecipients.size,
        rapid_repeat_count_7d: rapidRepeatTxIds.size,
        balance_drop_ratio_7d: Number(balance_drop_ratio_7d.toFixed(2)),
        model1_data_coverage: Number(model1_data_coverage.toFixed(2))
    };

    return model1_summary;
}

module.exports = { generateModel1Summary };