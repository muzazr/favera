// src/utils/riskEngine/index.js

const config = require('../../config/freRulesConfig.json');
const { deriveFeaturesAndQuality } = require('./featureDerivation');
const { evaluateSafetyRules } = require('./safetyEvaluator');
const { evaluateDomainScorecards } = require('./domainScorecards');
const { evaluateHardEscalations } = require('./hardEscalations');
const { calculateTrendAndApplyHysteresis } = require('./trendAndHysteresis');
const { selectTopFactorsAndAction } = require('./actionAndReasons');

/**
 * Main Assessment Function untuk FAVERA Model 2 (family_risk_engine)
 * @param {Object} inputData - Data JSON gabungan dari getFullFamilyHealthSummary
 * @param {Array} previousAssessments - Riwayat asesmen minggu-minggu sebelumnya (optional)
 * @param {string} householdId - ID Rumah Tangga / Keluarga
 * @param {string} assessmentWeek - Format 'YYYY-Wxx' (contoh: '2026-W32')
 */
function assessFamilyRisk(inputData, previousAssessments = [], householdId = 'unknown', assessmentWeek = '2026-W32') {
  // 1. Validation & Feature Derivation
  const { derived, quality } = deriveFeaturesAndQuality(inputData);

  // 2. Safety Override Rules (Recall 100%)
  const safetyResult = evaluateSafetyRules(inputData.safety_answers);

  if (safetyResult.triggered) {
    const { topFactors, recommendedAction } = selectTopFactorsAndAction(safetyResult, { reasons: [] }, {}, 'INTENSIVE_SUPPORT', 'STABLE_TREND', {});

    return {
      household_id: householdId,
      assessment_week: assessmentWeek,
      assessment_status: quality.status,
      risk_level: 'INTENSIVE_SUPPORT',
      risk_score: 100.0,
      trend: 'WORSENING',
      domain_scores: {
        financial_harm: 100.0,
        relationship_strain: 100.0,
        emotional_strain: 100.0,
        recovery_nonadherence: 100.0
      },
      domain_trends: {
        financial_harm: 'WORSENING',
        relationship_strain: 'WORSENING',
        emotional_strain: 'WORSENING',
        recovery_nonadherence: 'WORSENING'
      },
      safety_override: true,
      top_factors: topFactors,
      recommended_action: recommendedAction,
      data_quality_score: quality.score,
      rules_version: config.version,
      generated_at: new Date().toISOString()
    };
  }

  // 3. Domain Scorecards Evaluation
  const { domainScores, domainReasons } = evaluateDomainScorecards(inputData, { derived });

  // 4. Calculate Base Risk Score (Section 9.3)
  const baseRiskScore = Number((
    (config.domain_weights.financial_harm * domainScores.financial_harm) +
    (config.domain_weights.relationship_strain * domainScores.relationship_strain) +
    (config.domain_weights.emotional_strain * domainScores.emotional_strain) +
    (config.domain_weights.recovery_nonadherence * domainScores.recovery_nonadherence)
  ).toFixed(1));

  // 5. Cross-domain Hard Escalations
  const hardRules = evaluateHardEscalations(inputData, { derived }, domainScores);

  // 6. Provisional Level Classification
  let provisionalLevel = 'STABLE';
  if (hardRules.requiredLevel === 'INTENSIVE_SUPPORT' || baseRiskScore >= config.risk_levels.attention_max_exclusive) {
    provisionalLevel = 'INTENSIVE_SUPPORT';
  } else if (baseRiskScore >= config.risk_levels.stable_max_exclusive || Math.max(...Object.values(domainScores)) >= 60 || hardRules.triggered) {
    provisionalLevel = 'ATTENTION';
  }

  // 7. Trend & Hysteresis Application
  const { trend, finalLevel } = calculateTrendAndApplyHysteresis(baseRiskScore, provisionalLevel, previousAssessments, hardRules.triggered);

  // 8. Select Top Factors & Recommended Action
  const { topFactors, recommendedAction } = selectTopFactorsAndAction(safetyResult, hardRules, domainReasons, finalLevel, trend, domainScores);

  // 9. Build Final Output Contract (Section 16)
  return {
    household_id: householdId,
    assessment_week: assessmentWeek,
    assessment_status: quality.status,
    risk_level: finalLevel,
    risk_score: baseRiskScore,
    trend: trend,
    domain_scores: domainScores,
    domain_trends: {
      financial_harm: 'STABLE_TREND',
      relationship_strain: 'STABLE_TREND',
      emotional_strain: 'STABLE_TREND',
      recovery_nonadherence: 'STABLE_TREND'
    },
    safety_override: false,
    top_factors: topFactors,
    recommended_action: recommendedAction,
    data_quality_score: quality.score,
    rules_version: config.version,
    generated_at: new Date().toISOString()
  };
}

module.exports = { assessFamilyRisk };