// src/routes/userRoutes.js
const express = require('express');
const router = express.Router();
const UserController = require('../controllers/userController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Semua endpoint /me membutuhkan autentikasi
router.get('/me', requireAuth, UserController.getProfile);
router.patch('/me', requireAuth, UserController.updateProfile);
router.post('/me/onboarding', requireAuth, UserController.completeOnboarding);

module.exports = router;