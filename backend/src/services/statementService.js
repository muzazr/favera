const { randomUUID: uuidv4 } = require('crypto');
const supabase = require('../config/supabaseClient');
const { parseStatementBuffer } = require('../utils/statementParsers');
const { evaluateBatchAnomaly, getFallbackAnomaly } = require('./anomalyService');

/**
 * Helper menghitung saldo berjalan
 */
const calculateBalanceAfter = (currentBalance, amount, direction) => {
    const numericAmount = Number(amount || 0);
    if (direction === 'income') return currentBalance + numericAmount;
    if (direction === 'expense') return currentBalance - numericAmount;
    return currentBalance;
};

/**
 * 1. Upload dan Parse File E-Statement (PDF)
 */
const parseAndSaveDrafts = async (userId, familyId, fileBuffer, fileName, password) => {
    const { provider, parsedDrafts } = await parseStatementBuffer(fileBuffer, password);

    if (!parsedDrafts || parsedDrafts.length === 0) {
        throw new Error('Tidak ada data transaksi yang dapat diparsing dari e-statement ini.');
    }

    const { data: importRecord, error: importErr } = await supabase
        .from('statement_imports')
        .insert([{
            user_id: userId,
            family_id: familyId,
            provider,
            filename: fileName,
            file_type: 'pdf',
            total_transactions: parsedDrafts.length,
            status: 'draft'
        }])
        .select()
        .single();

    if (importErr) throw new Error(`Gagal membuat sesi impor: ${importErr.message}`);

    const hashes = parsedDrafts.map(d => d.raw_reference_hash);
    
    const { data: existingTxs } = await supabase
        .from('transactions')
        .select('raw_reference_hash')
        .in('raw_reference_hash', hashes);

    const existingHashSet = new Set((existingTxs || []).map(tx => tx.raw_reference_hash));

    const draftPayloads = parsedDrafts.map(draft => {
        const isDuplicate = existingHashSet.has(draft.raw_reference_hash);
        return {
            statement_import_id: importRecord.id,
            family_id: familyId,
            owner_user_id: userId,
            transaction_at: draft.transaction_at,
            direction: draft.direction,
            amount: draft.amount,
            currency: 'IDR',
            description: draft.description,
            category: draft.category,
            payment_channel: draft.payment_channel,
            raw_reference_hash: draft.raw_reference_hash,
            is_selected: !isDuplicate,
            validation_status: isDuplicate ? 'duplicate' : 'valid',
            validation_errors: isDuplicate ? [{ field: 'general', message: 'Transaksi diduga sudah pernah terimport sebelumnya' }] : []
        };
    });

    const { data: savedDrafts, error: draftsErr } = await supabase
        .from('parsed_transaction_drafts')
        .insert(draftPayloads)
        .select();

    if (draftsErr) throw new Error(`Gagal menyimpan draft transaksi: ${draftsErr.message}`);

    return {
        import_session: importRecord,
        drafts: savedDrafts
    };
};

/**
 * 2. Get Drafts by Import ID
 */
const getDraftsByImportId = async (importId, familyId) => {
    const { data, error } = await supabase
        .from('parsed_transaction_drafts')
        .select('*')
        .eq('statement_import_id', importId)
        .eq('family_id', familyId)
        .order('transaction_at', { ascending: false });

    if (error) throw new Error(`Gagal mengambil draft: ${error.message}`);
    return data;
};

/**
 * 3. Update Draft Spesifik
 */
const updateDraftTransaction = async (draftId, familyId, updatePayload) => {
    const { data, error } = await supabase
        .from('parsed_transaction_drafts')
        .update({ ...updatePayload, updated_at: new Date().toISOString() })
        .eq('id', draftId)
        .eq('family_id', familyId)
        .select()
        .single();

    if (error) throw new Error(`Gagal mengupdate draft: ${error.message}`);
    return data;
};

/**
 * 4. Discard / Hapus Draft Transaksi
 */
