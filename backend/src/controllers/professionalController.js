const ProfessionalService = require('../services/professionalService');
const { sendError } = require('../utils/response');

class ProfessionalController {
  static async getProfessionals(req, res) {
    try {
      const { limit, cursor, category, city, service_mode, cost_type } = req.query;

      const result = await ProfessionalService.getProfessionals({
        limit,
        cursor,
        category,
        city,
        service_mode,
        cost_type
      });

      return res.status(200).json(result);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil daftar profesional.', [err.message], req.id);
    }
  }

  static async getProfessionalById(req, res) {
    try {
      const { professional_id } = req.params;
      const professional = await ProfessionalService.getProfessionalById(professional_id);

      if (!professional) {
        return sendError(res, 404, 'NOT_FOUND', 'Profesional tidak ditemukan.', [], req.id);
      }

      return res.status(200).json(professional);
    } catch (err) {
      return sendError(res, 500, 'SERVER_ERROR', 'Gagal mengambil detail profesional.', [err.message], req.id);
    }
  }
}

module.exports = ProfessionalController;