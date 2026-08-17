const RecoveryService = require('../services/recoveryService');
const { sendError } = require('../utils/response');

class RecoveryController {
  static async getSessions(req, res) {
    try {
      const familyId = req.user.family_id;
      const { limit, cursor, status } = req.query;

      const data = await RecoveryService.getSessions(familyId, { limit, cursor, status });
      return res.status(200).json({ success: true, data });
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil daftar sesi pemulihan.', err.message, req.id);
    }
  }

  static async createSession(req, res) {
    try {
      const familyId = req.user.family_id;
      const userId = req.user.id;
      const { topic, custom_topic } = req.body;

      if (!topic) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Topik pemulihan wajib diisi.', null, req.id);
      }

      const data = await RecoveryService.createSession(familyId, userId, topic, custom_topic);
      return res.status(201).json({ success: true, data });
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal membuat sesi pemulihan.', err.message, req.id);
    }
  }

  static async getSessionById(req, res) {
    try {
      const { recovery_session_id } = req.params;
      const userId = req.user.id;

      const data = await RecoveryService.getSessionById(recovery_session_id, userId);
      if (!data) {
        return sendError(res, 404, 'NOT_FOUND', 'Sesi pemulihan tidak ditemukan.', null, req.id);
      }

      return res.status(200).json({ success: true, data });
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil detail sesi.', err.message, req.id);
    }
  }

  static async submitReadiness(req, res) {
    try {
      const { recovery_session_id } = req.params;
      const userId = req.user.id;
      const { readiness_level, feels_safe } = req.body;

      if (readiness_level === undefined || feels_safe === undefined) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Field readiness_level dan feels_safe wajib diisi.', null, req.id);
      }

      const data = await RecoveryService.submitReadiness(recovery_session_id, userId, readiness_level, feels_safe);
      return res.status(200).json({ success: true, data });
    } catch (err) {
      if (err.message === 'SESSION_NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Sesi tidak ditemukan.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal memperbarui kesiapan.', err.message, req.id);
    }
  }

  static async saveReflection(req, res) {
    try {
      const { recovery_session_id } = req.params;
      const userId = req.user.id;
      const { facts, impact, feelings, needs, expectations } = req.body;

      const data = await RecoveryService.saveReflection(recovery_session_id, userId, {
        facts, impact, feelings, needs, expectations
      });

      return res.status(200).json({ success: true, data });
    } catch (err) {
      if (err.message === 'SESSION_NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Sesi tidak ditemukan.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal menyimpan refleksi.', err.message, req.id);
    }
  }

  static async generateStatementDraft(req, res) {
    try {
      const { recovery_session_id } = req.params;
      const userId = req.user.id;

      const data = await RecoveryService.generateStatementDraft(recovery_session_id, userId);
      return res.status(200).json({ success: true, data });
    } catch (err) {
      if (err.message === 'REFLECTION_NOT_FOUND') {
        return sendError(res, 400, 'PRECONDITION_FAILED', 'Refleksi pribadi harus diisi terlebih dahulu.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal membuat draf pernyataan.', err.message, req.id);
    }
  }

  static async publishStatement(req, res) {
    try {
      const { recovery_session_id } = req.params;
      const { explicit_share_consent } = req.body;

      const data = await RecoveryService.publishStatement(recovery_session_id, explicit_share_consent);
      return res.status(200).json({ success: true, data });
    } catch (err) {
      if (err.message === 'CONSENT_REQUIRED') {
        return sendError(res, 400, 'CONSENT_REQUIRED', 'Persetujuan eksplisit diperlukan untuk mempublikasikan.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mempublikasikan pernyataan.', err.message, req.id);
    }
  }

  static async submitPartnerResponse(req, res) {
    try {
      const { recovery_session_id } = req.params;
      const { response_type, note, proposed_time } = req.body;

      if (!response_type) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'response_type wajib diisi.', null, req.id);
      }

      const data = await RecoveryService.submitPartnerResponse(recovery_session_id, response_type, note, proposed_time);
      return res.status(200).json({ success: true, data });
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengirim respons pasangan.', err.message, req.id);
    }
  }

  static async pauseSession(req, res) {
  try {
    const { recovery_session_id } = req.params;

    const data = await RecoveryService.pauseSession(recovery_session_id);
    return res.status(200).json({ success: true, data });
  } catch (err) {
    return sendError(res, 500, 'SERVER_ERROR', 'Gagal menjedakan sesi.', err.message, req.id);
  }
}

static async completeSession(req, res) {
  try {
    const { recovery_session_id } = req.params;

    const data = await RecoveryService.completeSession(recovery_session_id);
    return res.status(200).json({ success: true, data });
  } catch (err) {
    return sendError(res, 500, 'SERVER_ERROR', 'Gagal menyelesaikan sesi.', err.message, req.id);
  }
}
}

module.exports = RecoveryController;