const deleteDraftTransaction = async (draftId, familyId) => {
    const { error } = await supabase
        .from('parsed_transaction_drafts')
        .delete()
        .eq('id', draftId)
        .eq('family_id', familyId);

    if (error) throw new Error(`Gagal menghapus draft: ${error.message}`);
    return true;
};

/**
 * 5. Confirm Import (Memindahkan Selected Drafts ke Tabel Transactions Utama secara Bulk)
 */
/**
 * 5. Confirm Import (Memindahkan Selected Drafts ke Tabel Transactions Utama)
 */
const confirmStatementImport = async (importId, userId, familyId) => {
    // 1. Ambil semua draft yang dipilih
    const { data: selectedDrafts, error: draftsErr } = await supabase
        .from('parsed_transaction_drafts')
        .select('*')
        .eq('statement_import_id', importId)
        .eq('family_id', familyId)
        .eq('is_selected', true)
        .order('transaction_at', { ascending: true });

    if (draftsErr) {
        throw new Error(`Gagal mengambil draft transaksi: ${draftsErr.message}`);
    }

    // 🔍 DIAGNOSTIC CHECKER: Jika data kosong, cari tahu persis penyebabnya!
    if (!selectedDrafts || selectedDrafts.length === 0) {
        const { data: checkAll } = await supabase
            .from('parsed_transaction_drafts')
            .select('id, family_id, is_selected')
            .eq('statement_import_id', importId);

        if (!checkAll || checkAll.length === 0) {
            throw new Error(`[Debug] Draft tidak ditemukan untuk importId: '${importId}'. Pastikan ID benar, RLS tidak memblokir, atau draft belum dikonfirmasi/dihapus.`);
        }

        const sampleDraft = checkAll[0];
        if (sampleDraft.family_id !== familyId) {
            throw new Error(`[Debug Mismatch] family_id tidak cocok! Draft di DB pakai: '${sampleDraft.family_id}', tapi request kirim: '${familyId}'.`);
        }

        const trueSelectedCount = checkAll.filter(d => d.is_selected === true || d.is_selected === 'true').length;
        throw new Error(`[Debug Selection] Ditemukan ${checkAll.length} draft, tetapi yang bernilai is_selected=true hanya ${trueSelectedCount}.`);
    }

    // 2. Ambil saldo awal user
    const { data: userData, error: userError } = await supabase
        .from('users')
        .select('balance')
        .eq('id', userId)
        .single();

    if (userError || !userData) {
        throw new Error(`Gagal mengambil data user: ${userError?.message || 'User tidak ditemukan'}`);
    }

    // 3. Susun objek transaksi dan hitung running balance
    let currentBalance = Number(userData.balance || 0);
    const newTransactions = [];

    for (const draft of selectedDrafts) {
        const transactionId = uuidv4();
        const balanceBefore = currentBalance;
        currentBalance = calculateBalanceAfter(balanceBefore, draft.amount, draft.direction);
        const balanceAfter = currentBalance;

        newTransactions.push({
            id: transactionId,
            family_id: familyId,
            owner_user_id: userId,
            source: 'e_statement',
            source_provider: draft.payment_channel || null,
            external_transaction_id: null,
            statement_import_id: importId,
            raw_reference_hash: draft.raw_reference_hash || null,
            transaction_at: draft.transaction_at,
            direction: draft.direction,
            amount: Math.round(Number(draft.amount)),
            currency: draft.currency || 'IDR',
            description: draft.description,
            counterparty_name: draft.counterparty_name || null,
            counterparty_account_masked: null,
            category: draft.category || 'Lainnya',
            payment_channel: draft.payment_channel || null,
            balance_before: Math.round(Number(balanceBefore)),
            balance_after: Math.round(Number(balanceAfter)),
            visibility: 'shared',
            confirmation_status: 'confirmed',
            large_transaction_approval_status: 'not_required',
            goal_id: null,
            anomaly: getFallbackAnomaly(),
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
        });
    }

    // 4. Ambil riwayat transaksi 10 hari terakhir untuk ML
    const earliestTxDate = new Date(selectedDrafts[0].transaction_at);
    const tenDaysAgo = new Date(earliestTxDate);
    tenDaysAgo.setDate(tenDaysAgo.getDate() - 10);

    const { data: historyData } = await supabase
        .from('transactions')
        .select('*')
        .eq('owner_user_id', userId)
        .gte('transaction_at', tenDaysAgo.toISOString())
        .lte('transaction_at', earliestTxDate.toISOString())
        .order('transaction_at', { ascending: false })
        .limit(30);

    // ⚡ 5. EVALUASI BATCH ML (Synchronous sebelum Insert)
    const assessments = await evaluateBatchAnomaly(userId, familyId, newTransactions, historyData || []);

    if (assessments && assessments.length > 0) {
        const assessmentMap = new Map(assessments.map(item => [item.transaction_id, item]));

        for (const tx of newTransactions) {
            const item = assessmentMap.get(tx.id);
            if (item) {
                const attentionLevel = item.risk_band || item.attention_level || 'normal';

                tx.anomaly = {
                    attention_level: attentionLevel,
                    anomaly_score: item.anomaly_score,
                    reason_codes: item.reason_codes || [],
                    reason_details: item.reason_details || [],
                    recommended_action: item.recommended_action || null,
                    model_version: item.model_version || 'v1.0.0',
                    assessed_at: new Date().toISOString()
                };

                if (attentionLevel === 'needs_confirmation') {
                    tx.confirmation_status = 'needs_clarification';
                }
            }
        }
    }

    // 6. BULK INSERT transaksi sekaligus
    const { data: insertedTransactions, error: insertError } = await supabase
        .from('transactions')
        .insert(newTransactions)
        .select();

    if (insertError) {
        throw new Error(`Gagal melakukan bulk insert transaksi: ${insertError.message}`);
    }

    // 7. Update saldo user, status import, dan hapus draft
    await Promise.all([
        supabase.from('users').update({ balance: Math.round(currentBalance), updated_at: new Date().toISOString() }).eq('id', userId),
        supabase.from('statement_imports').update({ status: 'confirmed', updated_at: new Date().toISOString() }).eq('id', importId),
        supabase.from('parsed_transaction_drafts').delete().eq('statement_import_id', importId)
    ]);

    return {
        confirmed_count: insertedTransactions.length,
        transactions: insertedTransactions
    };
};

