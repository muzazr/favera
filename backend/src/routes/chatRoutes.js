// src/routes/chatRoutes.js

const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');
const { requireAuth } = require('../middlewares/authMiddleware'); 

// Listing & Buat Sesi Chat
router.get('/sessions', requireAuth, chatController.getSessions);
router.post('/sessions', requireAuth, chatController.createSession);

// Detail & Hapus Sesi Chat
router.get('/sessions/:chat_session_id', requireAuth, chatController.getSessionById);
router.delete('/sessions/:chat_session_id', requireAuth, chatController.deleteSession);

// Listing & Kirim Pesan
router.get('/sessions/:chat_session_id/messages', requireAuth, chatController.getMessages);
router.post('/sessions/:chat_session_id/messages', requireAuth, chatController.sendMessage);

module.exports = router;