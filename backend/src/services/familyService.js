// src/services/familyService.js
const supabase = require('../config/supabaseClient');
const crypto = require('crypto');

class FamilyService {
    static DEFAULT_SHARED_CATEGORIES = [
        "confirmed_transactions",
        "financial_goals",
        "checkin_summary",
        "commitments"
    ];

    // Helper untuk memformat FamilySpace
    static async getFormattedFamilySpace(familyId) {
        const { data: family, error: familyError } = await supabase
            .from('family_spaces')
            .select('*')
            .eq('id', familyId)
            .single();

        if (familyError || !family) {
            const err = new Error('Ruang keluarga tidak ditemukan.');
            err.statusCode = 404;
            throw err;
        }

        const { data: members, error: membersError } = await supabase
            .from('family_members')
            .select(`
                user_id,
                joined_at,
                consent_status,
                shared_data_categories,
                users (
                    display_name,
                    avatar_url
                )
            `)
            .eq('family_id', familyId);

        if (membersError) throw membersError;

        const formattedMembers = members.map(m => ({
            user_id: m.user_id,
            display_name: m.users?.display_name || 'Tanpa Nama',
            avatar_url: m.users?.avatar_url || null,
            joined_at: m.joined_at,
            consent_status: m.consent_status,
            shared_data_categories: m.shared_data_categories || []
        }));

        return {
            id: family.id,
            name: family.name,
            status: family.status,
            members: formattedMembers,
            transaction_confirmation_threshold: Number(family.transaction_confirmation_threshold || 0),
            created_at: family.created_at
        };
    }

    // GET /family
    static async getActiveFamily(userId) {
        const { data: member } = await supabase
            .from('family_members')
            .select('family_id')
            .eq('user_id', userId)
            .maybeSingle();

        if (!member) return null;
        return await this.getFormattedFamilySpace(member.family_id);
    }

    // GET /family/invitations (TAMBAHAN METHOD YANG KURANG DI CONTROLLER)
    static async getActiveInvitations(userId) {
        const { data: invitations, error } = await supabase
            .from('family_invitations')
            .select('*')
            .eq('sender_user_id', userId)
            .eq('status', 'pending')
            .gt('expires_at', new Date().toISOString());

        if (error) throw error;
        return invitations || [];
    }

    // POST /family/invitations (BUAT UNDANGAN)
    static async createInvitation(userId, expiresInHours = 24) {
        let familyId;
        const existingFamily = await this.getActiveFamily(userId);

        if (existingFamily) {
            if (existingFamily.members.length >= 2) {
                const error = new Error('Ruang keluarga kamu sudah penuh (maksimal 2 anggota).');
                error.statusCode = 400;
                throw error;
            }
            familyId = existingFamily.id;
        } else {
            // 1. Buat ruang keluarga baru
            const { data: newFamily, error: famError } = await supabase
                .from('family_spaces')
                .insert({ name: 'Keluarga Saya', status: 'pending_pairing' })
                .select()
                .single();

            if (famError) throw famError;
            familyId = newFamily.id;

            // 2. Tambahkan pembuat ke anggota keluarga
            const { error: memError } = await supabase.from('family_members').insert({
                family_id: familyId,
                user_id: userId,
                consent_status: 'accepted',
                shared_data_categories: this.DEFAULT_SHARED_CATEGORIES
            });

            if (memError) {
                // Cleanup jika insert member gagal
                await supabase.from('family_spaces').delete().eq('id', familyId);
                throw memError;
            }

            // Update user profile
            await supabase.from('users').update({ family_id: familyId }).eq('id', userId);
        }

        // 3. Cek apakah ada undangan pending yang masih berlaku
        const { data: activeInv } = await supabase
            .from('family_invitations')
            .select('*')
            .eq('family_id', familyId)
            .eq('sender_user_id', userId)
            .eq('status', 'pending')
            .gt('expires_at', new Date().toISOString())
            .maybeSingle();

        if (activeInv) {
            return {
                id: activeInv.id,
                invite_code: activeInv.invite_code,
                sender_user_id: activeInv.sender_user_id,
                status: activeInv.status,
                expires_at: activeInv.expires_at,
                created_at: activeInv.created_at
            };
        }

        // 4. Jika belum ada, buat kode baru
        const inviteCode = 'FAM-' + crypto.randomBytes(3).toString('hex').toUpperCase();
        const expiresAt = new Date(Date.now() + expiresInHours * 3600 * 1000).toISOString();

        const { data: invitation, error: invError } = await supabase
            .from('family_invitations')
            .insert({
                family_id: familyId,
                invite_code: inviteCode,
                sender_user_id: userId,
                status: 'pending',
                expires_at: expiresAt
            })
            .select()
            .single();

        if (invError) throw invError;

        return {
            id: invitation.id,
            invite_code: invitation.invite_code,
            sender_user_id: invitation.sender_user_id,
            status: invitation.status,
            expires_at: invitation.expires_at,
            created_at: invitation.created_at
        };
    }

