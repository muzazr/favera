const express = require('express');
const router = express.Router();
const multer = require('multer');
const statementController = require('../controllers/statementController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Konfigurasi Multer Memory Storage (File ephemeral di RAM)
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 } // Batas maksimum 10MB
});

// GET /statement-imports
router.get(
    '/',
    requireAuth,
    statementController.getStatementImports
);

// POST /statement-imports
router.post(
    '/',
    requireAuth,
    upload.single('file'),
    statementController.parseStatement
);

// GET /statement-imports/:statement_import_id
router.get(
    '/:statement_import_id',
    requireAuth,
    statementController.getStatementImportById
);

// DELETE /statement-imports/:statement_import_id
router.delete(
    '/:statement_import_id',
    requireAuth,
    statementController.cancelStatementImport
);

// POST /statement-imports/:statement_import_id/unlock
router.post(
    '/:statement_import_id/unlock',
    requireAuth,
    statementController.unlockStatement
);

// GET /statement-imports/:statement_import_id/draft-transactions
router.get(
    '/:statement_import_id/draft-transactions',
    requireAuth,
    statementController.getDraftTransactions
);

// PATCH /statement-imports/:statement_import_id/draft-transactions/:draft_transaction_id
router.patch(
    '/:statement_import_id/draft-transactions/:draft_transaction_id',
    requireAuth,
    statementController.updateDraftTransaction
);

// DELETE /statement-imports/:statement_import_id/draft-transactions/:draft_transaction_id
router.delete(
    '/:statement_import_id/draft-transactions/:draft_transaction_id',
    requireAuth,
    statementController.deleteDraftTransaction
);

// POST /statement-imports/:statement_import_id/confirm
router.post(
    '/:statement_import_id/confirm',
    requireAuth,
    statementController.confirmImport
);

module.exports = router;