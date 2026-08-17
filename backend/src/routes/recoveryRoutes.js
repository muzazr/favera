const express = require('express');
const router = express.Router();
const RecoveryController = require('../controllers/recoveryController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Middleware autentikasi untuk semua route recovery
router.use(requireAuth);

// List & Create Sesi
router.get('/', RecoveryController.getSessions);
router.post('/', RecoveryController.createSession);

// Detail Sesi
router.get('/:recovery_session_id', RecoveryController.getSessionById);

// Tahap Readiness & Reflection
router.post('/:recovery_session_id/readiness', RecoveryController.submitReadiness);
router.put('/:recovery_session_id/reflection', RecoveryController.saveReflection);

// Tahap Neutral Statement
router.post('/:recovery_session_id/statement-draft', RecoveryController.generateStatementDraft);
router.post('/:recovery_session_id/publish-statement', RecoveryController.publishStatement);

// Tahap Partner Response & Alignment
router.post('/:recovery_session_id/partner-response', RecoveryController.submitPartnerResponse);

// Kontrol Sesi
router.post('/:recovery_session_id/pause', RecoveryController.pauseSession);
router.post('/:recovery_session_id/complete', RecoveryController.completeSession);

module.exports = router;