/**
 * Worker Asinkron untuk memproses Batch ML di Background
 */
const processBatchInBackground = async (userId, familyId, insertedTransactions, historyData) => {
    try {
        const assessments = await evaluateBatchAnomaly(userId, familyId, insertedTransactions, historyData);

        if (!assessments || assessments.length === 0) return;

        // Update hasil evaluasi ML ke database per transaksi
        const updatePromises = assessments.map(item => {
            const anomalySummary = {
                attention_level: item.risk_band || 'normal',
                anomaly_score: item.anomaly_score,
                reason_codes: item.reason_codes || [],
                reason_details: item.reason_details || [],
                recommended_action: item.recommended_action || null,
                model_version: item.model_version || 'v1.0.0',
                assessed_at: new Date().toISOString()
            };

            return supabase
                .from('transactions')
                .update({ anomaly: anomalySummary, updated_at: new Date().toISOString() })
                .eq('id', item.transaction_id);
        });

        await Promise.all(updatePromises);
        console.log(`[Background ML Success] Berhasil memperbarui ${assessments.length} transaksi.`);
    } catch (err) {
        console.error('[Background ML Worker Exception]:', err.message);
    }
};

module.exports = {
    parseAndSaveDrafts,
    getDraftsByImportId,
    updateDraftTransaction,
    deleteDraftTransaction,
    confirmStatementImport
};