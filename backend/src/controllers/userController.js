// src/controllers/userController.js
const UserService = require('../services/userService');
const { sendError } = require('../utils/response');

class UserController {
    // GET /me
    static async getProfile(req, res) {
        try {
            const user = await UserService.getUserById(req.user.id);
            return res.status(200).json(user);
        } catch (err) {
            return sendError(res, 404, 'NOT_FOUND', err.message || 'Profil pengguna tidak ditemukan.');
        }
    }

    // PATCH /me
    static async updateProfile(req, res) {
        try {
            const { display_name, avatar_url } = req.body;
            const details = [];

            if (display_name !== undefined) {
                if (typeof display_name !== 'string' || display_name.length < 2 || display_name.length > 80) {
                    details.push({ field: 'display_name', issue: 'Harus berupa string antara 2 hingga 80 karakter.' });
                }
            }

            if (avatar_url !== undefined && avatar_url !== null) {
                const urlPattern = /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([\/\w .-]*)*\/?$/;
                if (!urlPattern.test(avatar_url)) {
                    details.push({ field: 'avatar_url', issue: 'Format URL avatar tidak valid.' });
                }
            }

            if (details.length > 0) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);
            }

            const updatedUser = await UserService.updateProfile(req.user.id, { display_name, avatar_url });
            return res.status(200).json(updatedUser);
        } catch (err) {
            return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal memperbarui profil pengguna.');
        }
    }

    // POST /me/onboarding
    static async completeOnboarding(req, res) {
        try {
            const {
                preferred_name,
                household_role,
                timezone = 'Asia/Jakarta',
                default_transaction_confirmation_threshold = 500000,
                consent_version
            } = req.body;

            const details = [];

            // Validasi Required
            if (!preferred_name || preferred_name.length < 2 || preferred_name.length > 80) {
                details.push({ field: 'preferred_name', issue: 'Nama panggilan wajib diisi (2-80 karakter).' });
            }

            if (!consent_version) {
                details.push({ field: 'consent_version', issue: 'Versi persetujuan privasi wajib diisi.' });
            }

            // Validasi Enum Household Role
            const validRoles = ['partner_a', 'partner_b', 'prefer_not_to_say'];
            if (household_role && !validRoles.includes(household_role)) {
                details.push({ field: 'household_role', issue: `Peran harus salah satu dari: ${validRoles.join(', ')}.` });
            }

            // Validasi Threshold
            if (typeof default_transaction_confirmation_threshold !== 'number' || default_transaction_confirmation_threshold < 0) {
                details.push({ field: 'default_transaction_confirmation_threshold', issue: 'Batas konfirmasi transaksi harus berupa angka positif.' });
            }

            if (details.length > 0) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);
            }

            const updatedUser = await UserService.completeOnboarding(req.user.id, {
                preferred_name,
                household_role,
                timezone,
                default_transaction_confirmation_threshold,
                consent_version
            });

            return res.status(200).json(updatedUser);
        } catch (err) {
            return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal menyelesaikan onboarding.');
        }
    }
}

module.exports = UserController;