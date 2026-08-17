const statementService = require('../services/statementService');

/**
 * POST /statement-imports
 */
const parseStatement = async (req, res) => {
    try {
        const userId = req.user.id;
        const familyId = req.user.family_id;
        const file = req.file;
        const { password } = req.body;

        if (!file) {
            return res.status(400).json({ success: false, message: 'File e-statement (PDF) wajib diunggah' });
        }

        const result = await statementService.parseAndSaveDrafts(
            userId,
            familyId,
            file.buffer,
            file.originalname,
            password
        );

        return res.status(201).json({
            success: true,
            message: 'E-Statement berhasil diparsing',
            data: result
        });
    } catch (error) {
        if (error.message === 'PDF_PASSWORD_REQUIRED') {
            return res.status(400).json({
                success: false,
                code: 'PDF_PASSWORD_REQUIRED',
                message: 'File PDF terproteksi password. Silakan masukkan password e-statement Anda.'
            });
        }

        if (error.message === 'PDF_PASSWORD_INCORRECT') {
            return res.status(400).json({
                success: false,
                code: 'PDF_PASSWORD_INCORRECT',
                message: 'Password PDF yang Anda masukkan salah. Silakan periksa kembali.'
            });
        }

        return res.status(error.statusCode || 500).json({ 
            success: false, 
            message: error.message || 'Terjadi kesalahan saat memproses e-statement' 
        });
    }
};

/**
 * GET /statement-imports
 */
const getStatementImports = async (req, res) => {
    try {
        const familyId = req.user.family_id;
        // Implementasikan pembacaan riwayat impor jika diperlukan
        return res.status(200).json({ success: true, data: [] });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

/**
 * GET /statement-imports/:statement_import_id
 */
const getStatementImportById = async (req, res) => {
    try {
        const { statement_import_id } = req.params;
        return res.status(200).json({ success: true, message: `Detail impor ${statement_import_id}` });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

/**
 * DELETE /statement-imports/:statement_import_id
 */
const cancelStatementImport = async (req, res) => {
    try {
        const { statement_import_id } = req.params;
        return res.status(200).json({ success: true, message: `Sesi impor ${statement_import_id} berhasil dibatalkan` });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

/**
 * POST /statement-imports/:statement_import_id/unlock
 */
const unlockStatement = async (req, res) => {
    try {
        const { statement_import_id } = req.params;
        const { password } = req.body;
        return res.status(200).json({ success: true, message: `Membuka kunci PDF ${statement_import_id}` });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

/**
 * GET /statement-imports/:statement_import_id/draft-transactions
 */
const getDraftTransactions = async (req, res) => {
    try {
        const { statement_import_id } = req.params;
        const familyId = req.user.family_id;

        const drafts = await statementService.getDraftsByImportId(statement_import_id, familyId);

        return res.status(200).json({
            success: true,
            data: drafts
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

/**
 * PATCH /statement-imports/:statement_import_id/draft-transactions/:draft_transaction_id
 */
const updateDraftTransaction = async (req, res) => {
    try {
        const { draft_transaction_id } = req.params;
        const familyId = req.user.family_id;

        const updatedDraft = await statementService.updateDraftTransaction(draft_transaction_id, familyId, req.body);

        return res.status(200).json({
            success: true,
            message: 'Draft transaksi berhasil diperbarui',
            data: updatedDraft
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

/**
 * DELETE /statement-imports/:statement_import_id/draft-transactions/:draft_transaction_id
 */
const deleteDraftTransaction = async (req, res) => {
    try {
        const { draft_transaction_id } = req.params;
        const familyId = req.user.family_id;

        await statementService.deleteDraftTransaction(draft_transaction_id, familyId);

        return res.status(200).json({
            success: true,
            message: 'Draft transaksi berhasil dihapus'
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

/**
 * POST /statement-imports/:statement_import_id/confirm
 */
const confirmImport = async (req, res) => {
    try {
        const { statement_import_id } = req.params;
        const userId = req.user.id;
        const familyId = req.user.family_id;

        const result = await statementService.confirmStatementImport(statement_import_id, userId, familyId);

        return res.status(200).json({
            success: true,
            message: 'Semua draft transaksi terpilih berhasil dikonfirmasi ke tabel transaksi',
            data: result
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = {
    parseStatement,
    getStatementImports,
    getStatementImportById,
    cancelStatementImport,
    unlockStatement,
    getDraftTransactions,
    updateDraftTransaction,
    deleteDraftTransaction,
    confirmImport
};