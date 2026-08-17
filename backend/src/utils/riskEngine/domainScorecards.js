// src/utils/riskEngine/domainScorecards.js

function evaluateDomainScorecards(input, derivedObj) {
  const { derived } = derivedObj;
  const { financial_snapshot = {}, recovery_commitments = {} } = input;

  const finReasons = [];
  const relReasons = [];
  const emoReasons = [];
  const recReasons = [];

  // Helper Severity Converter (Section 8)
  const getSeverityFromBand = (val, thresholds) => {
    if (val <= thresholds[0]) return 0;
    if (val <= thresholds[1]) return 25;
    if (val <= thresholds[2]) return 50;
    if (val <= thresholds[3]) return 75;
    return 100;
  };

  // ---------------------------------------------------
  // A. FINANCIAL HARM SCORECARD (Section 8.1)
  // ---------------------------------------------------
  const finSeverities = [];

  // FIN_01: essential_budget_gap_ratio [0.05, 0.10, 0.20, 0.40]
  const fin01Sev = getSeverityFromBand(derived.essential_budget_gap_ratio, [0.05, 0.10, 0.20, 0.40]);
  finSeverities.push(fin01Sev);
  if (fin01Sev >= 50) {
    finReasons.push({ code: 'FIN_ESSENTIAL_BUDGET_GAP', domain: 'financial', severity: fin01Sev, observed_value: derived.essential_budget_gap_ratio, unit: 'ratio' });
  }

  // FIN_02: debt_service_ratio [0.20, 0.30, 0.40, 0.60]
  const fin02Sev = getSeverityFromBand(derived.debt_service_ratio, [0.199, 0.299, 0.399, 0.599]);
  finSeverities.push(fin02Sev);
  if (fin02Sev >= 50) {
    finReasons.push({ code: 'FIN_HIGH_DEBT_SERVICE', domain: 'financial', severity: fin02Sev, observed_value: derived.debt_service_ratio, unit: 'ratio' });
  }

  // FIN_03: debt_growth_ratio_28d [0, 0.05, 0.15, 0.30]
  const fin03Sev = getSeverityFromBand(derived.debt_growth_ratio_28d, [0, 0.05, 0.15, 0.30]);
  finSeverities.push(fin03Sev);
  if (fin03Sev >= 50) {
    finReasons.push({ code: 'FIN_DEBT_INCREASE', domain: 'financial', severity: fin03Sev, observed_value: derived.debt_growth_ratio_28d, unit: 'ratio' });
  }

  // FIN_04: savings_drawdown_ratio_28d [0.05, 0.10, 0.20, 0.40]
  const fin04Sev = getSeverityFromBand(derived.savings_drawdown_ratio_28d, [0.05, 0.10, 0.20, 0.40]);
  finSeverities.push(fin04Sev);
  if (fin04Sev >= 50) {
    finReasons.push({ code: 'FIN_SAVINGS_DRAWDOWN', domain: 'financial', severity: fin04Sev, observed_value: derived.savings_drawdown_ratio_28d, unit: 'ratio' });
  }

  // FIN_05: confirmed_unusual_value_ratio [0.02, 0.05, 0.10, 0.25]
  const fin05Sev = getSeverityFromBand(derived.confirmed_unusual_value_ratio, [0.02, 0.05, 0.10, 0.25]);
  finSeverities.push(fin05Sev);
  if (fin05Sev >= 50) {
    finReasons.push({ code: 'FIN_UNUSUAL_VALUE_HIGH', domain: 'financial', severity: fin05Sev, observed_value: derived.confirmed_unusual_value_ratio, unit: 'ratio' });
  }

  // FIN_08..11 Boolean flags
  if (financial_snapshot.basic_needs_unmet) {
    finSeverities.push(100);
    finReasons.push({ code: 'FIN_BASIC_NEEDS_UNMET', domain: 'financial', severity: 100, observed_value: true, unit: 'boolean' });
  }
  if (financial_snapshot.new_external_debt) {
    finSeverities.push(100);
    finReasons.push({ code: 'FIN_NEW_EXTERNAL_DEBT', domain: 'financial', severity: 100, observed_value: true, unit: 'boolean' });
  }
  if (financial_snapshot.asset_sold_or_pawned) {
    finSeverities.push(100);
    finReasons.push({ code: 'FIN_ASSET_SOLD_OR_PAWNED', domain: 'financial', severity: 100, observed_value: true, unit: 'boolean' });
  }
  if (financial_snapshot.financial_activity_concealed) {
    finSeverities.push(75);
    finReasons.push({ code: 'FIN_ACTIVITY_CONCEALED', domain: 'financial', severity: 75, observed_value: true, unit: 'boolean' });
  }

  const financial_harm = finSeverities.length > 0
    ? finSeverities.reduce((a, b) => a + b, 0) / finSeverities.length
    : 0;

  // ---------------------------------------------------
  // B. RELATIONSHIP STRAIN SCORECARD (Section 8.2)
  // ---------------------------------------------------
  const relSeverities = [];
  const pAvg = derived.partnerAvg;

  // Konstruk Positif (0..4): severity = (4 - score) * 25
  const trustScore = pAvg('trust_score');
  if (trustScore !== null) {
    const sev = (4 - trustScore) * 25;
    relSeverities.push(sev);
    if (sev >= 50) relReasons.push({ code: 'REL_LOW_TRUST', domain: 'relationship', severity: sev, observed_value: trustScore, unit: 'score_0_4' });
  }

  const commSafety = pAvg('communication_safety_score');
  if (commSafety !== null) {
    const sev = (4 - commSafety) * 25;
    relSeverities.push(sev);
    if (sev >= 50) relReasons.push({ code: 'REL_COMMUNICATION_UNSAFE', domain: 'relationship', severity: sev, observed_value: commSafety, unit: 'score_0_4' });
  }

  const commQuality = pAvg('communication_quality_score');
  if (commQuality !== null) {
    const sev = (4 - commQuality) * 25;
    relSeverities.push(sev);
    if (sev >= 50) relReasons.push({ code: 'REL_COMMUNICATION_LOW', domain: 'relationship', severity: sev, observed_value: commQuality, unit: 'score_0_4' });
  }

  const openness = pAvg('openness_score');
  if (openness !== null) {
    const sev = (4 - openness) * 25;
    relSeverities.push(sev);
    if (sev >= 50) relReasons.push({ code: 'REL_LOW_OPENNESS', domain: 'relationship', severity: sev, observed_value: openness, unit: 'score_0_4' });
  }

  // Conflict days
  const conflictDays = pAvg('conflict_days_7d');
  if (conflictDays !== null) {
    const sev = getSeverityFromBand(conflictDays, [0, 1, 2, 4]);
    relSeverities.push(sev);
    if (sev >= 50) relReasons.push({ code: 'REL_HIGH_CONFLICT_FREQUENCY', domain: 'relationship', severity: sev, observed_value: conflictDays, unit: 'days_per_7d' });
  }

  // Divergence
  if (derived.partner_divergence !== null) {
    const sev = getSeverityFromBand(derived.partner_divergence, [0.499, 0.999, 1.499, 1.999]);
    relSeverities.push(sev);
    if (sev >= 50) relReasons.push({ code: 'REL_HIGH_DIVERGENCE', domain: 'relationship', severity: sev, observed_value: derived.partner_divergence, unit: 'score_diff' });
  }

  const relationship_strain = relSeverities.length > 0
    ? relSeverities.reduce((a, b) => a + b, 0) / relSeverities.length
    : 0;

  // ---------------------------------------------------
  // C. EMOTIONAL STRAIN SCORECARD (Section 8.3)
  // ---------------------------------------------------
  const emoSeverities = [];
  // Konstruk Negatif (0..4): severity = score * 25
  const stress = pAvg('stress_score');
  if (stress !== null) {
    const sev = stress * 25;
    emoSeverities.push(sev);
    if (sev >= 50) emoReasons.push({ code: 'EMO_HIGH_STRESS', domain: 'emotional', severity: sev, observed_value: stress, unit: 'score_0_4' });
  }

  const anxiety = pAvg('anxiety_score');
  if (anxiety !== null) {
    const sev = anxiety * 25;
    emoSeverities.push(sev);
    if (sev >= 50) emoReasons.push({ code: 'EMO_HIGH_ANXIETY', domain: 'emotional', severity: sev, observed_value: anxiety, unit: 'score_0_4' });
  }

  const anger = pAvg('anger_score');
  if (anger !== null) {
    const sev = anger * 25;
    emoSeverities.push(sev);
    if (sev >= 50) emoReasons.push({ code: 'EMO_HIGH_ANGER', domain: 'emotional', severity: sev, observed_value: anger, unit: 'score_0_4' });
  }

  const hopelessness = pAvg('hopelessness_score');
  if (hopelessness !== null) {
    const sev = hopelessness * 25;
    emoSeverities.push(sev);
    if (sev >= 50) emoReasons.push({ code: 'EMO_HIGH_HOPELESSNESS', domain: 'emotional', severity: sev, observed_value: hopelessness, unit: 'score_0_4' });
  }

  const emotional_strain = emoSeverities.length > 0
    ? emoSeverities.reduce((a, b) => a + b, 0) / emoSeverities.length
    : 0;

  // ---------------------------------------------------
  // D. RECOVERY NON-ADHERENCE SCORECARD (Section 8.4)
  // ---------------------------------------------------
  const recSeverities = [];

  // REC_01: commitment completion ratio
  const commRatio = derived.commitment_completion_ratio;
  let commSev = 0;
  if (commRatio === 0) commSev = 100;
  else if (commRatio < 0.25) commSev = 75;
  else if (commRatio < 0.50) commSev = 50;
  else if (commRatio < 0.75) commSev = 25;
  recSeverities.push(commSev);
  if (commSev >= 50) recReasons.push({ code: 'REC_LOW_COMMITMENT_COMPLETION', domain: 'recovery', severity: commSev, observed_value: commRatio, unit: 'ratio' });

  // REC_03: missed checkin streak
  const missedStreak = recovery_commitments.missed_checkin_streak || 0;
  const streakSev = getSeverityFromBand(missedStreak, [0, 1, 2, 3]);
  recSeverities.push(streakSev);
  if (streakSev >= 50) recReasons.push({ code: 'REC_MISSED_CHECKIN', domain: 'recovery', severity: streakSev, observed_value: missedStreak, unit: 'weeks' });

  // REC_04: mediation followup
  if (recovery_commitments.mediation_followup_required && !recovery_commitments.mediation_followup_completed) {
    recSeverities.push(75);
    recReasons.push({ code: 'REC_MISSED_MEDIATION_FOLLOWUP', domain: 'recovery', severity: 75, observed_value: true, unit: 'boolean' });
  }

  // REC_05: concerning event recurrence
  const recurrence = recovery_commitments.concerning_event_recurrence_7d || 0;
  const recSev = getSeverityFromBand(recurrence, [0, 1, 2, 3]);
  recSeverities.push(recSev);
  if (recSev >= 50) recReasons.push({ code: 'REC_CONCERNING_EVENT_RECURRED', domain: 'recovery', severity: recSev, observed_value: recurrence, unit: 'events' });

  const recovery_nonadherence = recSeverities.length > 0
    ? recSeverities.reduce((a, b) => a + b, 0) / recSeverities.length
    : 0;

  return {
    domainScores: {
      financial_harm: Number(financial_harm.toFixed(1)),
      relationship_strain: Number(relationship_strain.toFixed(1)),
      emotional_strain: Number(emotional_strain.toFixed(1)),
      recovery_nonadherence: Number(recovery_nonadherence.toFixed(1))
    },
    domainReasons: {
      financial: finReasons,
      relationship: relReasons,
      emotional: emoReasons,
      recovery: recReasons
    }
  };
}

module.exports = { evaluateDomainScorecards };