// src/services/transactionService.js
const supabase = require('../config/supabaseClient');
const { evaluateAnomaly } = require('./anomalyService');
const { randomUUID: uuidv4 } = require('crypto');

/**
 * Helper: Menghitung perubahan saldo dan hutang berdasarkan direction transaksi
 * Direction enum: 'income', 'expense', 'transfer', 'debt_increase', 'debt_payment'
 * 
 * isReversal: Digunakan untuk fitur UPDATE / DELETE (membatalkan efek transaksi lama)
 */
const calculateFinancialImpact = (currentBalance, currentDebt, amount, direction, isReversal = false) => {
    let numBalance = Number(currentBalance || 0);
    let numDebt = Number(currentDebt || 0);
    const amt = Number(amount || 0) * (isReversal ? -1 : 1);

    switch (direction) {
        case 'income':
            numBalance += amt;
            break;
        case 'expense':
        case 'transfer':
            numBalance -= amt;
            break;
        case 'debt_increase':
            numDebt += amt;
            numBalance += amt; // Asumsi: Menerima hutang (pinjaman cair) akan menambah saldo kas saat ini
            break;
        case 'debt_payment':
            numDebt -= amt;
            numBalance -= amt; // Asumsi: Membayar hutang akan mengambil uang dari saldo kas saat ini
            break;
    }

    return { newBalance: numBalance, newDebt: numDebt };
};

/**
 * Helper: Menambahkan kontribusi ke goal saat transaksi bertipe 'income' dibuat / diperbarui
 */
const handleGoalContributionCreate = async (userId, transactionId, goalId, amount, direction) => {
    if (!goalId || direction !== 'income') return;

    const { data: goal, error: goalError } = await supabase
        .from('financial_goals')
        .select('*')
        .eq('id', goalId)
        .single();

    if (goalError || !goal) return;

    const contributionPayload = {
        goal_id: goalId,
        contributor_user_id: userId,
        amount: Number(amount),
        source: 'transaction',
        transaction_id: transactionId,
        note: 'Kontribusi otomatis dari transaksi pemasukan'
    };

    await supabase.from('goal_contributions').insert([contributionPayload]);

    const newCurrentAmount = Number(goal.current_amount || 0) + Number(amount);
    const isCompleted = newCurrentAmount >= Number(goal.target_amount);

    const goalUpdatePayload = {
        current_amount: newCurrentAmount,
        updated_at: new Date().toISOString()
    };

    if (isCompleted && goal.status !== 'completed') {
        goalUpdatePayload.status = 'completed';
    }

    await supabase
        .from('financial_goals')
        .update(goalUpdatePayload)
        .eq('id', goalId);
};

/**
 * Helper: Menghapus / Rollback kontribusi ke goal saat transaksi dihapus atau diperbarui
 */
const handleGoalContributionRemove = async (transactionId) => {
    const { data: contrib } = await supabase
        .from('goal_contributions')
        .select('*')
        .eq('transaction_id', transactionId)
        .single();

    if (!contrib) return;

    await supabase
        .from('goal_contributions')
        .delete()
        .eq('id', contrib.id);

    const { data: goal } = await supabase
        .from('financial_goals')
        .select('*')
        .eq('id', contrib.goal_id)
        .single();

    if (goal) {
        const newCurrentAmount = Math.max(0, Number(goal.current_amount || 0) - Number(contrib.amount));
        const goalUpdatePayload = {
            current_amount: newCurrentAmount,
            updated_at: new Date().toISOString()
        };

        if (goal.status === 'completed' && newCurrentAmount < Number(goal.target_amount)) {
            goalUpdatePayload.status = 'active';
        }

        await supabase
            .from('financial_goals')
            .update(goalUpdatePayload)
            .eq('id', goal.id);
    }
};

/**
 * 1. GET /transactions
 */
const getTransactions = async (familyId, queryParams) => {
    const { cursor, limit = 20, direction, category, attention_level } = queryParams;

    const parsedLimit = Math.min(Math.max(parseInt(limit, 10) || 20, 1), 100);
    const fetchLimit = parsedLimit + 1;

    let query = supabase.from('transactions').select('*').eq('family_id', familyId);

    if (direction) query = query.eq('direction', direction);
    if (category) query = query.eq('category', category);
    if (attention_level) query = query.eq('anomaly->>attention_level', attention_level);

    if (cursor) {
        query = query.lt('transaction_at', cursor);
    }

    query = query.order('transaction_at', { ascending: false }).limit(fetchLimit);

    const { data: rawData, error } = await query;

    if (error) {
        throw new Error(`Database Query Error: ${error.message}`);
    }

    let hasMore = false;
    let nextCursor = null;
    let data = rawData || [];

    if (data.length > parsedLimit) {
        hasMore = true;
        data = data.slice(0, parsedLimit);
        nextCursor = data[data.length - 1].transaction_at;
    }

    return {
        data,
        pagination: { next_cursor: nextCursor, has_more: hasMore }
    };
};