    // POST /family/invitations/:code/accept
    static async acceptInvitation(userId, inviteCode, consentVersion, sharedCategories) {
        // Cek apakah user penerima sudah tergabung di keluarga lain
        const userExistingFamily = await this.getActiveFamily(userId);
        if (userExistingFamily) {
            const error = new Error('Anda sudah bergabung dalam sebuah ruang keluarga.');
            error.statusCode = 400;
            throw error;
        }

        // 1. Cari kode undangan (case insensitive)
        const { data: invitation, error: fetchError } = await supabase
            .from('family_invitations')
            .select('*')
            .ilike('invite_code', inviteCode.trim())
            .maybeSingle();

        if (fetchError || !invitation) {
            const error = new Error('Kode undangan tidak ditemukan.');
            error.statusCode = 404;
            throw error;
        }

        if (invitation.status !== 'pending') {
            const error = new Error('Kode undangan ini sudah pernah digunakan atau tidak berlaku lagi.');
            error.statusCode = 400;
            throw error;
        }

        if (new Date(invitation.expires_at) < new Date()) {
            const error = new Error('Kode undangan ini sudah kadaluwarsa.');
            error.statusCode = 400;
            throw error;
        }

        if (invitation.sender_user_id === userId) {
            const error = new Error('Kamu tidak bisa menggunakan kode undangan yang kamu buat sendiri.');
            error.statusCode = 400;
            throw error;
        }

        // 2. Cek batasan maksimal 2 anggota
        const { data: members } = await supabase
            .from('family_members')
            .select('id')
            .eq('family_id', invitation.family_id);

        if (members && members.length >= 2) {
            const error = new Error('Ruang keluarga ini sudah penuh (maksimal 2 anggota).');
            error.statusCode = 400;
            throw error;
        }

        // 3. Masukkan Pasangan ke family_members
        const finalCategories = (sharedCategories && sharedCategories.length > 0) 
            ? sharedCategories 
            : this.DEFAULT_SHARED_CATEGORIES;

        const { error: joinError } = await supabase
            .from('family_members')
            .insert({
                family_id: invitation.family_id,
                user_id: userId,
                consent_status: 'accepted',
                shared_data_categories: finalCategories
            });

        if (joinError) throw joinError;

        // 4. Update status & konsen
        await supabase
            .from('users')
            .update({ family_id: invitation.family_id, consent_version: consentVersion })
            .eq('id', userId);

        await supabase
            .from('family_invitations')
            .update({ status: 'accepted' })
            .eq('id', invitation.id);

        await supabase
            .from('family_spaces')
            .update({ status: 'active' })
            .eq('id', invitation.family_id);

        return await this.getFormattedFamilySpace(invitation.family_id);
    }

