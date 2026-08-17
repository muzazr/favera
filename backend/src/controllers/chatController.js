// src/controllers/chatController.js

const chatService = require('../services/chatService');
const { sendError } = require('../utils/response');

/**
 * GET /chat/sessions
 */
const getSessions = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const userId = req.user?.id;
    if (!userId) {
      return sendError(res, 401, 'UNAUTHORIZED', 'Pengguna belum terautentikasi.', [], requestId);
    }

    const limit = Math.min(parseInt(req.query.limit, 10) || 20, 100);
    const cursor = req.query.cursor || null;

    const rawSessions = await chatService.fetchSessions(userId, limit, cursor);

    const nextCursor = rawSessions.length === limit ? rawSessions[rawSessions.length - 1].updated_at : null;

    return res.status(200).json({
      items: rawSessions,
      pagination: {
        next_cursor: nextCursor,
        has_more: Boolean(nextCursor),
        limit
      }
    });

  } catch (error) {
    console.error('[ChatController] Get Sessions Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal mengambil daftar sesi chat.', [error.message], requestId);
  }
};

/**
 * POST /chat/sessions
 */
const createSession = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const userId = req.user?.id;
    if (!userId) {
      return sendError(res, 401, 'UNAUTHORIZED', 'Pengguna belum terautentikasi.', [], requestId);
    }

    const { title, context_scope } = req.body;

    if (!context_scope || !Array.isArray(context_scope)) {
      return sendError(res, 422, 'VALIDATION_ERROR', 'Atribut context_scope wajib diisi berupa array.', [], requestId);
    }

    const newSession = await chatService.createSession(userId, title, context_scope);
    return res.status(201).json(newSession);

  } catch (error) {
    console.error('[ChatController] Create Session Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal membuat sesi chat.', [error.message], requestId);
  }
};

/**
 * GET /chat/sessions/:chat_session_id
 */
const getSessionById = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const userId = req.user?.id;
    const { chat_session_id } = req.params;

    const session = await chatService.fetchSessionById(chat_session_id, userId);

    if (!session) {
      return sendError(res, 404, 'NOT_FOUND', 'Sesi chat tidak ditemukan.', [], requestId);
    }

    return res.status(200).json(session);

  } catch (error) {
    console.error('[ChatController] Get Session Detail Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal mengambil detail sesi chat.', [error.message], requestId);
  }
};

/**
 * DELETE /chat/sessions/:chat_session_id
 */
const deleteSession = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const userId = req.user?.id;
    const { chat_session_id } = req.params;

    const session = await chatService.fetchSessionById(chat_session_id, userId);

    if (!session) {
      return sendError(res, 404, 'NOT_FOUND', 'Sesi chat tidak ditemukan.', [], requestId);
    }

    await chatService.deleteSession(chat_session_id, userId);
    return res.status(204).send();

  } catch (error) {
    console.error('[ChatController] Delete Session Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal menghapus sesi chat.', [error.message], requestId);
  }
};

/**
 * GET /chat/sessions/:chat_session_id/messages
 */
const getMessages = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const userId = req.user?.id;
    const { chat_session_id } = req.params;
    const limit = Math.min(parseInt(req.query.limit, 10) || 20, 100);
    const cursor = req.query.cursor || null;

    const session = await chatService.fetchSessionById(chat_session_id, userId);
    if (!session) {
      return sendError(res, 404, 'NOT_FOUND', 'Sesi chat tidak ditemukan.', [], requestId);
    }

    const messages = await chatService.fetchMessages(chat_session_id, limit, cursor);

    const nextCursor = messages.length === limit ? messages[0].created_at : null;

    return res.status(200).json({
      items: messages,
      pagination: {
        next_cursor: nextCursor,
        has_more: Boolean(nextCursor),
        limit
      }
    });

  } catch (error) {
    console.error('[ChatController] Get Messages Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal mengambil riwayat pesan.', [error.message], requestId);
  }
};

/**
 * POST /chat/sessions/:chat_session_id/messages
 */
const sendMessage = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const userId = req.user?.id;
    const familyId = req.user?.family_id;
    const { chat_session_id } = req.params;
    const { message } = req.body;

    if (!message || message.trim() === '') {
      return sendError(res, 422, 'VALIDATION_ERROR', 'Pesan tidak boleh kosong.', [], requestId);
    }

    const session = await chatService.fetchSessionById(chat_session_id, userId);
    if (!session) {
      return sendError(res, 404, 'NOT_FOUND', 'Sesi chat tidak ditemukan.', [], requestId);
    }

    const assistantMessage = await chatService.sendMessageAndGenerateResponse(session, familyId, message);

    return res.status(200).json(assistantMessage);

  } catch (error) {
    console.error('[ChatController] Send Message Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal mengirim pesan.', [error.message], requestId);
  }
};

module.exports = {
  getSessions,
  createSession,
  getSessionById,
  deleteSession,
  getMessages,
  sendMessage
};