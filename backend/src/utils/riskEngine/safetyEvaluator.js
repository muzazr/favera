// src/utils/riskEngine/safetyEvaluator.js

/**
 * Mengevaluasi aturan keselamatan (Safety Override Rules)
 * Harus diproses SEBELUM skor biasa (Recall 100%)
 */
function evaluateSafetyRules(safetyAnswers = {}) {
  const safetyReasons = [];

  if (safetyAnswers.feels_threatened) {
    safetyReasons.push({
      code: 'SAFE_THREAT_REPORTED',
      domain: 'safety',
      severity: 100,
      contribution: 100,
      observed_value: true,
      unit: 'boolean'
    });
  }
  if (safetyAnswers.physical_violence_reported) {
    safetyReasons.push({
      code: 'SAFE_PHYSICAL_VIOLENCE_REPORTED',
      domain: 'safety',
      severity: 100,
      contribution: 100,
      observed_value: true,
      unit: 'boolean'
    });
  }
  if (safetyAnswers.self_harm_concern) {
    safetyReasons.push({
      code: 'SAFE_SELF_HARM_CONCERN',
      domain: 'safety',
      severity: 100,
      contribution: 100,
      observed_value: true,
      unit: 'boolean'
    });
  }
  if (safetyAnswers.harm_to_others_concern) {
    safetyReasons.push({
      code: 'SAFE_HARM_TO_OTHERS_CONCERN',
      domain: 'safety',
      severity: 100,
      contribution: 100,
      observed_value: true,
      unit: 'boolean'
    });
  }
  if (safetyAnswers.immediate_emergency) {
    safetyReasons.push({
      code: 'SAFE_IMMEDIATE_EMERGENCY',
      domain: 'safety',
      severity: 100,
      contribution: 100,
      observed_value: true,
      unit: 'boolean'
    });
  }

  const isTriggered = safetyReasons.length > 0;

  return {
    triggered: isTriggered,
    reasons: safetyReasons
  };
}

module.exports = { evaluateSafetyRules };