/**
 * 2. POST /transactions
 */
const createManualTransaction = async (userId, familyId, payload) => {
    const transactionId = uuidv4();
    const txDate = new Date(payload.transaction_at);
    const effectiveGoalId = payload.direction === 'income' ? (payload.goal_id || null) : null;

    // 1. Ambil saldo dan hutang user saat ini
    const { data: userData, error: userError } = await supabase
        .from('users')
        .select('balance, debt')
        .eq('id', userId)
        .single();

    if (userError || !userData) {
        throw new Error(`Gagal mengambil data user: ${userError?.message || 'User tidak ditemukan'}`);
    }

    const balanceBefore = Number(userData.balance || 0);
    const debtBefore = Number(userData.debt || 0);

    // 2. Hitung dampak finansial (Saldo dan Hutang)
    const { newBalance, newDebt } = calculateFinancialImpact(
        balanceBefore, 
        debtBefore, 
        payload.amount, 
        payload.direction
    );

    const tenDaysAgo = new Date(txDate);
    tenDaysAgo.setDate(tenDaysAgo.getDate() - 10);

    const { data: historyData } = await supabase
        .from('transactions')
        .select('*')
        .eq('owner_user_id', userId)
        .gte('transaction_at', tenDaysAgo.toISOString())
        .lte('transaction_at', txDate.toISOString())
        .order('transaction_at', { ascending: false })
        .limit(20);

    const currentTxDraft = {
        id: transactionId,
        ...payload,
        goal_id: effectiveGoalId,
        balance_before: balanceBefore,
        balance_after: newBalance
    };

    const anomalySummary = await evaluateAnomaly(userId, currentTxDraft, historyData || []);

    let confirmationStatus = payload.confirmation_status || 'confirmed';
    if (anomalySummary?.attention_level === 'needs_confirmation') {
        confirmationStatus = 'needs_clarification';
    }

    const newTransaction = {
        id: transactionId,
        family_id: familyId,
        owner_user_id: userId,
        source: payload.source || 'manual',
        source_provider: null,
        external_transaction_id: null,
        statement_import_id: null,
        transaction_at: payload.transaction_at,
        direction: payload.direction,
        amount: payload.amount,
        currency: payload.currency || 'IDR',
        description: payload.description,
        counterparty_name: payload.counterparty_name || null,
        counterparty_account_masked: null,
        category: payload.category,
        payment_channel: payload.payment_channel || null,
        balance_before: balanceBefore,
        balance_after: newBalance,
        visibility: payload.visibility,
        confirmation_status: confirmationStatus,
        large_transaction_approval_status: payload.large_transaction_approval_status || 'not_required',
        goal_id: effectiveGoalId,
        anomaly: anomalySummary,
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
    };

    const { data, error } = await supabase.from('transactions').insert([newTransaction]).select().single();
    if (error) throw new Error(`Database Insert Error: ${error.message}`);

    if (effectiveGoalId) {
        await handleGoalContributionCreate(userId, transactionId, effectiveGoalId, payload.amount, payload.direction);
    }

    // 3. Update saldo dan hutang terbaru pada tabel users
    await supabase
        .from('users')
        .update({ 
            balance: newBalance, 
            debt: newDebt,
            updated_at: new Date().toISOString() 
        })
        .eq('id', userId);

    return data;
};

/**
 * 3. GET /transactions/{transaction_id}
 */
const getTransactionById = async (transactionId, familyId) => {
    const { data, error } = await supabase
        .from('transactions')
        .select('*')
        .eq('id', transactionId)
        .eq('family_id', familyId)
        .single();

    if (error || !data) return null;
    return data;
};

/**
 * 4. PATCH /transactions/{transaction_id}
 */
