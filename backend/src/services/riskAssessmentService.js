// src/services/riskAssessmentService.js

const supabase = require('../config/supabaseClient');
const { getFullFamilyHealthSummary } = require('../utils/summaryAggregator');
const { assessFamilyRisk } = require('../utils/riskEngine');

/**
 * Memproses dan menyimpan asesmen risiko kesehatan keluarga
 * 
 * @param {string} familyId - UUID dari keluarga
 * @param {string} checkinId - (Optional) UUID dari weekly_check_in yang relevan
 * @param {string} assessmentWeek - Format minggu ISO, contoh: '2026-W32'
 */
const evaluateAndSaveFamilyRisk = async (familyId, checkinId = null, assessmentWeek = '2026-W32') => {
  try {
    // -------------------------------------------------------------
    // LANGKAH 1: Ambil Histori Asesmen Sebelumnya (untuk Hysteresis & Tren)
    // -------------------------------------------------------------
    const { data: previousAssessments, error: fetchError } = await supabase
      .from('family_assessments')
      .select('risk_level, risk_score, generated_at, assessment_week')
      .eq('family_id', familyId)
      .order('generated_at', { ascending: true })
      .limit(4); // Cukup mengambil 2-4 asesmen terakhir

    if (fetchError) {
      console.warn('[RiskService] Gagal mengambil histori asesmen:', fetchError.message);
    }

    // -------------------------------------------------------------
    // LANGKAH 2: Ambil Summary Data Mentah Lengkap
    // -------------------------------------------------------------
    const rawSummary = await getFullFamilyHealthSummary(familyId);

    // -------------------------------------------------------------
    // LANGKAH 3: Jalankan Engine Kalkulasi Model 2
    // -------------------------------------------------------------
    const assessmentResult = assessFamilyRisk(
      rawSummary,
      previousAssessments || [],
      familyId,
      assessmentWeek
    );

    // -------------------------------------------------------------
    // LANGKAH 4: Simpan / Upsert Hasil Asesmen ke Database
    // -------------------------------------------------------------
    const payloadToInsert = {
      family_id: familyId,
      checkin_id: checkinId,
      assessment_week: assessmentResult.assessment_week,
      assessment_status: assessmentResult.assessment_status,
      risk_level: assessmentResult.risk_level,
      risk_score: assessmentResult.risk_score,
      trend: assessmentResult.trend,
      domain_scores: assessmentResult.domain_scores,
      domain_trends: assessmentResult.domain_trends,
      top_factors: assessmentResult.top_factors,
      recommended_action: assessmentResult.recommended_action,
      safety_override: assessmentResult.safety_override,
      data_quality_score: assessmentResult.data_quality_score,
      rules_version: assessmentResult.rules_version,
      generated_at: assessmentResult.generated_at
    };

    const { data: savedAssessment, error: insertError } = await supabase
  .from('family_assessments')
  .upsert(payloadToInsert, { onConflict: 'checkin_id' }) 
  .select()
  .single();

    if (insertError) {
      console.error('[RiskService] Gagal menyimpan asesmen ke DB:', insertError);
      throw insertError;
    }

    return savedAssessment;

  } catch (error) {
    console.error('[RiskService Error] Gagal memproses asesmen risiko:', error);
    throw error;
  }
};

module.exports = { evaluateAndSaveFamilyRisk };