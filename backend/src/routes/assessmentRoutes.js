// src/routes/assessmentRoutes.js

const express = require('express');
const router = express.Router();
const assessmentController = require('../controllers/assessmentController');
const { requireAuth } = require('../middlewares/authMiddleware'); // Sesuaikan path requireAuth Anda

// Endpoint: GET /family-assessments/current
router.get(
  '/current',
  requireAuth,
  assessmentController.getCurrentAssessment
);

// Endpoint: GET /family-assessments
router.get(
  '/',
  requireAuth,
  assessmentController.getAssessmentHistory
);

// Endpoint: GET /family-assessments/:id
// WAJIB diletakkan di bawah /current
router.get(
  '/:id',
  requireAuth,
  assessmentController.getAssessmentById
);

module.exports = router;