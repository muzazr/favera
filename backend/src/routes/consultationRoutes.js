const express = require('express');
const router = express.Router();
const ConsultationController = require('../controllers/consultationController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.get('/', ConsultationController.getConsultations);
router.post('/', ConsultationController.createConsultation);
router.get('/:consultation_id', ConsultationController.getConsultationById);
router.patch('/:consultation_id', ConsultationController.updateConsultation);
router.put('/:consultation_id/checklist', ConsultationController.updateChecklist);
router.post('/:consultation_id/notes', ConsultationController.addNote);
router.post('/:consultation_id/convert-to-commitment', ConsultationController.convertToCommitment);

module.exports = router;