// src/middlewares/authMiddleware.js
const supabase = require('../config/supabaseClient');
const { sendError } = require('../utils/response');

const requireAuth = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return sendError(
                res, 
                401, 
                'UNAUTHORIZED', 
                'Akses ditolak. Token otorisasi tidak ditemukan.'
            );
        }

        const token = authHeader.split(' ')[1];

        // Dapatkan Auth User dari Supabase
        const { data: { user }, error: authError } = await supabase.auth.getUser(token);

        if (authError || !user) {
            return sendError(
                res, 
                401, 
                'UNAUTHORIZED', 
                'Sesi tidak valid atau telah kedaluwarsa.'
            );
        }

        // Ambil data tambahan dari tabel public.users
        const { data: publicUser, error: dbError } = await supabase
            .from('users')
            .select('*')
            .eq('id', user.id)
            .single();

        if (dbError) {
            console.error('Error fetching public user:', dbError);
            return sendError(
                res, 
                500, 
                'INTERNAL_ERROR', 
                'Gagal memuat profil pengguna.'
            );
        }

        req.user = { ...user, ...publicUser };
        req.token = token;
        next();
    } catch (err) {
        console.error('Auth Middleware Error:', err);
        return sendError(
            res, 
            500, 
            'INTERNAL_ERROR', 
            'Terjadi kesalahan internal server.'
        );
    }
};

module.exports = { requireAuth };