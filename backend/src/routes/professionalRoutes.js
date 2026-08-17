const express = require('express');
const router = express.Router();
const ProfessionalController = require('../controllers/professionalController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.get('/', ProfessionalController.getProfessionals);
router.get('/:professional_id', ProfessionalController.getProfessionalById);

module.exports = router;