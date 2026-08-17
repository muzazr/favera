// src/services/authService.js
const supabase = require('../config/supabaseClient');

class AuthService {
    static async register({ email, password, display_name, privacy_consent }) {
        // 1. Sign up ke Supabase Auth
        const { data: authData, error: authError } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: { display_name }
            }
        });

        if (authError) throw authError;

        const user = authData.user;
        if (!user) throw new Error('Gagal membuat akun pengguna.');

        // 2. Simpan profil ke tabel public.users
        const { data: publicUser, error: dbError } = await supabase
            .from('users')
            .insert([
                {
                    id: user.id,
                    email,
                    display_name,
                    privacy_consent
                }
            ])
            .select()
            .single();

        if (dbError) {
            // Rollback auth user jika insert DB gagal
            await supabase.auth.admin.deleteUser(user.id);
            throw dbError;
        }

        // Format return AuthTokens
        return {
            access_token: authData.session?.access_token || '',
            refresh_token: authData.session?.refresh_token || '',
            token_type: 'Bearer',
            expires_in: authData.session?.expires_in || 3600,
            user: {
                id: publicUser.id,
                email: publicUser.email,
                display_name: publicUser.display_name,
                created_at: publicUser.created_at
            }
        };
    }

    static async login({ email, password }) {
        const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (authError) throw authError;

        const { data: publicUser, error: dbError } = await supabase
            .from('users')
            .select('*')
            .eq('id', authData.user.id)
            .single();

        if (dbError) throw dbError;

        return {
            access_token: authData.session.access_token,
            refresh_token: authData.session.refresh_token,
            token_type: 'Bearer',
            expires_in: authData.session.expires_in,
            user: {
                id: publicUser.id,
                email: publicUser.email,
                display_name: publicUser.display_name,
                created_at: publicUser.created_at
            }
        };
    }

    static async refresh(refreshToken) {
        const { data: authData, error: authError } = await supabase.auth.refreshSession({
            refresh_token: refreshToken
        });

        if (authError) throw authError;

        const { data: publicUser } = await supabase
            .from('users')
            .select('*')
            .eq('id', authData.user.id)
            .single();

        return {
            access_token: authData.session.access_token,
            refresh_token: authData.session.refresh_token,
            token_type: 'Bearer',
            expires_in: authData.session.expires_in,
            user: {
                id: publicUser.id,
                email: publicUser.email,
                display_name: publicUser.display_name,
                created_at: publicUser.created_at
            }
        };
    }

    static async logout(accessToken) {
    // Gunakan admin.signOut dengan JWT scope 'global' jika pakai Service Role
    // Atau jika pakai client biasa, gunakan signOut standard:
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
}

    static async forgotPassword(email) {
        const { error } = await supabase.auth.resetPasswordForEmail(email);
        if (error) throw error;
        return { accepted: true };
    }

    static async resetPassword(resetToken, newPassword) {
        // Set session menggunakan reset_token
        const { error: sessionError } = await supabase.auth.setSession({
            access_token: resetToken,
            refresh_token: resetToken
        });

        if (sessionError) throw sessionError;

        const { error: updateError } = await supabase.auth.updateUser({
            password: newPassword
        });

        if (updateError) throw updateError;

        return { updated: true };
    }
}

module.exports = AuthService;