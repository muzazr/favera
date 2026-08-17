// src/utils/riskEngine/featureDerivation.js

const EPSILON = 0.0001;

/**
 * Membentuk derived features dan menghitung data quality score dari raw input
 */
function deriveFeaturesAndQuality(input) {
  const {
    model1_summary = {},
    financial_snapshot = {},
    partner_checkins = {},
    recovery_commitments = {}
  } = input;

  // 1. Unpack Raw Financials
  const {
    weekly_income_baseline = 0,
    essential_budget_7d = 0,
    essential_funds_available_7d = 0,
    debt_balance_current = 0,
    debt_balance_28d_ago = 0,
    debt_payment_due_30d = 0,
    savings_current = 0,
    savings_28d_ago = 0,
    cash_expected = 0,
    cash_reported = 0
  } = financial_snapshot;

  const {
    confirmed_unusual_value_7d = 0,
    confirmed_unusual_count_7d = 0,
    model1_data_coverage = 0
  } = model1_summary;

  const { partner_a, partner_b } = partner_checkins;
  const checkinACount = partner_a ? 1 : 0;
  const checkinBCount = partner_b ? 1 : 0;
  const completedCheckins = checkinACount + checkinBCount;

  // 2. Denominator Safe Logic
  const denomIncomeOrBudget = Math.max(weekly_income_baseline, essential_budget_7d, EPSILON);
  const denomDebt = Math.max(debt_balance_28d_ago, weekly_income_baseline, EPSILON);
  const monthlyNetIncomeEstimate = weekly_income_baseline * 4.345;
  const denomDebtService = Math.max(monthlyNetIncomeEstimate, EPSILON);

  // 3. Formula Ratios (Section 7)
  const essential_budget_gap_ratio = Math.max(0, essential_budget_7d - essential_funds_available_7d) / Math.max(essential_budget_7d, EPSILON);
  const debt_growth_ratio_28d = Math.max(0, debt_balance_current - debt_balance_28d_ago) / denomDebt;
  const debt_service_ratio = debt_payment_due_30d / denomDebtService;
  const savings_drawdown_ratio_28d = Math.max(0, savings_28d_ago - savings_current) / Math.max(savings_28d_ago, weekly_income_baseline, EPSILON);
  const confirmed_unusual_value_ratio = confirmed_unusual_value_7d / denomIncomeOrBudget;
  const cash_reconciliation_gap_ratio = Math.abs(cash_expected - cash_reported) / denomIncomeOrBudget;

  // 4. Partner Divergence (Hanya jika kedua pasangan mengisi)
  let partner_divergence = null;
  if (partner_a && partner_b) {
    const items = ['trust_score', 'communication_safety_score', 'communication_quality_score', 'openness_score', 'partner_support_score', 'relationship_progress_score'];
    const diffSum = items.reduce((sum, key) => sum + Math.abs((partner_a[key] ?? 0) - (partner_b[key] ?? 0)), 0);
    partner_divergence = diffSum / items.length;
  }

  // 5. Recovery Ratio
  const totalComm = recovery_commitments.commitment_total_7d || 0;
  const compComm = recovery_commitments.commitment_completed_7d || 0;
  const commitment_completion_ratio = totalComm > 0 ? compComm / totalComm : 1;
  const checkin_completion_ratio = completedCheckins / 2;

  // 6. Rata-rata Skor Pasangan (A & B) untuk Domain Relasi & Emosi
  const partnerAvg = (key) => {
    if (partner_a && partner_b) return (partner_a[key] + partner_b[key]) / 2;
    if (partner_a) return partner_a[key];
    if (partner_b) return partner_b[key];
    return null; // Missing
  };

  // 7. Hitung Data Quality Score (Section 17)
  // Component 1: Financial coverage (30%)
  const finCoverageScore = Object.keys(financial_snapshot).length > 0 ? 100 : 0;
  // Component 2: Model 1 coverage (25%)
  const model1Score = Math.min(100, Math.max(0, model1_data_coverage));
  // Component 3: Partner check-in completeness (25%)
  const checkinScore = (completedCheckins / 2) * 100;
  // Component 4: Recovery completeness (10%)
  const recoveryScore = Object.keys(recovery_commitments).length > 0 ? 100 : 0;
  // Component 5: Continuity (10% - default 100 jika dipanggil mingguan)
  const continuityScore = 100;

  const dataQualityScore = Math.round(
    (0.30 * finCoverageScore) +
    (0.25 * model1Score) +
    (0.25 * checkinScore) +
    (0.10 * recoveryScore) +
    (0.10 * continuityScore)
  );

  let assessmentStatus = 'COMPLETE';
  if (dataQualityScore < 50) assessmentStatus = 'INSUFFICIENT';
  else if (dataQualityScore < 80) assessmentStatus = 'PARTIAL';

  return {
    derived: {
      essential_budget_gap_ratio,
      debt_growth_ratio_28d,
      debt_service_ratio,
      savings_drawdown_ratio_28d,
      confirmed_unusual_value_ratio,
      confirmed_unusual_count_7d,
      cash_reconciliation_gap_ratio,
      commitment_completion_ratio,
      checkin_completion_ratio,
      partner_divergence,
      partnerAvg
    },
    quality: {
      score: dataQualityScore,
      status: assessmentStatus
    }
  };
}

module.exports = { deriveFeaturesAndQuality };