const { randomUUID: uuidv4 } = require('crypto');

// Environment variables
const EVALUATE_URL = process.env.ML_EVALUATE_URL;
const BATCH_EVALUATE_URL = process.env.ML_BATCH_EVALUATE_URL || 'https://faveraai.vercel.app/v1/model1/evaluate-batch';
const ML_TIMEOUT_MS = parseInt(process.env.ML_TIMEOUT_MS, 10) || 5000;

/**
 * Fallback standar jika ML Service tidak tersedia / timeout
 */
const getFallbackAnomaly = () => ({
    attention_level: 'normal',
    reason_codes: ['MODEL_SERVICE_UNAVAILABLE'],
    reason_details: [],
    explanation: null,
    recommended_action: null,
    model_version: null,
    assessed_at: new Date().toISOString()
});

/**
 * 1. Evaluasi Single Transaksi (Dipakai oleh Transaksi Manual)
 */
const evaluateAnomaly = async (userId, currentTx, historyData) => {
    const requestId = uuidv4();

    const mapTxForML = (tx) => ({
        transaction_id: tx.id || uuidv4(),
        timestamp: tx.transaction_at,
        amount: Number(tx.amount || 0),
        recipient_id: tx.counterparty_name || "",
        direction: tx.direction,
        transaction_type: tx.category,
        description: tx.description || "",
        balance_before: Number(tx.balance_before || 0),
        balance_after: Number(tx.balance_after || 0),
        additionalProp1: {}
    });

    const payload = {
        request_id: requestId,
        user_id: userId,
        transaction: mapTxForML(currentTx),
        history: (historyData || []).map(mapTxForML),
        global_features: {
            additionalProp1: 0,
            additionalProp2: 0,
            additionalProp3: 0
        },
        metadata: {
            additionalProp1: {}
        }
    };

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), ML_TIMEOUT_MS);

    try {
        const response = await fetch(EVALUATE_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
            signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
            console.error(`ML Model HTTP Error: ${response.status}`);
            return getFallbackAnomaly();
        }

        const mlRes = await response.json();

        const reasonCodes = Array.isArray(mlRes.reason_codes)
            ? mlRes.reason_codes.map(rc => typeof rc === 'string' ? rc : JSON.stringify(rc))
            : [];

        let recommendedAction = null;
        if (mlRes.requires_confirmation || (mlRes.attention_level && mlRes.attention_level !== 'normal')) {
            recommendedAction = {
                code: 'CONFIRM_TRANSACTION',
                label: 'Konfirmasi rincian transaksi',
                route: `/transactions/${currentTx.id}/confirmation`,
                priority: mlRes.attention_level === 'needs_confirmation' ? 'high' : 'medium'
            };
        }

        return {
            attention_level: mlRes.attention_level || 'normal',
            reason_codes: reasonCodes,
            explanation: mlRes.attention_level !== 'normal' 
                ? (mlRes.explanation || mlRes.message || 'Transaksi terdeteksi di luar kebiasaan pola harian.') 
                : null,
            recommended_action: recommendedAction,
            model_version: mlRes.versions?.model_version || 'v1.0.0',
            assessed_at: new Date().toISOString()
        };

    } catch (error) {
        clearTimeout(timeoutId);
        if (error.name === 'AbortError') {
            console.error(`Gagal menghubungi ML Evaluator: Request Timeout (${ML_TIMEOUT_MS}ms)`);
        } else {
            console.error('Gagal menghubungi Anomaly Evaluator Service:', error.message);
        }
        return getFallbackAnomaly();
    }
};

/**
 * 2. Evaluasi Batch Transaksi (Dipakai oleh Confirm E-Statement Import)
 */
const evaluateBatchAnomaly = async (userId, familyId, currentTxs, historyData) => {
    const requestId = uuidv4();

    const mapTxForBatchML = (tx) => ({
        transaction_id: tx.id || tx.transaction_id || uuidv4(),
        transaction_at: tx.transaction_at,
        direction: tx.direction,
        amount: Number(tx.amount || 0),
        currency: tx.currency || 'IDR',
        description: tx.description || '',
        counterparty_name: tx.counterparty_name || '',
        counterparty_id: '',
        category: tx.category || 'Lainnya',
        payment_channel: tx.payment_channel || '',
        balance_before: Number(tx.balance_before || 0),
        balance_after: Number(tx.balance_after || 0),
        external_transaction_id: tx.external_transaction_id || '',
        source_provider: tx.source_provider || '',
        additionalProp1: {}
    });

    const payload = {
        request_id: requestId,
        user_id: userId,
        family_id: familyId,
        current_transactions: currentTxs.map(mapTxForBatchML),
        historical_transactions: (historyData || []).map(mapTxForBatchML),
        household_context: {
            essential_budget_remaining: 0,
            unconfirmed_transaction_count: 0,
            large_transaction_threshold: 0,
            active_goal_progress: 0,
            additionalProp1: {}
        },
        additionalProp1: {}
    };

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), ML_TIMEOUT_MS * 2); // Timeout batch 10 detik

    try {
        const response = await fetch(BATCH_EVALUATE_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
            signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
            console.error(`ML Batch Model HTTP Error Status: ${response.status}`);
            return [];
        }

        const mlRes = await response.json();
        return mlRes.assessments || [];

    } catch (error) {
        clearTimeout(timeoutId);
        if (error.name === 'AbortError') {
            console.error(`Gagal menghubungi ML Batch Evaluator: Request Timeout (${ML_TIMEOUT_MS * 2}ms)`);
        } else {
            console.error('Gagal menghubungi Batch ML Evaluator Service:', error.message);
        }
        return [];
    }
};

module.exports = { 
    evaluateAnomaly, 
    evaluateBatchAnomaly, 
    getFallbackAnomaly 
};