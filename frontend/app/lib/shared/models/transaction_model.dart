enum TransactionType {
  income,
  expense,
}

class Transaction {
  final String id;
  final TransactionType type;
  final int amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isAnomaly;
  final String? anomalyReason;
  final bool confirmedByPartner;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.isAnomaly = false,
    this.anomalyReason,
    this.confirmedByPartner = false,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: (json['amount'] as num).toInt(),
      category: json['category'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      isAnomaly: json['is_anomaly'] as bool? ?? false,
      anomalyReason: json['anomaly_reason'] as String?,
      confirmedByPartner: json['confirmed_by_partner'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toUtc().toIso8601String(),
      'is_anomaly': isAnomaly,
      'anomaly_reason': anomalyReason,
      'confirmed_by_partner': confirmedByPartner,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? category,
    String? description,
    DateTime? date,
    bool? isAnomaly,
    String? anomalyReason,
    bool? confirmedByPartner,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      isAnomaly: isAnomaly ?? this.isAnomaly,
      anomalyReason: anomalyReason ?? this.anomalyReason,
      confirmedByPartner: confirmedByPartner ?? this.confirmedByPartner,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
