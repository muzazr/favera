const supabase = require('../config/supabaseClient'); // Sesuaikan path dengan inisiasi supabase Anda

/**
 * Mengambil ringkasan recovery commitments untuk sebuah keluarga (7 hari terakhir)
 * @param {string} familyId - UUID dari tabel family_spaces
 * @returns {Promise<Object>} Object JSON berisi metrik recovery
 */
const getRecoveryCommitmentsSummary = async (familyId) => {
  try {
    // Memanggil PostgreSQL function menggunakan .rpc()
    const { data, error } = await supabase
      .rpc('get_recovery_commitments_summary', { 
        p_family_id: familyId 
      });

    if (error) throw error;
    
    return data; // Langsung mengembalikan bentuk JSON object
  } catch (err) {
    console.error('Gagal mengambil Recovery Commitments Summary:', err.message);
    // Kembalikan default fallback value jika terjadi error agar aplikasi tidak crash
    return {
      recovery_commitments: {
        commitment_total_7d: 0,
        commitment_completed_7d: 0,
        checkin_completed_a: false,
        checkin_completed_b: false,
        missed_checkin_streak: 0,
        mediation_followup_required: false,
        mediation_followup_completed: false,
        help_seeking_status: "none",
        concerning_event_recurrence_7d: 0,
        positive_activity_days_7d: 0
      }
    };
  }
};

module.exports = {
  getRecoveryCommitmentsSummary
};