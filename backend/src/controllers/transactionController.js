// src/controllers/transactionController.js
const transactionService = require('../services/transactionService');
const supabase = require('../config/supabaseClient');
const { sendError } = require('../utils/response');

// Helper untuk memastikan family_id ada
const resolveUserAndFamily = async (req) => {
    const userId = req.user?.id;
    let familyId = req.user?.family_id;

    if (!userId) return { userId: null, familyId: null };

    if (!familyId) {
        const { data: userProfile } = await supabase
            .from('users')
            .select('family_id')
            .eq('id', userId)
            .single();
        familyId = userProfile?.family_id;
    }

    return { userId, familyId };
};

/**
 * GET /transactions
 */
const getTransactions = async (req, res) => {
    try {
        const { familyId } = await resolveUserAndFamily(req);
        if (!familyId) {
            return sendError(res, 401, 'UNAUTHORIZED', 'Pengguna tidak terautentikasi atau belum terhubung ke keluarga.');
        }

        const result = await transactionService.getTransactions(familyId, req.query);
        return res.status(200).json(result);
    } catch (error) {
        console.error('Error pada getTransactions:', error);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengambil daftar transaksi.');
    }
};

/**
 * POST /transactions
 */
const createTransaction = async (req, res) => {
    try {
        const { userId, familyId } = await resolveUserAndFamily(req);
        if (!userId || !familyId) {
            return sendError(res, 401, 'UNAUTHORIZED', 'Pengguna tidak terautentikasi atau belum terhubung ke keluarga.');
        }

        const { transaction_at, direction, amount, description, category, visibility } = req.body;
        if (!transaction_at || !direction || !amount || !description || !category || !visibility) {
            return sendError(res, 422, 'VALIDATION_ERROR', 'Field wajib harus diisi.');
        }

        const newTx = await transactionService.createManualTransaction(userId, familyId, req.body);
        return res.status(201).json(newTx);
    } catch (error) {
        console.error('Error pada createTransaction:', error);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mencatat transaksi.');
    }
};

/**
 * GET /transactions/{transaction_id}
 */
const getTransactionById = async (req, res) => {
    try {
        const { familyId } = await resolveUserAndFamily(req);
        const { transaction_id } = req.params;

        const transaction = await transactionService.getTransactionById(transaction_id, familyId);
        if (!transaction) {
            return sendError(res, 404, 'NOT_FOUND', 'Transaksi tidak ditemukan.');
        }

        return res.status(200).json(transaction);
    } catch (error) {
        console.error('Error pada getTransactionById:', error);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengambil detail transaksi.');
    }
};

/**
 * PATCH /transactions/{transaction_id}
 */
const updateTransaction = async (req, res) => {
    try {
        const { familyId } = await resolveUserAndFamily(req);
        const { transaction_id } = req.params;

        const updatedTx = await transactionService.updateTransaction(transaction_id, familyId, req.body);
        if (!updatedTx) {
            return sendError(res, 404, 'NOT_FOUND', 'Transaksi tidak ditemukan atau gagal diperbarui.');
        }

        return res.status(200).json(updatedTx);
    } catch (error) {
        console.error('Error pada updateTransaction:', error);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal memperbarui transaksi.');
    }
};

/**
 * DELETE /transactions/{transaction_id}
 */
const deleteTransaction = async (req, res) => {
    try {
        const { familyId } = await resolveUserAndFamily(req);
        const { transaction_id } = req.params;

        const success = await transactionService.deleteTransaction(transaction_id, familyId);
        if (!success) {
            return sendError(res, 404, 'NOT_FOUND', 'Transaksi tidak ditemukan.');
        }

        return res.status(204).send(); // 204 No Content sesuai spec
    } catch (error) {
        console.error('Error pada deleteTransaction:', error);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengarsip/menghapus transaksi.');
    }
};

/**
 * POST /transactions/{transaction_id}/confirmation
 */
const confirmTransaction = async (req, res) => {
    try {
        const { familyId } = await resolveUserAndFamily(req);
        const { transaction_id } = req.params;
        const { status, comment } = req.body;

        if (!status) {
            return sendError(res, 422, 'VALIDATION_ERROR', 'Field "status" wajib diisi.');
        }

        const validStatuses = ['confirmed', 'needs_clarification', 'rejected'];
        if (!validStatuses.includes(status)) {
            return sendError(res, 422, 'VALIDATION_ERROR', `Status harus salah satu dari: ${validStatuses.join(', ')}`);
        }

        const result = await transactionService.confirmTransaction(transaction_id, familyId, { status, comment });
        if (!result) {
            return sendError(res, 404, 'NOT_FOUND', 'Transaksi tidak ditemukan.');
        }

        return res.status(200).json(result);
    } catch (error) {
        console.error('Error pada confirmTransaction:', error);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengonfirmasi transaksi.');
    }
};

/**
 * POST /transactions/{transaction_id}/feedback
 */
const submitFeedback = async (req, res) => {
    try {
        const { familyId } = await resolveUserAndFamily(req);
        const { transaction_id } = req.params;
        const { label, comment } = req.body;

        if (!label) {
            return sendError(res, 422, 'VALIDATION_ERROR', 'Field "label" wajib diisi.');
        }

        const validLabels = [
            'normal', 
            'unusual_but_known', 
            'unrecognized', 
            'hidden_or_sensitive', 
            'gambling_related_optional', 
            'parsing_error'
        ];
        if (!validLabels.includes(label)) {
            return sendError(res, 422, 'VALIDATION_ERROR', `Label tidak valid. Harus salah satu dari enum yang ditentukan.`);
        }

        const result = await transactionService.submitFeedback(transaction_id, familyId, { label, comment });
        if (!result) {
            return sendError(res, 404, 'NOT_FOUND', 'Transaksi tidak ditemukan.');
        }

        return res.status(200).json(result);
    } catch (error) {
        console.error('Error pada submitFeedback:', error);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengirim umpan balik.');
    }
};

module.exports = {
    getTransactions,
    createTransaction,
    getTransactionById,
    updateTransaction,
    deleteTransaction,
    confirmTransaction,
    submitFeedback
};