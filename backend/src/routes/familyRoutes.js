// src/routes/familyRoutes.js
const express = require('express');
const router = express.Router();
const FamilyController = require('../controllers/familyController');
const { requireAuth } = require('../middlewares/authMiddleware');

// Semua endpoint /family membutuhkan token JWT aktif
router.get('/', requireAuth, FamilyController.getFamilySpace);
router.post('/invitations', requireAuth, FamilyController.createInvitation);
router.get('/invitations', requireAuth, FamilyController.getInvitations);
router.post('/invitations/:invite_code/accept', requireAuth, FamilyController.acceptInvitation);
router.post('/invitations/:invite_code/reject', requireAuth, FamilyController.rejectInvitation);
router.delete('/invitations/:invitation_id', requireAuth, FamilyController.revokeInvitation);
router.patch('/settings', requireAuth, FamilyController.updateSettings);
router.post('/consents', requireAuth, FamilyController.updateConsent);
router.post('/disconnect', requireAuth, FamilyController.disconnectFamily);

module.exports = router;