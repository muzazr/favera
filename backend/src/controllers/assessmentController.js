// src/controllers/assessmentController.js

const assessmentService = require('../services/assessmentService');
const aiService = require('../services/aiService');
const { transformToFamilyAssessmentDTO } = require('../utils/assessmentMapper');
const { sendError } = require('../utils/response');

/**
 * GET /family-assessments/current
 * Mengembalikan data asesmen terbaru (tanpa summary)
 */
const getCurrentAssessment = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const familyId = req.user?.family_id;

    if (!familyId) {
      return sendError(res, 400, 'BAD_REQUEST', 'Family ID tidak ditemukan pada kredensial pengguna.', [], requestId);
    }

    const rawData = await assessmentService.fetchCurrentAssessment(familyId);

    if (!rawData) {
      return sendError(res, 404, 'NOT_FOUND', 'Asesmen keluarga tidak ditemukan.', [], requestId);
    }

    const responsePayload = transformToFamilyAssessmentDTO(rawData);
    return res.status(200).json(responsePayload);

  } catch (error) {
    console.error('[AssessmentController] Get Current Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal mengambil data asesmen terbaru.', [error.message], requestId);
  }
};

/**
 * GET /family-assessments/:id
 * Khusus mengembalikan HANYA AI Summary dari asesmen tertentu
 */
const getAssessmentById = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const familyId = req.user?.family_id;
    const { id } = req.params;

    if (!familyId) {
      return sendError(res, 400, 'BAD_REQUEST', 'Family ID tidak ditemukan pada kredensial pengguna.', [], requestId);
    }

    let rawData = await assessmentService.fetchAssessmentById(id, familyId);

    if (!rawData) {
      return sendError(res, 404, 'NOT_FOUND', 'Asesmen keluarga tidak ditemukan.', [], requestId);
    }

    // Lazy Load AI Summary jika belum ada di database
    if (!rawData.summary || Object.keys(rawData.summary).length === 0) {
      const generatedSummary = await aiService.generateAssessmentSummary(rawData);
      rawData = await assessmentService.updateAssessmentSummary(rawData.id, generatedSummary);
    }

    // HANYA mengembalikan objek summary
    return res.status(200).json(rawData.summary);

  } catch (error) {
    console.error('[AssessmentController] Get By ID Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal mengambil summary asesmen.', [error.message], requestId);
  }
};

/**
 * GET /family-assessments
 * Mengembalikan riwayat asesmen (tanpa summary)
 */
const getAssessmentHistory = async (req, res) => {
  const requestId = req.headers['x-request-id'] || null;

  try {
    const familyId = req.user?.family_id;
    const limit = Math.min(parseInt(req.query.limit, 10) || 20, 100);
    const cursor = req.query.cursor || null;

    if (!familyId) {
      return sendError(res, 400, 'BAD_REQUEST', 'Family ID tidak ditemukan pada kredensial pengguna.', [], requestId);
    }

    const rawRows = await assessmentService.fetchAssessmentHistory(familyId, limit, cursor);

    const items = rawRows.map(row => transformToFamilyAssessmentDTO(row));

    const nextCursor = rawRows.length === limit ? rawRows[rawRows.length - 1].generated_at : null;

    const responsePayload = {
      items,
      pagination: {
        next_cursor: nextCursor,
        has_more: Boolean(nextCursor),
        limit
      }
    };

    return res.status(200).json(responsePayload);

  } catch (error) {
    console.error('[AssessmentController] Get History Error:', error);
    return sendError(res, 500, 'INTERNAL_SERVER_ERROR', 'Gagal mengambil riwayat asesmen.', [error.message], requestId);
  }
};

module.exports = {
  getCurrentAssessment,
  getAssessmentById,
  getAssessmentHistory
};