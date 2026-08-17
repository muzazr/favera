/**
 * Pipeline Evaluasi Asesmen Kesehatan Keluarga
 */

// Pastikan import supabase sesuai dengan lokasi file di project Anda
const supabase = require('../config/supabaseClient'); 

const normalizeReverse5 = (val) => Math.max(0, Math.min(100, ((5 - (val ?? 3)) / 4) * 100));
const normalizeDirect5 = (val) => Math.max(0, Math.min(100, (((val ?? 1) - 1) / 4) * 100));

/**
 * Mengevaluasi Check-In terbaru berdasarkan Family ID
 * @param {string} familyId - UUID dari keluarga
 * @returns {object|null} Mengembalikan objek evaluasi atau null jika tidak ada data
 */
const evaluateCheckInPipeline = async (familyId) => {
  try {
    // ==========================================
    // FASE 1: FETCH DATA DARI DATABASE
    // ==========================================

    // 1. Ambil ID Check-In terbaru untuk family ini
    const { data: latestCheckIn, error: checkinError } = await supabase
      .from('weekly_check_ins')
      .select('id')
      .eq('family_id', familyId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (checkinError) throw new Error(`Gagal mengambil check-in: ${checkinError.message}`);
    
    // Jika belum ada checkin sama sekali
    if (!latestCheckIn) {
      return null; 
    }

    const checkinId = latestCheckIn.id;

    // 2. Ambil semua submissions untuk check-in tersebut
    const { data: submissions, error: submissionsError } = await supabase
      .from('check_in_submissions')
      .select('*')
      .eq('checkin_id', checkinId);

    if (submissionsError) throw new Error(`Gagal mengambil submissions: ${submissionsError.message}`);


    // 3. Ambil assessment minggu lalu untuk menghitung 'trend'
    const { data: previousAssessment } = await supabase
      .from('family_assessments')
      .select('breakdown')
      .eq('family_id', familyId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    // ==========================================
    // FASE 2: KALKULASI & EVALUASI
    // ==========================================

    const partnerData = {};
    const safetyAnswers = {
      feels_threatened: false,
      physical_violence_reported: false,
      self_harm_concern: false,
      harm_to_others_concern: false,
      immediate_emergency: false
    };

    const partnerScores = {};
    const submittedUsers = (submissions || []).filter(s => s.status === 'submitted');
    const submissionCount = submittedUsers.length;

    // 1. Ekstraksi Format Kunci JSON Tepat yang Diminta
    submittedUsers.forEach((sub, idx) => {
      const key = idx === 0 ? 'partner_a' : 'partner_b';
      const answersMap = {};
      (sub.answers || []).forEach(a => { answersMap[a.question_id] = a.value; });

      // Format Objek JSON Partner A / B
      partnerData[key] = {
        trust_score: answersMap['trust'] ?? 3,
        communication_safety_score: answersMap['comm_safety'] ?? 3,
        communication_quality_score: answersMap['comm_quality'] ?? 3,
        openness_score: answersMap['openness'] ?? 3,
        partner_support_score: answersMap['support'] ?? 3,
        relationship_progress_score: answersMap['rel_progress'] ?? 3,
        stress_score: answersMap['stress'] ?? 1,
        anxiety_score: answersMap['anxiety'] ?? 1,
        anger_score: answersMap['anger'] ?? 0,
        hopelessness_score: answersMap['hopelessness'] ?? 0,
        social_withdrawal_score: answersMap['withdrawal'] ?? 0,
        conflict_days_7d: answersMap['conflict_days'] ?? 0
      };

      // Hitung Skor Strain Internal
      const relStrainScore = Math.round(
        (normalizeReverse5(partnerData[key].trust_score) * 0.20) +
        (normalizeReverse5(partnerData[key].communication_safety_score) * 0.20) +
        (normalizeReverse5(partnerData[key].communication_quality_score) * 0.15) +
        (normalizeReverse5(partnerData[key].openness_score) * 0.15) +
        (normalizeReverse5(partnerData[key].partner_support_score) * 0.15) +
        (normalizeReverse5(partnerData[key].relationship_progress_score) * 0.05) +
        (((partnerData[key].conflict_days_7d / 7) * 100) * 0.10)
      );

      const emoStrainScore = Math.round(
        (normalizeDirect5(partnerData[key].stress_score) * 0.25) +
        (normalizeDirect5(partnerData[key].anxiety_score) * 0.25) +
        (normalizeDirect5(partnerData[key].anger_score) * 0.20) +
        (normalizeDirect5(partnerData[key].hopelessness_score) * 0.15) +
        (normalizeDirect5(partnerData[key].social_withdrawal_score) * 0.15)
      );

      partnerScores[key] = { relStrainScore, emoStrainScore };

      // Evaluation Safety Answers
      if (answersMap['feels_threatened'] === true) safetyAnswers.feels_threatened = true;
      if (answersMap['physical_violence'] === true) safetyAnswers.physical_violence_reported = true;
      if (answersMap['self_harm'] === true) safetyAnswers.self_harm_concern = true;
      if (answersMap['harm_others'] === true) safetyAnswers.harm_to_others_concern = true;
      if (answersMap['emergency'] === true) safetyAnswers.immediate_emergency = true;
    });

    // 2. Evaluasi Sinyal Keselamatan (Critical Override)
    const isSafetyTriggered = Object.values(safetyAnswers).some(Boolean);

    if (isSafetyTriggered) {
      return {
        checkin_id: checkinId, // Tambahan agar ID checkin bisa dipakai di luar
        level: 'safety_support_required',
        trend: 'worsening',
        safety_override: true,
        domain_levels: {
          financial_harm: 'high',
          relationship_strain: 'high',
          emotional_strain: 'high',
          recovery_adherence: 'low'
        },
        main_factors: [
          {
            code: 'SAFETY_CRITICAL_SIGNAL',
            title: 'Bahaya Keselamatan Terdeteksi',
            description: 'Terdeteksi indikasi yang mengancam keselamatan fisik atau emosional.'
          }
        ],
        recommended_actions: [
          {
            code: 'SAFETY_HOTLINE',
            label: 'Hubungi Bantuan Darurat',
            route: '/emergency',
            priority: 'urgent'
          }
        ],
        breakdown: {
          submission_count: submissionCount,
          partner_checkins: {
            partner_a: partnerData.partner_a || null,
            partner_b: partnerData.partner_b || null
          },
          safety_answers: safetyAnswers
        }
      };
    }

    // 3. Kalkulasi Skor Terintegrasi
    let finalRelStrain = 0;
    let finalEmoStrain = 0;
    let perceptionDisparity = 0;
    const mainFactors = [];
    const recommendedActions = [];

    if (submissionCount === 2) {
      const sA = partnerScores.partner_a;
      const sB = partnerScores.partner_b;

      perceptionDisparity = Math.abs(sA.relStrainScore - sB.relStrainScore);
      finalRelStrain = Math.round(((sA.relStrainScore + sB.relStrainScore) / 2) + (perceptionDisparity * 0.15));
      finalEmoStrain = Math.round((sA.emoStrainScore + sB.emoStrainScore) / 2);

      if (perceptionDisparity >= 25) {
        mainFactors.push({
          code: 'HIGH_PERCEPTION_GAP',
          title: 'Kesenjangan Persepsi Tinggi',
          description: `Terdapat perbedaan sudut pandang sebesar ${perceptionDisparity}% mengenai kondisi hubungan.`
        });
        recommendedActions.push({
          code: 'ALIGNMENT_DIALOGUE',
          label: 'Jadwalkan Diskusi Terbuka',
          route: '/guidance/perception-gap',
          priority: 'high'
        });
      } else {
        mainFactors.push({
          code: 'BALANCED_PERCEPTION',
          title: 'Persepsi Harmonis',
          description: 'Kedua pasangan memiliki pandangan yang sejalan terhadap kondisi hubungan.'
        });
      }
    } else if (submissionCount === 1) {
      const sA = partnerScores.partner_a;
      finalRelStrain = Math.min(100, sA.relStrainScore + 20);
      finalEmoStrain = Math.min(100, sA.emoStrainScore + 15);

      mainFactors.push({
        code: 'PARTNER_MISSED_CHECKIN',
        title: 'Salah Satu Pasangan Absen',
        description: 'Hanya satu pasangan yang mengisi check-in minggu ini.'
      });
      recommendedActions.push({
        code: 'REMIND_PARTNER',
        label: 'Ingatkan Pasangan Mengisi Check-In',
        route: '/check-ins',
        priority: 'high'
      });
    } else {
      finalRelStrain = 75;
      finalEmoStrain = 65;

      mainFactors.push({
        code: 'BOTH_MISSED_CHECKIN',
        title: 'Check-In Dilewatkan',
        description: 'Kedua pasangan tidak mengisi check-in minggu ini.'
      });
    }

    // 4. Penentuan Level Kategori
    let overallLevel = 'stable';
    if (finalRelStrain >= 65 || finalEmoStrain >= 70 || submissionCount === 0) {
      overallLevel = 'intensive_support_recommended';
    } else if (finalRelStrain >= 40 || finalEmoStrain >= 45 || submissionCount === 1) {
      overallLevel = 'needs_attention';
    }

    const getDomainRating = (score) => score >= 60 ? 'high' : score >= 35 ? 'medium' : 'low';

    // 5. Trend Calculation (menggunakan previousAssessment dari database)
    let trend = 'stable';
    if (!previousAssessment) {
      trend = 'insufficient_data';
    } else if (previousAssessment.breakdown?.overall_strain_score) {
      const prevScore = previousAssessment.breakdown.overall_strain_score;
      const currentScore = Math.round((finalRelStrain + finalEmoStrain) / 2);
      const diff = currentScore - prevScore;

      if (diff <= -8) trend = 'improving';
      else if (diff >= 8) trend = 'worsening';
    }

    if (recommendedActions.length === 0) {
      recommendedActions.push({
        code: 'MAINTAIN_ROUTINE',
        label: 'Pertahankan Rutinitas Positif',
        route: '/check-ins',
        priority: 'low'
      });
    }

    // Output Breakdown Akhir
    return {
      checkin_id: checkinId, // Tambahan ID check-in
      level: overallLevel,
      trend,
      safety_override: false,
      domain_levels: {
        financial_harm: 'low',
        relationship_strain: getDomainRating(finalRelStrain),
        emotional_strain: getDomainRating(finalEmoStrain),
        recovery_adherence: submissionCount === 2 ? 'high' : submissionCount === 1 ? 'medium' : 'low'
      },
      main_factors: mainFactors,
      recommended_actions: recommendedActions,
      breakdown: {
        submission_count: submissionCount,
        overall_strain_score: Math.round((finalRelStrain + finalEmoStrain) / 2),
        partner_checkins: {
          partner_a: partnerData.partner_a || null,
          partner_b: partnerData.partner_b || null
        },
        safety_answers: safetyAnswers
      }
    };

  } catch (error) {
    console.error('[Pipeline Error] Gagal memproses data asesmen:', error);
    throw error;
  }
};

module.exports = { evaluateCheckInPipeline };