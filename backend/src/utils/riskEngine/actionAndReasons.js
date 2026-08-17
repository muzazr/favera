// src/utils/riskEngine/actionAndReasons.js

/**
 * Memilih maksimal 3 top factors dan menentukan action_code (Section 14 & 15)
 */
function selectTopFactorsAndAction(safetyResult, hardRules, domainReasons, finalLevel, overallTrend, domainScores) {
  // 1. Kumpulkan semua reason
  const allReasons = [];

  // Urutan prioritas: 1. Safety > 2. Hard Escalation > 3. Domain Reasons
  safetyResult.reasons.forEach(r => allReasons.push({ ...r, priority: 1 }));
  hardRules.reasons.forEach(r => allReasons.push({ ...r, priority: 2 }));

  Object.values(domainReasons).flatMap(rList => rList).forEach(r => {
    allReasons.push({ ...r, priority: 3 });
  });

  // Urutkan berdasarkan priority, lalu severity terbesar
  allReasons.sort((a, b) => {
    if (a.priority !== b.priority) return a.priority - b.priority;
    return (b.severity || 0) - (a.severity || 0);
  });

  // Ambil maksimal 3 top factors
  const topFactors = allReasons.slice(0, 3).map(r => ({
    code: r.code,
    observed_value: r.observed_value ?? 0,
    unit: r.unit || 'ratio',
    severity: r.severity || 0
  }));

  // 2. Pemetaan Action Code (Section 15)
  let recommendedAction = 'CONTINUE_WEEKLY_CHECKIN';

  if (safetyResult.triggered) {
    recommendedAction = 'SAFETY_AND_PROFESSIONAL_REFERRAL';
  } else if (finalLevel === 'INTENSIVE_SUPPORT') {
    recommendedAction = 'EXTERNAL_MEDIATION_OR_COUNSELING';
  } else if (domainScores.financial_harm >= 60) {
    recommendedAction = 'FINANCIAL_RECONCILIATION';
  } else if (domainScores.relationship_strain >= 50) {
    recommendedAction = 'GUIDED_CONVERSATION';
  } else if (domainScores.recovery_nonadherence >= 50) {
    recommendedAction = 'REVIEW_COMMITMENTS';
  } else if (finalLevel === 'ATTENTION') {
    recommendedAction = 'SCHEDULE_PROFESSIONAL_SUPPORT';
  }

  return {
    topFactors,
    recommendedAction
  };
}

module.exports = { selectTopFactorsAndAction };