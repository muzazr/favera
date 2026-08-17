// src/utils/summaryAggregator.js

// Import Supabase Client (Diperlukan untuk financialPipeline)
const supabase = require('../config/supabaseClient');

// Import keempat fungsi pipeline (semua berada di folder utils yang sama)
const { generateModel1Summary } = require('./anomalyPipeline');
const { evaluateCheckInPipeline } = require('./assessmentPipeline');
const { generateFinancialSnapshot } = require('./financialPipeline');
const { getRecoveryCommitmentsSummary } = require('./recoveryMetrics');

/**
 * Agregasi seluruh data pipeline menjadi satu format JSON lengkap
 * @param {string} familyId - UUID dari keluarga
 * @returns {Promise<Object>} Object JSON gabungan
 */
const getFullFamilyHealthSummary = async (familyId) => {
  try {
    // Jalankan ke-4 fungsi pipeline secara paralel demi efisiensi performa
    const [
      model1Summary,
      financialSnapshot,
      assessmentResult,
      recoveryData
    ] = await Promise.all([
      generateModel1Summary(familyId),
      generateFinancialSnapshot(familyId, supabase),
      evaluateCheckInPipeline(familyId),
      getRecoveryCommitmentsSummary(familyId)
    ]);

    // 1. Ekstraksi partner_checkins & safety_answers dari hasil assessmentPipeline
    const partnerCheckins = assessmentResult?.breakdown?.partner_checkins || {
      partner_a: null,
      partner_b: null
    };

    const safetyAnswers = assessmentResult?.breakdown?.safety_answers || {
      feels_threatened: false,
      physical_violence_reported: false,
      self_harm_concern: false,
      harm_to_others_concern: false,
      immediate_emergency: false
    };

    // 2. Ekstraksi recovery_commitments (menangani kasus jika di-return sebagai wrapper object atau direct object)
    const recoveryCommitments = recoveryData?.recovery_commitments 
      ? recoveryData.recovery_commitments 
      : recoveryData;

    // 3. Susun sesuai dengan format JSON target yang diminta
    const combinedSummary = {
      model1_summary: model1Summary,
      financial_snapshot: financialSnapshot,
      partner_checkins: partnerCheckins,
      recovery_commitments: recoveryCommitments,
      safety_answers: safetyAnswers
    };

    return combinedSummary;

  } catch (error) {
    console.error('[Aggregator Error] Gagal menggabungkan data summary:', error);
    throw error;
  }
};

module.exports = { getFullFamilyHealthSummary };