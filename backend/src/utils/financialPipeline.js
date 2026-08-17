// src/services/financialSnapshotService.js (Sesuaikan dengan path Anda)

const { getWIBISOString } = require('../utils/dateUtils'); // Sesuaikan path dateUtils Anda

/**
 * Pipeline Generate Financial Snapshot
 * Menghasilkan snapshot keuangan keluarga berdasarkan historis transaksi 90 hari.
 * Menggunakan referensi zona waktu WIB (Asia/Jakarta) dan Supabase Client.
 */
async function generateFinancialSnapshot(familyId, supabase) {
    // 1. Setup Timeframes dengan referensi WIB
    // Menggunakan getWIBISOString() memastikan 'now' terkunci pada zona waktu Jakarta
    const nowWIB = new Date(getWIBISOString()); 
    const msPerDay = 24 * 60 * 60 * 1000;
    
    const date90DaysAgo = new Date(nowWIB.getTime() - (90 * msPerDay));
    const date30DaysAgo = new Date(nowWIB.getTime() - (30 * msPerDay));
    const date28DaysAgo = new Date(nowWIB.getTime() - (28 * msPerDay));

    // 2. Ambil Current Balance dan Debt dari tabel Users untuk satu keluarga
    // Catatan: Supabase client standar tidak memiliki fungsi agregasi SUM(), 
    // jadi kita ambil row-nya lalu kita jumlahkan di memori.
    const { data: users, error: userError } = await supabase
        .from('users')
        .select('balance, debt')
        .eq('family_id', familyId);

    if (userError) throw new Error(`Gagal mengambil data user: ${userError.message}`);

    let currentBalance = 0;
    let currentDebt = 0;

    (users || []).forEach(user => {
        currentBalance += Number(user.balance || 0);
        currentDebt += Number(user.debt || 0);
    });

    // 3. Ambil Transaksi 90 Hari Terakhir
    const { data: txHistory, error: txError } = await supabase
        .from('transactions')
        .select('transaction_at, amount, direction, category, visibility')
        .eq('family_id', familyId)
        .gte('transaction_at', date90DaysAgo.toISOString()) // Batas awal ditarik berdasarkan ISO String WIB
        .order('transaction_at', { ascending: true });

    if (txError) throw new Error(`Gagal mengambil histori transaksi: ${txError.message}`);

    // Kategori Kebutuhan Dasar
    const essentialCategories = ['food', 'utilities', 'transportation', 'housing', 'health', 'education'];
    
    // Variabel Agregasi
    let totalIncome90d = 0;
    let totalDebtPayment90d = 0;
    
    let essentialExpense30d = 0;
    
    let income28d = 0;
    let expense28d = 0;
    let debtIncreases28d = 0;
    let debtPayments28d = 0;

    // Indikator (Flags)
    let newDebt = false;
    let assetSold = false;
    let concealedActivity = false;

    // 4. Proses Iterasi Transaksi
    (txHistory || []).forEach(tx => {
        const txDate = new Date(tx.transaction_at);
        const amount = Number(tx.amount);
        
        const isWithin30d = txDate >= date30DaysAgo;
        const isWithin28d = txDate >= date28DaysAgo;

        // -- Pengecekan Flags --
        if (tx.visibility !== 'shared') {
            concealedActivity = true;
        }

        if (tx.direction === 'income') {
            totalIncome90d += amount;
            if (isWithin28d) income28d += amount;
            
            // Indikasi jual aset: Pemasukan dari kategori investment atau other
            if (tx.category === 'investment' || tx.category === 'other') {
                assetSold = true;
            }
        } 
        else if (tx.direction === 'expense') {
            if (isWithin28d) expense28d += amount;
            
            // Hitung Pengeluaran Esensial (30 Hari Terakhir)
            if (isWithin30d && essentialCategories.includes(tx.category)) {
                essentialExpense30d += amount;
            }
        } 
        else if (tx.direction === 'debt_payment') {
            totalDebtPayment90d += amount;
            if (isWithin28d) debtPayments28d += amount;
        } 
        else if (tx.direction === 'debt_increase') {
            if (isWithin28d) {
                debtIncreases28d += amount;
                newDebt = true; // Terdeteksi ada utang baru dalam 28 hari terakhir
            }
        }
    });

    // 5. Kalkulasi Metrik Akhir
    
    // A. Income Baseline: Rata-rata per minggu dari 90 hari (90 hari = 12.85 minggu)
    const weekly_income_baseline = totalIncome90d / (90 / 7);
    
    // B. Essential Budget: Rata-rata per minggu dari pengeluaran esensial 30 hari terakhir
    const essential_budget_7d = essentialExpense30d / (30 / 7);
    
    // C. Proyeksi Jatuh Tempo Utang 30 hari ke depan: Rata-rata cicilan per bulan dari 90 hari
    const debt_payment_due_30d = totalDebtPayment90d / (90 / 30);
    
    // D. Rollback Saldo & Utang ke 28 Hari Lalu
    const debt_balance_28d_ago = currentDebt - debtIncreases28d + debtPayments28d;
    const savings_28d_ago = currentBalance - income28d + expense28d;

    // E. Evaluasi Kebutuhan Dasar
    // Kebutuhan gagal terpenuhi jika saldo saat ini lebih kecil dari budget esensial seminggu
    const basic_needs_unmet = currentBalance < essential_budget_7d;

    // 6. Menyusun JSON Output Akhir
    const financial_snapshot = {
        weekly_income_baseline: Math.round(weekly_income_baseline),
        essential_budget_7d: Math.round(essential_budget_7d),
        essential_funds_available_7d: currentBalance, 
        
        debt_balance_current: currentDebt,
        debt_balance_28d_ago: Math.max(0, debt_balance_28d_ago),
        debt_payment_due_30d: Math.round(debt_payment_due_30d),
        
        savings_current: currentBalance,
        savings_28d_ago: Math.max(0, savings_28d_ago),
        
        cash_expected: currentBalance,
        cash_reported: currentBalance,
        
        basic_needs_unmet: basic_needs_unmet,
        new_external_debt: newDebt,
        asset_sold_or_pawned: assetSold,
        financial_activity_concealed: concealedActivity
    };

    return financial_snapshot;
}

module.exports = { generateFinancialSnapshot };