const updateTransaction = async (transactionId, familyId, payload) => {
    const { data: existingTx, error: fetchError } = await supabase
        .from('transactions')
        .select('*')
        .eq('id', transactionId)
        .eq('family_id', familyId)
        .single();

    if (fetchError || !existingTx) return null;

    const { data: userData } = await supabase
        .from('users')
        .select('balance, debt')
        .eq('id', existingTx.owner_user_id)
        .single();

    // 1. Rollback dampak transaksi lama
    const { newBalance: balWithoutOld, newDebt: debtWithoutOld } = calculateFinancialImpact(
        userData?.balance, 
        userData?.debt, 
        existingTx.amount, 
        existingTx.direction, 
        true // isReversal = true
    );

    // 2. Aplikasikan dampak transaksi baru
    const newDirection = payload.direction || existingTx.direction;
    const newAmount = payload.amount !== undefined ? payload.amount : existingTx.amount;
    const rawGoalId = payload.goal_id !== undefined ? payload.goal_id : existingTx.goal_id;
    const newGoalId = newDirection === 'income' ? rawGoalId : null;

    const { newBalance: finalBalance, newDebt: finalDebt } = calculateFinancialImpact(
        balWithoutOld, 
        debtWithoutOld, 
        newAmount, 
        newDirection
    );

    const updatedTxDraft = {
        ...existingTx,
        ...payload,
        goal_id: newGoalId,
        balance_before: balWithoutOld,
        balance_after: finalBalance
    };

    const txDate = new Date(updatedTxDraft.transaction_at);
    const tenDaysAgo = new Date(txDate);
    tenDaysAgo.setDate(tenDaysAgo.getDate() - 10);

    const { data: historyData } = await supabase
        .from('transactions')
        .select('*')
        .eq('owner_user_id', existingTx.owner_user_id)
        .neq('id', transactionId)
        .gte('transaction_at', tenDaysAgo.toISOString())
        .lte('transaction_at', txDate.toISOString())
        .order('transaction_at', { ascending: false })
        .limit(20);

    const newAnomalySummary = await evaluateAnomaly(existingTx.owner_user_id, updatedTxDraft, historyData || []);

    let updatedConfirmationStatus = payload.confirmation_status || existingTx.confirmation_status;
    if (newAnomalySummary?.attention_level === 'needs_confirmation') {
        updatedConfirmationStatus = 'needs_clarification';
    }

    const updateData = {
        ...payload,
        confirmation_status: updatedConfirmationStatus,
        goal_id: newGoalId,
        balance_before: balWithoutOld,
        balance_after: finalBalance,
        anomaly: newAnomalySummary,
        updated_at: new Date().toISOString()
    };

    const { data, error } = await supabase
        .from('transactions')
        .update(updateData)
        .eq('id', transactionId)
        .eq('family_id', familyId)
        .select()
        .single();

    if (error || !data) return null;

    await handleGoalContributionRemove(transactionId);
    if (newGoalId && newDirection === 'income') {
        await handleGoalContributionCreate(existingTx.owner_user_id, transactionId, newGoalId, newAmount, newDirection);
    }

    // 3. Update Balance dan Debt di tabel User
    await supabase
        .from('users')
        .update({ 
            balance: finalBalance, 
            debt: finalDebt,
            updated_at: new Date().toISOString() 
        })
        .eq('id', existingTx.owner_user_id);

    return data;
};

/**
 * 5. DELETE /transactions/{transaction_id}
 */
const deleteTransaction = async (transactionId, familyId) => {
    const { data: existingTx } = await supabase
        .from('transactions')
        .select('*')
        .eq('id', transactionId)
        .eq('family_id', familyId)
        .single();

    if (!existingTx) return false;

    await handleGoalContributionRemove(transactionId);

    const { error } = await supabase
        .from('transactions')
        .delete()
        .eq('id', transactionId)
        .eq('family_id', familyId);

    if (error) return false;

    // Rollback saldo dan hutang user
    const { data: userData } = await supabase
        .from('users')
        .select('balance, debt')
        .eq('id', existingTx.owner_user_id)
        .single();

    if (userData) {
        const { newBalance: restoredBalance, newDebt: restoredDebt } = calculateFinancialImpact(
            userData.balance, 
            userData.debt, 
            existingTx.amount, 
            existingTx.direction, 
            true // isReversal = true
        );

        await supabase
            .from('users')
            .update({ 
                balance: restoredBalance, 
                debt: restoredDebt,
                updated_at: new Date().toISOString() 
            })
            .eq('id', existingTx.owner_user_id);
    }

    return true;
};

/**
 * 6. POST /transactions/{transaction_id}/confirmation
 */
const confirmTransaction = async (transactionId, familyId, confirmationPayload) => {
    const { status, comment } = confirmationPayload;

    const existingTx = await getTransactionById(transactionId, familyId);
    if (!existingTx) return null;

    const updatedAnomaly = {
        ...existingTx.anomaly,
        user_comment: comment || null,
        confirmed_at: new Date().toISOString()
    };

    const { data, error } = await supabase
        .from('transactions')
        .update({
            confirmation_status: status,
            anomaly: updatedAnomaly,
            updated_at: new Date().toISOString()
        })
        .eq('id', transactionId)
        .eq('family_id', familyId)
        .select()
        .single();

    if (error) return null;
    return data;
};

/**
 * 7. POST /transactions/{transaction_id}/feedback
 */
const submitFeedback = async (transactionId, familyId, feedbackPayload) => {
    const { label, comment } = feedbackPayload;

    const existingTx = await getTransactionById(transactionId, familyId);
    if (!existingTx) return null;

    const updatedAnomaly = {
        ...existingTx.anomaly,
        feedback: {
            label: label,
            comment: comment || null,
            submitted_at: new Date().toISOString()
        }
    };

    const { data, error } = await supabase
        .from('transactions')
        .update({
            anomaly: updatedAnomaly,
            updated_at: new Date().toISOString()
        })
        .eq('id', transactionId)
        .eq('family_id', familyId)
        .select()
        .single();

    if (error) return null;
    return data;
};

module.exports = {
    getTransactions,
    createManualTransaction,
    getTransactionById,
    updateTransaction,
    deleteTransaction,
    confirmTransaction,
    submitFeedback
};