// src/utils/riskEngine/hardEscalations.js

/**
 * Mengevaluasi Hard Rules setelah scorecards (Section 10)
 */
function evaluateHardEscalations(input, derivedObj, domainScores) {
  const { derived } = derivedObj;
  const { financial_snapshot = {}, recovery_commitments = {} } = input;
  const pAvg = derived.partnerAvg;

  let requiredLevel = null; // 'INTENSIVE_SUPPORT' atau 'ATTENTION'
  const hardReasons = [];

  // A. Financial Escalation (10.2)
  if (financial_snapshot.basic_needs_unmet && derived.essential_budget_gap_ratio > 0.20) {
    requiredLevel = 'INTENSIVE_SUPPORT';
    hardReasons.push({ code: 'ESC_FIN_01', domain: 'financial', severity: 100 });
  }
  if (derived.debt_service_ratio >= 0.60) {
    requiredLevel = 'INTENSIVE_SUPPORT';
    hardReasons.push({ code: 'ESC_FIN_02', domain: 'financial', severity: 100 });
  }
  if (financial_snapshot.asset_sold_or_pawned && derived.debt_growth_ratio_28d > 0.15) {
    requiredLevel = 'INTENSIVE_SUPPORT';
    hardReasons.push({ code: 'ESC_FIN_03', domain: 'financial', severity: 100 });
  }
  if (domainScores.financial_harm >= 80) {
    requiredLevel = 'INTENSIVE_SUPPORT';
    hardReasons.push({ code: 'ESC_FIN_05', domain: 'financial', severity: 100 });
  }

  // B. Relationship Escalation (10.3)
  const commSafety = pAvg('communication_safety_score');
  if (commSafety === 0) {
    requiredLevel = 'INTENSIVE_SUPPORT';
    hardReasons.push({ code: 'ESC_REL_01', domain: 'relationship', severity: 100 });
  }
  if (domainScores.relationship_strain >= 80) {
    requiredLevel = 'INTENSIVE_SUPPORT';
    hardReasons.push({ code: 'ESC_REL_04', domain: 'relationship', severity: 100 });
  }

  // C. Emotional Escalation (10.4)
  if (domainScores.emotional_strain >= 80) {
    requiredLevel = 'INTENSIVE_SUPPORT';
    hardReasons.push({ code: 'ESC_EMO_03', domain: 'emotional', severity: 100 });
  }

  return {
    triggered: hardReasons.length > 0,
    requiredLevel,
    reasons: hardReasons
  };
}

module.exports = { evaluateHardEscalations };