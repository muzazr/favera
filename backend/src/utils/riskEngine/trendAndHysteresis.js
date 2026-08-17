// src/utils/riskEngine/trendAndHysteresis.js

/**
 * Menghitung tren dan menerapkan hysteresis state transition (Section 12 & 20)
 */
function calculateTrendAndApplyHysteresis(currentBaseScore, provisionalLevel, previousAssessments = [], hardRulesTriggered = false) {
  let overallTrend = 'STABLE_TREND';
  
  if (!previousAssessments || previousAssessments.length === 0) {
    overallTrend = 'UNKNOWN';
  } else {
    // Ambil rata-rata skor dari 2 minggu terakhir
    const prevScores = previousAssessments.slice(-2).map(a => a.risk_score || 0);
    const refScore = prevScores.reduce((a, b) => a + b, 0) / prevScores.length;
    const delta = currentBaseScore - refScore;

    if (delta >= 8) overallTrend = 'WORSENING';
    else if (delta <= -8) overallTrend = 'IMPROVING';
    else overallTrend = 'STABLE_TREND';
  }

  // Hysteresis Rule (Section 12.4 & 20)
  // Eskalasi naik terjadi SECARA INSTAN.
  // Penurunan butuh 2 minggu berturut-turut di bawah threshold tanpa hard rules.
  let finalLevel = provisionalLevel;
  const lastAssessment = previousAssessments[previousAssessments.length - 1];

  if (lastAssessment) {
    const prevLevel = lastAssessment.risk_level;

    if (prevLevel === 'INTENSIVE_SUPPORT' && provisionalLevel !== 'INTENSIVE_SUPPORT') {
      const consecutiveLow = previousAssessments.slice(-2).every(a => a.risk_score < 60) && !hardRulesTriggered;
      if (!consecutiveLow) {
        finalLevel = 'INTENSIVE_SUPPORT'; // Tahan di intensive
      }
    } else if (prevLevel === 'ATTENTION' && provisionalLevel === 'STABLE') {
      const consecutiveStable = previousAssessments.slice(-2).every(a => a.risk_score < 30) && !hardRulesTriggered;
      if (!consecutiveStable) {
        finalLevel = 'ATTENTION'; // Tahan di attention
      }
    }
  }

  return {
    trend: overallTrend,
    finalLevel
  };
}

module.exports = { calculateTrendAndApplyHysteresis };