// src/routes/transactionRoutes.js
const express = require('express');
const router = express.Router();
const transactionController = require('../controllers/transactionController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Standard CRUD Endpoints
router.get('/', requireAuth, transactionController.getTransactions);
router.post('/', requireAuth, transactionController.createTransaction);
router.get('/:transaction_id', requireAuth, transactionController.getTransactionById);
router.patch('/:transaction_id', requireAuth, transactionController.updateTransaction);
router.delete('/:transaction_id', requireAuth, transactionController.deleteTransaction);

// Action / Feature Endpoints
router.post('/:transaction_id/confirmation', requireAuth, transactionController.confirmTransaction);
router.post('/:transaction_id/feedback', requireAuth, transactionController.submitFeedback);

module.exports = router;