// src/controllers/familyController.js
const FamilyService = require('../services/familyService');
const { sendError } = require('../utils/response');

class FamilyController {
    // GET /family
    static async getFamilySpace(req, res) {
        try {
            const family = await FamilyService.getActiveFamily(req.user.id);
            if (!family) {
                return sendError(res, 404, 'NOT_FOUND', 'Anda belum terhubung ke ruang keluarga mana pun.');
            }
            return res.status(200).json(family);
        } catch (err) {
            return sendError(res, err.statusCode || 500, err.code || 'INTERNAL_ERROR', err.message || 'Gagal mengambil data ruang keluarga.');
        }
    }

    // POST /family/invitations
    static async createInvitation(req, res) {
        try {
            const { expires_in_hours = 24 } = req.body;
            
            if (typeof expires_in_hours !== 'number' || expires_in_hours < 1 || expires_in_hours > 168) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', [
                    { field: 'expires_in_hours', issue: 'Masa berlaku harus antara 1 sampai 168 jam.' }
                ]);
            }

            const invitation = await FamilyService.createInvitation(req.user.id, expires_in_hours);
            return res.status(201).json(invitation);
        } catch (err) {
            return sendError(res, err.statusCode || 500, err.code || 'INTERNAL_ERROR', err.message || 'Gagal membuat undangan.');
        }
    }

    // GET /family/invitations
    static async getInvitations(req, res) {
        try {
            const invitations = await FamilyService.getActiveInvitations(req.user.id);
            return res.status(200).json(invitations);
        } catch (err) {
            return sendError(res, err.statusCode || 500, err.code || 'INTERNAL_ERROR', err.message || 'Gagal mengambil daftar undangan.');
        }
    }

    // POST /family/invitations/:invite_code/accept
    static async acceptInvitation(req, res) {
        try {
            const { invite_code } = req.params;
            const { consent_version, shared_data_categories } = req.body;

            const details = [];
            if (!consent_version) details.push({ field: 'consent_version', issue: 'Versi persetujuan wajib diisi.' });
            if (!Array.isArray(shared_data_categories)) details.push({ field: 'shared_data_categories', issue: 'Kategori data harus berupa array.' });

            if (details.length > 0) return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);

            const familySpace = await FamilyService.acceptInvitation(req.user.id, invite_code, consent_version, shared_data_categories);
            return res.status(200).json(familySpace);
        } catch (err) {
            return sendError(res, err.statusCode || 400, err.code || 'BAD_REQUEST', err.message || 'Gagal menerima undangan.');
        }
    }

    // POST /family/invitations/:invite_code/reject
    static async rejectInvitation(req, res) {
        try {
            const { invite_code } = req.params;
            const invitation = await FamilyService.rejectInvitation(invite_code);
            return res.status(200).json(invitation);
        } catch (err) {
            return sendError(res, err.statusCode || 404, err.code || 'NOT_FOUND', err.message || 'Undangan tidak ditemukan.');
        }
    }

    // DELETE /family/invitations/:invitation_id
    static async revokeInvitation(req, res) {
        try {
            const { invitation_id } = req.params;
            await FamilyService.revokeInvitation(invitation_id, req.user.id);
            return res.status(204).send();
        } catch (err) {
            return sendError(res, err.statusCode || 500, err.code || 'INTERNAL_ERROR', err.message || 'Gagal mencabut undangan.');
        }
    }

    // PATCH /family/settings
    static async updateSettings(req, res) {
        try {
            const family = await FamilyService.getActiveFamily(req.user.id);
            if (!family) return sendError(res, 404, 'NOT_FOUND', 'Ruang keluarga tidak ditemukan.');

            const { name, transaction_confirmation_threshold } = req.body;
            const details = [];

            if (name !== undefined && (typeof name !== 'string' || name.trim().length < 2 || name.trim().length > 100)) {
                details.push({ field: 'name', issue: 'Nama ruang keluarga harus antara 2-100 karakter.' });
            }
            if (transaction_confirmation_threshold !== undefined && (typeof transaction_confirmation_threshold !== 'number' || transaction_confirmation_threshold < 0)) {
                details.push({ field: 'transaction_confirmation_threshold', issue: 'Nilai batas konfirmasi harus berupa angka positif.' });
            }

            if (details.length > 0) return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);

            const updatedFamily = await FamilyService.updateSettings(family.id, { name, transaction_confirmation_threshold });
            return res.status(200).json(updatedFamily);
        } catch (err) {
            return sendError(res, err.statusCode || 500, err.code || 'INTERNAL_ERROR', err.message || 'Gagal memperbarui pengaturan ruang keluarga.');
        }
    }

    // POST /family/consents
    static async updateConsent(req, res) {
        try {
            const family = await FamilyService.getActiveFamily(req.user.id);
            if (!family) return sendError(res, 404, 'NOT_FOUND', 'Ruang keluarga tidak ditemukan.');

            const { consent_version, shared_data_categories, accepted } = req.body;
            const details = [];

            if (!consent_version) details.push({ field: 'consent_version', issue: 'Versi persetujuan wajib diisi.' });
            if (!Array.isArray(shared_data_categories)) details.push({ field: 'shared_data_categories', issue: 'Kategori data harus berupa array.' });
            if (typeof accepted !== 'boolean') details.push({ field: 'accepted', issue: 'Status persetujuan harus boolean.' });

            if (details.length > 0) return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);

            const updatedFamily = await FamilyService.updateConsent(req.user.id, family.id, consent_version, shared_data_categories, accepted);
            return res.status(200).json(updatedFamily);
        } catch (err) {
            return sendError(res, err.statusCode || 500, err.code || 'INTERNAL_ERROR', err.message || 'Gagal memperbarui persetujuan.');
        }
    }

    // POST /family/disconnect
    static async disconnectFamily(req, res) {
        try {
            const family = await FamilyService.getActiveFamily(req.user.id);
            if (!family) return sendError(res, 404, 'NOT_FOUND', 'Ruang keluarga tidak ditemukan.');

            const { password } = req.body;
            if (!password) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Kata sandi wajib diisi untuk autentikasi ulang.', [
                    { field: 'password', issue: 'Kata sandi wajib diisi.' }
                ]);
            }

            const result = await FamilyService.disconnectFamily(req.user.id, family.id, password);
            return res.status(200).json(result);
        } catch (err) {
            return sendError(res, err.statusCode || 401, err.code || 'UNAUTHORIZED', err.message || 'Gagal memutuskan koneksi pasangan.');
        }
    }
}

module.exports = FamilyController;