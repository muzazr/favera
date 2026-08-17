const ConsultationService = require('../services/consultationService');
const { sendError } = require('../utils/response');

class ConsultationController {
  static async getConsultations(req, res) {
    try {
      const userId = req.user.id;
      const { limit = 20, cursor } = req.query;

      const result = await ConsultationService.getConsultations(userId, { limit, cursor });
      return res.status(200).json(result);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil daftar konsultasi.', [err.message], req.id);
    }
  }

  static async createConsultation(req, res) {
    try {
      const userId = req.user.id;
      const familyId = req.user.family_id;
      const { professional_name, service_type, scheduled_at, meeting_method, visibility } = req.body;

      if (!professional_name || !service_type || !scheduled_at || !meeting_method || !visibility) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Atribut wajib consultation (professional_name, service_type, scheduled_at, meeting_method, visibility) harus diisi.', [], req.id);
      }

      const consultation = await ConsultationService.createConsultation(userId, familyId, req.body);
      return res.status(201).json(consultation);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mencatat jadwal konsultasi.', [err.message], req.id);
    }
  }

  static async getConsultationById(req, res) {
    try {
      const userId = req.user.id;
      const { consultation_id } = req.params;

      const consultation = await ConsultationService.getConsultationById(consultation_id, userId);
      if (!consultation) {
        return sendError(res, 404, 'NOT_FOUND', 'Konsultasi tidak ditemukan.', [], req.id);
      }

      return res.status(200).json(consultation);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil detail konsultasi.', [err.message], req.id);
    }
  }

  static async updateConsultation(req, res) {
    try {
      const userId = req.user.id;
      const { consultation_id } = req.params;

      const updated = await ConsultationService.updateConsultation(consultation_id, userId, req.body);
      return res.status(200).json(updated);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Konsultasi tidak ditemukan.', [], req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal memperbarui konsultasi.', [err.message], req.id);
    }
  }

  static async updateChecklist(req, res) {
    try {
      const userId = req.user.id;
      const { consultation_id } = req.params;
      const { items } = req.body;

      if (!Array.isArray(items)) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Field items wajib berupa array.', [], req.id);
      }

      const updated = await ConsultationService.updateChecklist(consultation_id, userId, items);
      return res.status(200).json(updated);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Konsultasi tidak ditemukan.', [], req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal memperbarui checklist konsultasi.', [err.message], req.id);
    }
  }

  static async addNote(req, res) {
    try {
      const userId = req.user.id;
      const { consultation_id } = req.params;
      const { content, visibility } = req.body;

      if (!content || !visibility) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Field content dan visibility wajib diisi.', [], req.id);
      }

      const updated = await ConsultationService.addNote(consultation_id, userId, req.body);
      return res.status(200).json(updated);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Konsultasi tidak ditemukan.', [], req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal menambahkan catatan konsultasi.', [err.message], req.id);
    }
  }

  static async convertToCommitment(req, res) {
    try {
      const userId = req.user.id;
      const familyId = req.user.family_id;
      const { consultation_id } = req.params;
      const { title, action, responsible_user_ids, start_date, success_indicator } = req.body;

      if (!title || !action || !responsible_user_ids || !start_date || !success_indicator) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Field title, action, responsible_user_ids, start_date, dan success_indicator wajib diisi.', [], req.id);
      }

      const commitment = await ConsultationService.convertToCommitment(consultation_id, userId, familyId, req.body);
      return res.status(201).json(commitment);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Konsultasi tidak ditemukan.', [], req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal membuat komitmen dari konsultasi.', [err.message], req.id);
    }
  }
}

module.exports = ConsultationController;