const CommitmentService = require('../services/commitmentService');
const { sendError } = require('../utils/response');

class CommitmentController {
  static async getCommitments(req, res) {
    try {
      const familyId = req.user.family_id;
      const { limit = 20, cursor } = req.query;

      const data = await CommitmentService.getCommitments(familyId, { limit, cursor });
      return res.status(200).json(data);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil daftar komitmen.', err.message, req.id);
    }
  }

  static async createCommitment(req, res) {
    try {
      const familyId = req.user.family_id;
      const userId = req.user.id;
      const { title, action, responsible_user_ids, start_date, success_indicator } = req.body;

      if (!title || !action || !responsible_user_ids || !start_date || !success_indicator) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Field wajib tidak boleh kosong.', null, req.id);
      }

      const data = await CommitmentService.createCommitment(familyId, userId, req.body);
      return res.status(201).json(data);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal membuat komitmen.', err.message, req.id);
    }
  }

  static async getCommitmentById(req, res) {
    try {
      const familyId = req.user.family_id;
      const { commitment_id } = req.params;

      const data = await CommitmentService.getCommitmentById(commitment_id, familyId);
      if (!data) {
        return sendError(res, 404, 'NOT_FOUND', 'Komitmen tidak ditemukan.', null, req.id);
      }

      return res.status(200).json(data);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil detail komitmen.', err.message, req.id);
    }
  }

  static async reviseCommitment(req, res) {
    try {
      const familyId = req.user.family_id;
      const userId = req.user.id;
      const { commitment_id } = req.params;

      const data = await CommitmentService.reviseCommitment(commitment_id, familyId, userId, req.body);
      return res.status(200).json(data);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Komitmen tidak ditemukan.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal merevisi komitmen.', err.message, req.id);
    }
  }

  static async approveCommitment(req, res) {
    try {
      const familyId = req.user.family_id;
      const userId = req.user.id;
      const { commitment_id } = req.params;
      const { decision, comment } = req.body;

      if (!decision || !['approve', 'reject'].includes(decision)) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'Nilai decision harus approve atau reject.', null, req.id);
      }

      const data = await CommitmentService.approveCommitment(commitment_id, familyId, userId, decision, comment);
      return res.status(200).json(data);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Komitmen tidak ditemukan.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal memperbarui persetujuan komitmen.', err.message, req.id);
    }
  }

  static async updateProgress(req, res) {
    try {
      const familyId = req.user.family_id;
      const userId = req.user.id;
      const { commitment_id } = req.params;
      const { progress_percent, note, evidence } = req.body;

      if (progress_percent === undefined || progress_percent < 0 || progress_percent > 100) {
        return sendError(res, 400, 'VALIDATION_ERROR', 'progress_percent harus antara 0 dan 100.', null, req.id);
      }

      const data = await CommitmentService.updateProgress(commitment_id, familyId, userId, progress_percent, note, evidence);
      return res.status(200).json(data);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Komitmen tidak ditemukan.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal memperbarui progres komitmen.', err.message, req.id);
    }
  }

  static async completeCommitment(req, res) {
    try {
      const familyId = req.user.family_id;
      const { commitment_id } = req.params;

      const data = await CommitmentService.completeCommitment(commitment_id, familyId);
      return res.status(200).json(data);
    } catch (err) {
      if (err.message === 'NOT_FOUND') {
        return sendError(res, 404, 'NOT_FOUND', 'Komitmen tidak ditemukan.', null, req.id);
      }
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal menyelesaikan komitmen.', err.message, req.id);
    }
  }
}

module.exports = CommitmentController;