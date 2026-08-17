// src/services/userService.js
const supabase = require('../config/supabaseClient');

class UserService {
    /**
     * Helper untuk memformat objek user agar tepat sesuai skema "User" di API Contract
     */
    static formatUserResponse(user) {
        return {
            id: user.id,
            display_name: user.display_name,
            email: user.email,
            avatar_url: user.avatar_url || null,
            onboarding_completed: Boolean(user.onboarding_completed),
            family_id: user.family_id || null,
            created_at: user.created_at
        };
    }

    static async getUserById(userId) {
        const { data: user, error } = await supabase
            .from('users')
            .select('*')
            .eq('id', userId)
            .single();

        if (error || !user) throw new Error('Pengguna tidak ditemukan.');
        return this.formatUserResponse(user);
    }

    static async updateProfile(userId, updateData) {
        const payload = {};
        if (updateData.display_name !== undefined) payload.display_name = updateData.display_name;
        if (updateData.avatar_url !== undefined) payload.avatar_url = updateData.avatar_url;

        const { data: user, error } = await supabase
            .from('users')
            .update(payload)
            .eq('id', userId)
            .select()
            .single();

        if (error) throw error;
        return this.formatUserResponse(user);
    }

    static async completeOnboarding(userId, onboardingData) {
        const payload = {
            display_name: onboardingData.preferred_name, // Mengubah display_name menjadi preferred_name
            household_role: onboardingData.household_role || null,
            timezone: onboardingData.timezone || 'Asia/Jakarta',
            default_transaction_confirmation_threshold: onboardingData.default_transaction_confirmation_threshold !== undefined 
                ? onboardingData.default_transaction_confirmation_threshold 
                : 500000,
            consent_version: onboardingData.consent_version,
            onboarding_completed: true
        };

        const { data: user, error } = await supabase
            .from('users')
            .update(payload)
            .eq('id', userId)
            .select()
            .single();

        if (error) throw error;
        return this.formatUserResponse(user);
    }
}

module.exports = UserService;