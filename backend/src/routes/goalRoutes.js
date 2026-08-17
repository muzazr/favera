// src/routes/goalRoutes.js
const express = require('express');
const router = express.Router();
const goalController = require('../controllers/goalController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Semua endpoint membutuhkan autentikasi
router.use(requireAuth);

router.get('/', (req, res) => goalController.getGoals(req, res));
router.post('/', (req, res) => goalController.createGoal(req, res));
router.get('/:goal_id', (req, res) => goalController.getGoalById(req, res));
router.patch('/:goal_id', (req, res) => goalController.updateGoal(req, res));
router.post('/:goal_id/approval', (req, res) => goalController.approveGoal(req, res));
router.post('/:goal_id/contributions', (req, res) => goalController.addContribution(req, res));

module.exports = router;