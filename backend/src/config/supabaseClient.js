require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
    throw new Error("SUPABASE_URL dan SUPABASE_SERVICE_ROLE_KEY harus diisi di .env!");
}

// Tambahkan opsi auth ini agar backend selalu konsisten memakai Service Role
const supabase = createClient(supabaseUrl, supabaseKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false, // Mencegah sesi klien tertimpa saat ada user login/register
        detectSessionInUrl: false
    }
});

module.exports = supabase;