/// Transaction direction enum matching current contract:
/// income, expense, transfer, debt_increase, debt_payment
/// plus [unknown] as a safe fallback for future values.
enum TransactionDirection {
  income,
  expense,
  transfer,
  debtIncrease,
  debtPayment,
  unknown;

  /// Serialize to API snake_case value.
  String get apiValue {
    switch (this) {
      case TransactionDirection.income:
        return 'income';
      case TransactionDirection.expense:
        return 'expense';
      case TransactionDirection.transfer:
        return 'transfer';
      case TransactionDirection.debtIncrease:
        return 'debt_increase';
      case TransactionDirection.debtPayment:
        return 'debt_payment';
      case TransactionDirection.unknown:
        return 'expense'; // safe fallback for create
    }
  }

  /// Parse from API snake_case string, returns [unknown] for unrecognized values.
  static TransactionDirection fromApi(String? value) {
    switch (value) {
      case 'income':
        return TransactionDirection.income;
      case 'expense':
        return TransactionDirection.expense;
      case 'transfer':
        return TransactionDirection.transfer;
      case 'debt_increase':
        return TransactionDirection.debtIncrease;
      case 'debt_payment':
        return TransactionDirection.debtPayment;
      default:
        return TransactionDirection.unknown;
    }
  }

  /// Whether this direction is a filter-safe value (backend query supports only 3).
  bool get isQueryFilterSafe =>
      this == income || this == expense || this == transfer;
}

/// Attention level enum for anomaly/flag states.
enum AttentionLevel {
  normal,
  unusual,
  needsConfirmation,
  unknown;

  static AttentionLevel fromApi(String? value) {
    switch (value) {
      case 'normal':
        return AttentionLevel.normal;
      case 'unusual':
        return AttentionLevel.unusual;
      case 'needs_confirmation':
        return AttentionLevel.needsConfirmation;
      default:
        return AttentionLevel.unknown;
    }
  }

  String get apiValue {
    switch (this) {
      case AttentionLevel.normal:
        return 'normal';
      case AttentionLevel.unusual:
        return 'unusual';
      case AttentionLevel.needsConfirmation:
        return 'needs_confirmation';
      case AttentionLevel.unknown:
        return 'normal';
    }
  }
}

class Transaction {
  final String id;
  final TransactionDirection direction;
  final int amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isAnomaly;
  final String? anomalyReason;
  final bool confirmedByPartner;
  final AttentionLevel attentionLevel;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.direction,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.isAnomaly = false,
    this.anomalyReason,
    this.confirmedByPartner = false,
    this.attentionLevel = AttentionLevel.normal,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: (json['id'] ?? '') as String,
      direction: TransactionDirection.fromApi(
        (json['direction'] ?? json['type']) as String?,
      ),
      amount: (json['amount'] as num? ?? 0).toInt(),
      category: (json['category'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      isAnomaly: json['is_anomaly'] as bool? ?? false,
      anomalyReason: json['anomaly_reason'] as String?,
      confirmedByPartner: json['confirmed_by_partner'] as bool? ?? false,
      attentionLevel: AttentionLevel.fromApi(
        json['attention_level'] as String?,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction.apiValue,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toUtc().toIso8601String(),
    };
  }

  Transaction copyWith({
    String? id,
    TransactionDirection? direction,
    int? amount,
    String? category,
    String? description,
    DateTime? date,
    bool? isAnomaly,
    String? anomalyReason,
    bool? confirmedByPartner,
    AttentionLevel? attentionLevel,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      isAnomaly: isAnomaly ?? this.isAnomaly,
      anomalyReason: anomalyReason ?? this.anomalyReason,
      confirmedByPartner: confirmedByPartner ?? this.confirmedByPartner,
      attentionLevel: attentionLevel ?? this.attentionLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
