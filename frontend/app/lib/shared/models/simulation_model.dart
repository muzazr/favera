class ImpactSimulation {
  final String id;
  final int monthlyLivingCost;
  final int childCount;
  final int debtAmount;
  final String financialImpactText;
  final String childImpactText;
  final String disclaimer;

  const ImpactSimulation({
    required this.id,
    required this.monthlyLivingCost,
    required this.childCount,
    required this.debtAmount,
    required this.financialImpactText,
    required this.childImpactText,
    required this.disclaimer,
  });

  factory ImpactSimulation.fromJson(Map<String, dynamic> json) {
    return ImpactSimulation(
      id: json['id'] as String,
      monthlyLivingCost: (json['monthly_living_cost'] as num).toInt(),
      childCount: (json['child_count'] as num).toInt(),
      debtAmount: (json['debt_amount'] as num).toInt(),
      financialImpactText: json['financial_impact_text'] as String,
      childImpactText: json['child_impact_text'] as String,
      disclaimer: json['disclaimer'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthly_living_cost': monthlyLivingCost,
      'child_count': childCount,
      'debt_amount': debtAmount,
      'financial_impact_text': financialImpactText,
      'child_impact_text': childImpactText,
      'disclaimer': disclaimer,
    };
  }
}
