// src/utils/assessmentMapper.js

const mapRiskLevel = (dbLevel) => {
  const levelMap = {
    'STABLE': 'stable',
    'NEEDS_ATTENTION': 'needs_attention',
    'INTENSIVE_SUPPORT_RECOMMENDED': 'intensive_support_recommended',
    'SAFETY_SUPPORT_REQUIRED': 'safety_support_required'
  };
  return levelMap[dbLevel?.toUpperCase()] || 'stable';
};

const mapTrend = (dbTrend) => {
  const trendMap = {
    'IMPROVING_TREND': 'improving',
    'STABLE_TREND': 'stable',
    'WORSENING_TREND': 'worsening',
    'INSUFFICIENT_DATA': 'insufficient_data'
  };
  return trendMap[dbTrend?.toUpperCase()] || 'stable';
};

/**
 * Konversi skor angka ke level kategorikal (low/moderate/high)
 */
const mapScoreToLevel = (score, isInverted = false) => {
  const num = parseFloat(score);
  if (isNaN(num)) return isInverted ? 'high' : 'low';

  let level = 'low';
  if (num <= 3.33) level = 'low';
  else if (num <= 6.66) level = 'moderate';
  else level = 'high';

  if (isInverted) {
    if (level === 'low') return 'high';
    if (level === 'high') return 'low';
    return 'moderate';
  }

  return level;
};

// Helper aman untuk parse JSON tanpa membuat server crash
const safeJsonParse = (data, fallback) => {
  if (!data) return fallback;
  if (typeof data === 'object') return data;
  try {
    return JSON.parse(data);
  } catch (e) {
    return fallback;
  }
};

/**
 * Validasi Enum Domain sesuai API Contract Schema
 */
const mapDomainEnum = (domain) => {
  const validDomains = [
    'financial_harm',
    'relationship_strain',
    'emotional_strain',
    'recovery_adherence',
    'safety'
  ];

  if (!domain) return 'relationship_strain';

  const lower = String(domain).toLowerCase();
  if (lower === 'recovery_nonadherence') return 'recovery_adherence';
  if (validDomains.includes(lower)) return lower;

  return 'relationship_strain';
};

/**
 * Validasi Enum Direction sesuai API Contract Schema
 */
const mapDirectionEnum = (direction) => {
  const lower = String(direction).toLowerCase();
  if (lower === 'protective') return 'protective';
  return 'risk';
};

/**
 * Menjamin objek item sesuai dengan skema OpenAPI `AssessmentFactor`
 */
const transformAssessmentFactor = (factor) => {
  if (typeof factor === 'string') {
    const formattedCode = factor.toUpperCase();
    return {
      code: formattedCode,
      label: factor.replace(/_/g, ' '),
      domain: 'relationship_strain',
      direction: 'risk',
      explanation: `Terdeteksi indikator risiko: ${factor.replace(/_/g, ' ')}.`
    };
  }

  const code = factor.code || 'UNKNOWN_FACTOR';
  const label = factor.label || code.replace(/_/g, ' ');
  const domain = mapDomainEnum(factor.domain);
  const direction = mapDirectionEnum(factor.direction);
  const explanation = factor.explanation || factor.message || `Terdeteksi indikator ${direction} pada domain ${domain.replace(/_/g, ' ')}.`;

  return {
    code,
    label,
    domain,
    direction,
    explanation
  };
};

/**
 * Menjamin objek item sesuai dengan skema OpenAPI `Action`
 */
const transformAction = (action) => {
  if (typeof action === 'string') {
    return {
      code: action,
      label: action.replace(/_/g, ' '),
      route: null,
      priority: 'low'
    };
  }

  const validPriorities = ['low', 'medium', 'high', 'urgent'];
  const priority = validPriorities.includes(action.priority?.toLowerCase())
    ? action.priority.toLowerCase()
    : 'low';

  return {
    code: action.code || 'CONTINUE_WEEKLY_CHECKIN',
    label: action.label || (action.code ? action.code.replace(/_/g, ' ') : 'Lanjutkan Check-in Mingguan'),
    route: action.route ?? null,
    priority
  };
};

/**
 * Mengubah DB Row family_assessments ke DTO FamilyAssessment Schema
 */
const transformToFamilyAssessmentDTO = (dbRow) => {
  if (!dbRow) return null;

  const scores = safeJsonParse(dbRow.domain_scores, {});
  let rawActions = safeJsonParse(dbRow.recommended_actions, []);
  let rawTopFactors = safeJsonParse(dbRow.top_factors, []);

  const mappedLevel = mapRiskLevel(dbRow.risk_level);

  // 1. Transformasi main_factors dari database
  let mainFactors = Array.isArray(rawTopFactors)
    ? rawTopFactors.map(transformAssessmentFactor)
    : [];

  // FALLBACK: Jika main_factors kosong di DB (karena kondisi stabil/aman),
  // buatkan Protective Factor bawaan agar sesuai Contract API
  if (mainFactors.length === 0) {
    if (mappedLevel === 'stable') {
      mainFactors.push({
        code: 'STABLE_CHECKIN_STATUS',
        label: 'Kondisi Keluarga & Check-in Stabil',
        domain: 'relationship_strain',
        direction: 'protective',
        explanation: 'Tidak terdeteksi indikator risiko kritis pada asesmen minggu ini.'
      });
    } else {
      mainFactors.push({
        code: 'GENERAL_ASSESSMENT_MONITORING',
        label: 'Pantauan Asesmen Rutin',
        domain: 'relationship_strain',
        direction: 'risk',
        explanation: 'Indikator berada dalam batas pemantauan tanpa faktor risiko dominan tunggal.'
      });
    }
  }

  // 2. Transformasi recommended_actions
  if (Array.isArray(rawActions) && rawActions.length === 0 && dbRow.recommended_action) {
    rawActions = [dbRow.recommended_action];
  }

  const recommendedActions = Array.isArray(rawActions)
    ? rawActions.map(transformAction)
    : [];

  return {
    id: dbRow.id,
    family_id: dbRow.family_id,
    checkin_id: dbRow.checkin_id || null,
    assessment_version: dbRow.rules_version || 'v1.0',
    level: mappedLevel,
    trend: mapTrend(dbRow.trend),
    domain_levels: {
      financial_harm: mapScoreToLevel(scores.financial_harm),
      relationship_strain: mapScoreToLevel(scores.relationship_strain),
      emotional_strain: mapScoreToLevel(scores.emotional_strain),
      recovery_adherence: mapScoreToLevel(scores.recovery_nonadherence ?? scores.recovery_adherence, true)
    },
    main_factors: mainFactors,
    recommended_actions: recommendedActions,
    safety_override: Boolean(dbRow.safety_override),
    generated_at: dbRow.generated_at
  };
};

module.exports = { transformToFamilyAssessmentDTO };