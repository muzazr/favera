enum RecoverySessionStatus {
  draft,
  readinessCheck,
  privateReflection,
  waitingForPartner,
  partnerResponse,
  alignment,
  commitmentDraft,
  commitmentActive,
  completed,
  paused,
  mediationRecommended,
}

enum ReadinessLevel {
  ready,
  needTime,
  unsafe,
}

enum CommitmentStatus {
  draft,
  pendingPartnerApproval,
  active,
  completed,
  cancelled,
  overdue,
  revised,
}

class RecoverySession {
  final String id;
  final String title;
  final String topic;
  final RecoverySessionStatus status;
  final ReadinessLevel readinessLevel;
  final String? privateReflection;
  final String? publishedStatement;
  final String? partnerResponseText;
  final String? alignmentSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecoverySession({
    required this.id,
    required this.title,
    required this.topic,
    required this.status,
    this.readinessLevel = ReadinessLevel.ready,
    this.privateReflection,
    this.publishedStatement,
    this.partnerResponseText,
    this.alignmentSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecoverySession.fromJson(Map<String, dynamic> json) {
    return RecoverySession(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Sesi Pemulihan',
      topic: json['topic'] as String? ?? 'Diskusi Keuangan',
      status: _parseSessionStatus(json['status'] as String?),
      readinessLevel: _parseReadinessLevel(json['readiness_level'] as String?),
      privateReflection: json['private_reflection'] as String?,
      publishedStatement: json['published_statement'] as String?,
      partnerResponseText: json['partner_response_text'] as String?,
      alignmentSummary: json['alignment_summary'] as String?,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static RecoverySessionStatus _parseSessionStatus(String? statusStr) {
    if (statusStr == null) return RecoverySessionStatus.draft;
    final normalized = statusStr.toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'readinesscheck':
        return RecoverySessionStatus.readinessCheck;
      case 'privatereflection':
        return RecoverySessionStatus.privateReflection;
      case 'waitingforpartner':
        return RecoverySessionStatus.waitingForPartner;
      case 'partnerresponse':
        return RecoverySessionStatus.partnerResponse;
      case 'alignment':
        return RecoverySessionStatus.alignment;
      case 'commitmentdraft':
        return RecoverySessionStatus.commitmentDraft;
      case 'commitmentactive':
        return RecoverySessionStatus.commitmentActive;
      case 'completed':
        return RecoverySessionStatus.completed;
      case 'paused':
        return RecoverySessionStatus.paused;
      case 'mediationrecommended':
        return RecoverySessionStatus.mediationRecommended;
      case 'draft':
      default:
        return RecoverySessionStatus.draft;
    }
  }

  static ReadinessLevel _parseReadinessLevel(String? readinessStr) {
    if (readinessStr == null) return ReadinessLevel.ready;
    final normalized = readinessStr.toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'needtime':
        return ReadinessLevel.needTime;
      case 'unsafe':
        return ReadinessLevel.unsafe;
      case 'ready':
      default:
        return ReadinessLevel.ready;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'status': status.name,
      'readiness_level': readinessLevel.name,
      'private_reflection': privateReflection,
      'published_statement': publishedStatement,
      'partner_response_text': partnerResponseText,
      'alignment_summary': alignmentSummary,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  RecoverySession copyWith({
    String? id,
    String? title,
    String? topic,
    RecoverySessionStatus? status,
    ReadinessLevel? readinessLevel,
    String? privateReflection,
    String? publishedStatement,
    String? partnerResponseText,
    String? alignmentSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecoverySession(
      id: id ?? this.id,
      title: title ?? this.title,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      readinessLevel: readinessLevel ?? this.readinessLevel,
      privateReflection: privateReflection ?? this.privateReflection,
      publishedStatement: publishedStatement ?? this.publishedStatement,
      partnerResponseText: partnerResponseText ?? this.partnerResponseText,
      alignmentSummary: alignmentSummary ?? this.alignmentSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Commitment {
  final String id;
  final String recoverySessionId;
  final String title;
  final String description;
  final DateTime targetDate;
  final CommitmentStatus status;
  final String createdBy;
  final bool approvedByPartner;
  final int progressPercentage;
  final DateTime createdAt;

  const Commitment({
    required this.id,
    required this.recoverySessionId,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.status,
    required this.createdBy,
    this.approvedByPartner = false,
    this.progressPercentage = 0,
    required this.createdAt,
  });

  factory Commitment.fromJson(Map<String, dynamic> json) {
    return Commitment(
      id: json['id'] as String? ?? '',
      recoverySessionId: json['recovery_session_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      targetDate: json['target_date'] != null
          ? (DateTime.tryParse(json['target_date'] as String) ?? DateTime.now())
          : DateTime.now(),
      status: _parseCommitmentStatus(json['status'] as String?),
      createdBy: json['created_by'] as String? ?? '',
      approvedByPartner: json['approved_by_partner'] as bool? ?? false,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static CommitmentStatus _parseCommitmentStatus(String? statusStr) {
    if (statusStr == null) return CommitmentStatus.draft;
    final normalized = statusStr.toLowerCase().replaceAll('_', '');
    switch (normalized) {
      case 'pendingpartnerapproval':
        return CommitmentStatus.pendingPartnerApproval;
      case 'active':
        return CommitmentStatus.active;
      case 'completed':
        return CommitmentStatus.completed;
      case 'cancelled':
        return CommitmentStatus.cancelled;
      case 'overdue':
        return CommitmentStatus.overdue;
      case 'revised':
        return CommitmentStatus.revised;
      case 'draft':
      default:
        return CommitmentStatus.draft;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recovery_session_id': recoverySessionId,
      'title': title,
      'description': description,
      'target_date': targetDate.toUtc().toIso8601String(),
      'status': status.name,
      'created_by': createdBy,
      'approved_by_partner': approvedByPartner,
      'progress_percentage': progressPercentage,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Commitment copyWith({
    String? id,
    String? recoverySessionId,
    String? title,
    String? description,
    DateTime? targetDate,
    CommitmentStatus? status,
    String? createdBy,
    bool? approvedByPartner,
    int? progressPercentage,
    DateTime? createdAt,
  }) {
    return Commitment(
      id: id ?? this.id,
      recoverySessionId: recoverySessionId ?? this.recoverySessionId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      approvedByPartner: approvedByPartner ?? this.approvedByPartner,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
