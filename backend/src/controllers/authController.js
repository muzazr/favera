// src/controllers/authController.js
const AuthService = require('../services/authService');
const { sendError } = require('../utils/response');

class AuthController {
    static async register(req, res) {
        try {
            const { display_name, email, password, privacy_consent } = req.body;
            const details = [];

            // Validasi Input
            if (!display_name || display_name.length < 2 || display_name.length > 80) {
                details.push({ field: 'display_name', issue: 'Harus antara 2 hingga 80 karakter.' });
            }
            if (!email || !/^\S+@\S+\.\S+$/.test(email)) {
                details.push({ field: 'email', issue: 'Format email tidak valid.' });
            }
            if (!password || password.length < 8) {
                details.push({ field: 'password', issue: 'Password minimal 8 karakter.' });
            }
            if (privacy_consent !== true) {
                details.push({ field: 'privacy_consent', issue: 'Persetujuan privasi harus disetujui (true).' });
            }

            if (details.length > 0) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);
            }

            const result = await AuthService.register({ display_name, email, password, privacy_consent });
            return res.status(201).json(result);
        } catch (err) {
            if (err.message?.includes('already registered') || err.code === '23505') {
                return sendError(res, 409, 'CONFLICT', 'Email sudah terdaftar.');
            }
            return sendError(res, 500, 'INTERNAL_ERROR', err.message || 'Gagal melakukan registrasi.');
        }
    }

    static async login(req, res) {
        try {
            const { email, password } = req.body;
            const details = [];

            if (!email) details.push({ field: 'email', issue: 'Email wajib diisi.' });
            if (!password) details.push({ field: 'password', issue: 'Password wajib diisi.' });

            if (details.length > 0) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);
            }

            const result = await AuthService.login({ email, password });
            return res.status(200).json(result);
        } catch (err) {
            return sendError(res, 401, 'UNAUTHORIZED', 'Email atau kata sandi salah.');
        }
    }

    static async refresh(req, res) {
        try {
            const { refresh_token } = req.body;

            if (!refresh_token) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', [
                    { field: 'refresh_token', issue: 'Refresh token wajib diisi.' }
                ]);
            }

            const result = await AuthService.refresh(refresh_token);
            return res.status(200).json(result);
        } catch (err) {
            return sendError(res, 401, 'UNAUTHORIZED', 'Refresh token tidak valid atau kedaluwarsa.');
        }
    }

    static async logout(req, res) {
    try {
        await AuthService.logout(req.token);
        return res.status(204).send(); // 204 No Content
    } catch (err) {
        console.error('Logout Error:', err);
        return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal melakukan logout.');
    }
}

    static async forgotPassword(req, res) {
        try {
            const { email } = req.body;

            if (!email || !/^\S+@\S+\.\S+$/.test(email)) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', [
                    { field: 'email', issue: 'Format email tidak valid.' }
                ]);
            }

            const result = await AuthService.forgotPassword(email);
            return res.status(200).json(result);
        } catch (err) {
            return sendError(res, 500, 'INTERNAL_ERROR', 'Gagal mengirim email pemulihan.');
        }
    }

    static async resetPassword(req, res) {
        try {
            const { reset_token, new_password } = req.body;
            const details = [];

            if (!reset_token) details.push({ field: 'reset_token', issue: 'Reset token wajib diisi.' });
            if (!new_password || new_password.length < 8) {
                details.push({ field: 'new_password', issue: 'Kata sandi baru minimal 8 karakter.' });
            }

            if (details.length > 0) {
                return sendError(res, 422, 'VALIDATION_ERROR', 'Input tidak valid.', details);
            }

            const result = await AuthService.resetPassword(reset_token, new_password);
            return res.status(200).json(result);
        } catch (err) {
            return sendError(res, 400, 'BAD_REQUEST', 'Reset token tidak valid atau telah kedaluwarsa.');
        }
    }
}

module.exports = AuthController;