    // POST /family/invitations/{invite_code}/reject
    static async rejectInvitation(inviteCode) {
        const { data: invitation, error } = await supabase
            .from('family_invitations')
            .update({ status: 'rejected' })
            .ilike('invite_code', inviteCode.trim())
            .select()
            .single();

        if (error || !invitation) {
            const err = new Error('Kode undangan tidak ditemukan.');
            err.statusCode = 404;
            throw err;
        }

        return {
            id: invitation.id,
            invite_code: invitation.invite_code,
            sender_user_id: invitation.sender_user_id,
            status: invitation.status,
            expires_at: invitation.expires_at,
            created_at: invitation.created_at
        };
    }

    // DELETE /family/invitations/{invitation_id}
    static async revokeInvitation(invitationId, userId) {
        const { error } = await supabase
            .from('family_invitations')
            .update({ status: 'revoked' })
            .eq('id', invitationId)
            .eq('sender_user_id', userId);

        if (error) throw error;
    }

    // PATCH /family/settings
    static async updateSettings(familyId, settingsData) {
        const payload = {};
        if (settingsData.name !== undefined) payload.name = settingsData.name.trim();
        if (settingsData.transaction_confirmation_threshold !== undefined) {
            payload.transaction_confirmation_threshold = settingsData.transaction_confirmation_threshold;
        }

        const { error } = await supabase
            .from('family_spaces')
            .update(payload)
            .eq('id', familyId);

        if (error) throw error;
        return await this.getFormattedFamilySpace(familyId);
    }

    // POST /family/consents
    static async updateConsent(userId, familyId, consentVersion, sharedDataCategories, accepted) {
        const consentStatus = accepted ? 'accepted' : 'revoked';

        const { error: memberError } = await supabase
            .from('family_members')
            .update({
                consent_status: consentStatus,
                shared_data_categories: sharedDataCategories
            })
            .eq('user_id', userId)
            .eq('family_id', familyId);

        if (memberError) throw memberError;

        await supabase.from('users').update({ consent_version: consentVersion }).eq('id', userId);

        return await this.getFormattedFamilySpace(familyId);
    }

    // POST /family/disconnect
    static async disconnectFamily(userId, familyId, password) {
    // 1. Verifikasi Email User
    const { data: user, error: userError } = await supabase
        .from('users')
        .select('email')
        .eq('id', userId)
        .single();

    if (userError || !user) {
        const err = new Error('Pengguna tidak ditemukan.');
        err.statusCode = 404;
        throw err;
    }

    // 2. Verifikasi Password User via Supabase Auth
    const { error: authError } = await supabase.auth.signInWithPassword({
        email: user.email,
        password: password
    });

    if (authError) {
        const err = new Error('Kata sandi salah.');
        err.statusCode = 401;
        throw err;
    }

    // -------------------------------------------------------------
    // PROSES PEMBERSIHAN & PENGHAPUSAN BERURUTAN (CLEANUP)
    // -------------------------------------------------------------

    // A. Lepas referensi family_id dari tabel users (Set NULL)
    // Ini wajib dilakukan pertama agar Foreign Key di `users` tidak menahan penghapusan `family_spaces`.
    const { error: clearUserFamilyErr } = await supabase
        .from('users')
        .update({ family_id: null })
        .eq('family_id', familyId);

    if (clearUserFamilyErr) throw clearUserFamilyErr;

    // B. Hapus riwayat undangan di family_invitations (Child Table)
    const { error: deleteInvitationsErr } = await supabase
        .from('family_invitations')
        .delete()
        .eq('family_id', familyId);

    if (deleteInvitationsErr) throw deleteInvitationsErr;

    // C. Hapus anggota keluarga di family_members (Child Table)
    const { error: deleteMembersErr } = await supabase
        .from('family_members')
        .delete()
        .eq('family_id', familyId);

    if (deleteMembersErr) throw deleteMembersErr;

    // E. Hapus Induk Tabel: family_spaces (Parent Table)
    const { error: deleteFamilySpaceErr } = await supabase
        .from('family_spaces')
        .delete()
        .eq('id', familyId);

    if (deleteFamilySpaceErr) throw deleteFamilySpaceErr;

    return { status: 'disconnected', message: 'Family space dan seluruh keanggotaan berhasil dihapus.' };
}
}

module.exports = FamilyService;