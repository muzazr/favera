enum GoalStatus {
  draft,
  pendingPartnerApproval,
  active,
  completed,
  cancelled,
}

class FinancialGoal {
  final String id;
  final String name;
  final int targetAmount;
  final int currentAmount;
  final String deadline; // YYYY-MM-DD
  final GoalStatus status;
  final bool approvedByPartner;
  final DateTime createdAt;

  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.status = GoalStatus.active,
    this.approvedByPartner = true,
    required this.createdAt,
  });

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: (json['target_amount'] as num).toInt(),
      currentAmount: (json['current_amount'] as num).toInt(),
      deadline: json['deadline'] as String,
      status: _parseStatus(json['status'] as String?),
      approvedByPartner: json['approved_by_partner'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
