const checkInService = require('../services/checkInService');
const { sendError } = require('../utils/response');

const getCurrentCheckIn = async (req, res) => {
  try {
    const userId = req.user.id;
    const familyId = req.user.family_id;

    if (!familyId) {
      return sendError(res, 400, 'NO_FAMILY_SPACE', 'Pengguna belum terhubung dengan ruang keluarga.');
    }

    const checkin = await checkInService.getCurrentCheckIn(userId, familyId);
    return res.status(200).json(checkin);
  } catch (error) {
    console.error('Error getCurrentCheckIn:', error);
    return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengambil data check-in aktif.');
  }
};

const getCheckInList = async (req, res) => {
  try {
    const userId = req.user.id;
    const familyId = req.user.family_id;
    const { cursor, limit } = req.query;

    if (!familyId) {
      return sendError(res, 400, 'NO_FAMILY_SPACE', 'Pengguna belum terhubung dengan ruang keluarga.');
    }

    const parsedLimit = limit ? parseInt(limit, 10) : 20;
    const result = await checkInService.getCheckInList(userId, familyId, cursor, parsedLimit);

    return res.status(200).json(result);
  } catch (error) {
    console.error('Error getCheckInList:', error);
    return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengambil riwayat check-in.');
  }
};

const getCheckInById = async (req, res) => {
  try {
    const userId = req.user.id;
    const familyId = req.user.family_id;
    const { checkin_id } = req.params;

    const checkin = await checkInService.getCheckInById(checkin_id, userId, familyId);

    if (!checkin) {
      return sendError(res, 404, 'NOT_FOUND', 'Check-in tidak ditemukan.');
    }

    return res.status(200).json(checkin);
  } catch (error) {
    if (error.message === 'FORBIDDEN') {
      return sendError(res, 403, 'FORBIDDEN', 'Anda tidak memiliki akses ke check-in ini.');
    }
    console.error('Error getCheckInById:', error);
    return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengambil detail check-in.');
  }
};

const saveAnswers = async (req, res) => {
  try {
    const userId = req.user.id;
    const familyId = req.user.family_id;
    const { checkin_id } = req.params;
    const { answers } = req.body;

    if (!Array.isArray(answers)) {
      return sendError(res, 422, 'VALIDATION_ERROR', 'Format array jawaban tidak valid.');
    }

    const updatedCheckIn = await checkInService.saveAnswersDraft(checkin_id, userId, familyId, answers);

    if (!updatedCheckIn) {
      return sendError(res, 404, 'NOT_FOUND', 'Check-in tidak ditemukan.');
    }

    return res.status(200).json(updatedCheckIn);
  } catch (error) {
    if (error.message === 'FORBIDDEN') {
      return sendError(res, 403, 'FORBIDDEN', 'Anda tidak memiliki akses ke check-in ini.');
    }
    console.error('Error saveAnswers:', error);
    return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal menyimpan draft jawaban.');
  }
};

const submitCheckIn = async (req, res) => {
  try {
    const userId = req.user.id;
    const familyId = req.user.family_id;
    const { checkin_id } = req.params;

    const updatedCheckIn = await checkInService.submitAnswers(checkin_id, userId, familyId);

    if (!updatedCheckIn) {
      return sendError(res, 404, 'NOT_FOUND', 'Check-in tidak ditemukan.');
    }

    return res.status(200).json(updatedCheckIn);
  } catch (error) {
    if (error.message === 'FORBIDDEN') {
      return sendError(res, 403, 'FORBIDDEN', 'Anda tidak memiliki akses ke check-in ini.');
    }
    console.error('Error submitCheckIn:', error);
    return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengirim jawaban check-in.');
  }
};

module.exports = {
  getCurrentCheckIn,
  getCheckInList,
  getCheckInById,
  saveAnswers,
  submitCheckIn
};