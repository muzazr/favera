enum GoalStatus {
  draft,
  pendingPartnerApproval,
  active,
  completed,
  cancelled,
}

class GoalContribution {
  final String id;
  final String sourceName;
  final DateTime date;
  final int amount;

  const GoalContribution({
    required this.id,
    required this.sourceName,
    required this.date,
    required this.amount,
  });

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      final dateVal = json['contributed_at'] ??
          json['date'] ??
          json['created_at'] ??
          json['transaction_at'];
      if (dateVal is String) {
        parsedDate = DateTime.parse(dateVal);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return GoalContribution(
      id: json['id']?.toString() ?? 'contrib-${DateTime.now().millisecondsSinceEpoch}',
      sourceName: json['source']?.toString() ??
          json['source_name']?.toString() ??
          json['note']?.toString() ??
          'Dari Saldo Bersama',
      date: parsedDate,
      amount: ((json['amount'] ?? json['nominal'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_name': sourceName,
      'date': date.toUtc().toIso8601String(),
      'amount': amount,
    };
  }
}

class FinancialGoal {
  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String deadline; // YYYY-MM-DD
  final GoalStatus status;
  final bool approvedByPartner;
  final String themeIcon; // 'house', 'plane', 'baby', 'car'
  final String
      contributionScheme; // 'Dari Saldo Bersama', 'Patungan Proporsional'
  final String priority; // 'Sangat Penting', 'Penting', 'Fleksibel'
  final List<GoalContribution> contributions;
  final DateTime createdAt;

  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.status = GoalStatus.active,
    this.approvedByPartner = true,
    this.themeIcon = 'house',
    this.contributionScheme = 'Dari Saldo Bersama',
    this.priority = 'Penting',
    this.contributions = const [],
    required this.createdAt,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'] as String? ??
          'goal-${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Target Keuangan',
      targetAmount: (json['target_amount'] as num?)?.toInt() ?? 0,
      currentAmount: (json['current_amount'] as num?)?.toInt() ?? 0,
      deadline: json['deadline'] as String? ?? '',
      status: _parseStatus(json['status'] as String?),
      approvedByPartner: json['approved_by_partner'] as bool? ?? true,
      themeIcon: (json['theme_icon'] as String?) ??
          (json['theme'] as String?) ??
          'house',
      contributionScheme:
          json['contribution_scheme'] as String? ?? 'Dari Saldo Bersama',
      priority: json['priority'] as String? ?? 'Penting',
      contributions: (json['contributions'] as List<dynamic>?)
              ?.map((c) => GoalContribution.fromJson(c as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static GoalStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'pending_partner_approval':
        return GoalStatus.pendingPartnerApproval;
      case 'draft':
        return GoalStatus.draft;
      case 'completed':
        return GoalStatus.completed;
      case 'cancelled':
        return GoalStatus.cancelled;
      default:
        return GoalStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline,
      'status': _statusToString(status),
      'approved_by_partner': approvedByPartner,
      'theme_icon': themeIcon,
      'contribution_scheme': contributionScheme,
      'priority': priority,
      'contributions': contributions.map((c) => c.toJson()).toList(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  static String _statusToString(GoalStatus status) {
    switch (status) {
      case GoalStatus.pendingPartnerApproval:
        return 'pending_partner_approval';
      case GoalStatus.draft:
        return 'draft';
      case GoalStatus.completed:
        return 'completed';
      case GoalStatus.cancelled:
        return 'cancelled';
      case GoalStatus.active:
        return 'active';
    }
  }

  FinancialGoal copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    String? deadline,
    GoalStatus? status,
    bool? approvedByPartner,
    String? themeIcon,
    String? contributionScheme,
    String? priority,
    List<GoalContribution>? contributions,
    DateTime? createdAt,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      approvedByPartner: approvedByPartner ?? this.approvedByPartner,
      themeIcon: themeIcon ?? this.themeIcon,
      contributionScheme: contributionScheme ?? this.contributionScheme,
      priority: priority ?? this.priority,
      contributions: contributions ?? this.contributions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
