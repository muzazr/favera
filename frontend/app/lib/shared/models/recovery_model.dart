// Recovery domain models aligned with favera-public-api-v0.1.openapi.json
// Shapes: RecoverySession, Commitment, ReadinessRequest, PrivateReflectionRequest

String? _safeString(dynamic val) {
  if (val == null) return null;
  if (val is String) return val;
  if (val is Map) {
    if (val.containsKey('id')) return val['id']?.toString();
    if (val.containsKey('name')) return val['name']?.toString();
    if (val.containsKey('statement')) return val['statement']?.toString();
    if (val.containsKey('content')) return val['content']?.toString();
    if (val.containsKey('text')) return val['text']?.toString();
    if (val.containsKey('summary')) return val['summary']?.toString();
    if (val.containsKey('value')) return val['value']?.toString();
    if (val.containsKey('title')) return val['title']?.toString();
    return val.toString();
  }
  return val.toString();
}

enum RecoverySessionStatus {
  draft,
  readinessCheck,
  privateReflection,
  waitingForPartner,
  partnerResponse,
  alignment,
  commitmentDraft,
  commitmentActive,
  followUp,
  completed,
  paused,
  mediationRecommended,
}

/// API topic enum values (snake_case as sent to / received from backend)
enum RecoveryTopic {
  unknownTransaction,
  hiddenDebt,
  essentialFundsUsage,
  unfulfilledCommitment,
  communicationConflict,
  gamblingRecurrenceConcern,
  other;

  String get apiValue {
    switch (this) {
      case RecoveryTopic.unknownTransaction:
        return 'unknown_transaction';
      case RecoveryTopic.hiddenDebt:
        return 'hidden_debt';
      case RecoveryTopic.essentialFundsUsage:
        return 'essential_funds_usage';
      case RecoveryTopic.unfulfilledCommitment:
        return 'unfulfilled_commitment';
      case RecoveryTopic.communicationConflict:
        return 'communication_conflict';
      case RecoveryTopic.gamblingRecurrenceConcern:
        return 'gambling_recurrence_concern';
      case RecoveryTopic.other:
        return 'other';
    }
  }

  String get displayLabel {
    switch (this) {
      case RecoveryTopic.unknownTransaction:
        return 'Transaksi Tidak Dikenal';
      case RecoveryTopic.hiddenDebt:
        return 'Utang Tersembunyi';
      case RecoveryTopic.essentialFundsUsage:
        return 'Penggunaan Dana Esensial';
      case RecoveryTopic.unfulfilledCommitment:
        return 'Komitmen Tidak Terpenuhi';
      case RecoveryTopic.communicationConflict:
        return 'Konflik Komunikasi';
      case RecoveryTopic.gamblingRecurrenceConcern:
        return 'Perhatian Transaksi Tidak Biasa';
      case RecoveryTopic.other:
        return 'Topik Lainnya';
    }
  }

  static RecoveryTopic fromApi(String? value) {
    if (value == null) return RecoveryTopic.other;
    final v = value.toLowerCase();
    for (final t in RecoveryTopic.values) {
      if (t.apiValue == v) return t;
    }
    return RecoveryTopic.other;
  }
}

/// Nested object: my_readiness (object or null)
class RecoveryReadiness {
  final bool feelsSafe;
  final int readinessLevel; // 1–5
  final bool needsTime;
  final bool needsThirdParty;

  const RecoveryReadiness({
    required this.feelsSafe,
    required this.readinessLevel,
    required this.needsTime,
    required this.needsThirdParty,
  });

  factory RecoveryReadiness.fromJson(Map<String, dynamic> json) {
    return RecoveryReadiness(
      feelsSafe: json['feels_safe'] as bool? ?? true,
      readinessLevel: json['readiness_level'] as int? ?? 3,
      needsTime: json['needs_time'] as bool? ?? false,
      needsThirdParty: json['needs_third_party'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'feels_safe': feelsSafe,
        'readiness_level': readinessLevel,
        'needs_time': needsTime,
        'needs_third_party': needsThirdParty,
      };
}

/// Nested object: my_private_reflection (object or null)
class PrivateReflection {
  final String facts;
  final String impact;
  final String feelings;
  final String needs;
  final String expectations;

  const PrivateReflection({
    required this.facts,
    required this.impact,
    required this.feelings,
    required this.needs,
    required this.expectations,
  });

  factory PrivateReflection.fromJson(Map<String, dynamic> json) {
    return PrivateReflection(
      facts: _safeString(json['facts']) ?? '',
      impact: _safeString(json['impact']) ?? '',
      feelings: _safeString(json['feelings']) ?? '',
      needs: _safeString(json['needs']) ?? '',
      expectations: _safeString(json['expectations']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'facts': facts,
        'impact': impact,
        'feelings': feelings,
        'needs': needs,
        'expectations': expectations,
      };

  /// Combined text for display
  String toDisplayText() {
    final parts = <String>[];
    if (facts.isNotEmpty) parts.add('Fakta: $facts');
    if (impact.isNotEmpty) parts.add('Dampak: $impact');
    if (feelings.isNotEmpty) parts.add('Perasaan: $feelings');
    if (needs.isNotEmpty) parts.add('Kebutuhan: $needs');
    if (expectations.isNotEmpty) parts.add('Harapan: $expectations');
    return parts.join('\n\n');
  }
}

/// Readiness level enum (used internally for UX flow)
enum ReadinessLevel {
  ready,
  needTime,
  unsafe,
}

class RecoverySession {
  final String id;
  final String familyId;
  final String createdByUserId;
  final RecoveryTopic topic;
  final String? customTopic;
  final RecoverySessionStatus status;
  final RecoveryReadiness? myReadiness;
  final String partnerReadinessStatus; // not_started | submitted | not_safe | paused
  final PrivateReflection? myPrivateReflection;
  final String? mySharedStatement;
  final String? partnerSharedStatement;
  final String? partnerResponse; // enum: understand_concern etc
  final String? alignmentSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecoverySession({
    required this.id,
    this.familyId = '',
    this.createdByUserId = '',
    required this.topic,
    this.customTopic,
    required this.status,
    this.myReadiness,
    this.partnerReadinessStatus = 'not_started',
    this.myPrivateReflection,
    this.mySharedStatement,
    this.partnerSharedStatement,
    this.partnerResponse,
    this.alignmentSummary,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Human-readable title for display
  String get title {
    if (customTopic != null && customTopic!.isNotEmpty) return customTopic!;
    return topic.displayLabel;
  }

  /// For backwards compat with existing widgets that use privateReflection as String
  String? get privateReflection => myPrivateReflection?.toDisplayText();

  /// For backwards compat with existing widgets that use publishedStatement
  String? get publishedStatement => mySharedStatement;

  /// For backwards compat
  String? get partnerResponseText => partnerSharedStatement;

  factory RecoverySession.fromJson(Map<String, dynamic> json) {
    // Parse nested my_readiness (object or null)
    RecoveryReadiness? readiness;
    final readinessRaw = json['my_readiness'];
    if (readinessRaw is Map<String, dynamic>) {
      readiness = RecoveryReadiness.fromJson(readinessRaw);
    } else if (readinessRaw is Map) {
      readiness = RecoveryReadiness.fromJson(Map<String, dynamic>.from(readinessRaw));
    }

    // Parse nested my_private_reflection (object, string, or null)
    PrivateReflection? privateRef;
    final reflectionRaw = json['my_private_reflection'];
    if (reflectionRaw is Map<String, dynamic>) {
      privateRef = PrivateReflection.fromJson(reflectionRaw);
    } else if (reflectionRaw is Map) {
      privateRef = PrivateReflection.fromJson(Map<String, dynamic>.from(reflectionRaw));
    } else if (reflectionRaw is String && reflectionRaw.isNotEmpty) {
      privateRef = PrivateReflection(
        facts: reflectionRaw,
        impact: '',
        feelings: '',
        needs: '',
        expectations: '',
      );
    }

    return RecoverySession(
      id: _safeString(json['id']) ?? '',
      familyId: _safeString(json['family_id']) ?? '',
      createdByUserId: _safeString(json['created_by_user_id']) ?? '',
      topic: RecoveryTopic.fromApi(_safeString(json['topic'])),
      customTopic: _safeString(json['custom_topic']),
      status: _parseSessionStatus(_safeString(json['status'])),
      myReadiness: readiness,
      partnerReadinessStatus:
          _safeString(json['partner_readiness_status']) ?? 'not_started',
      myPrivateReflection: privateRef,
      mySharedStatement: _safeString(json['my_shared_statement']),
      partnerSharedStatement: _safeString(json['partner_shared_statement']),
      partnerResponse: _safeString(json['partner_response']),
      alignmentSummary: _safeString(json['alignment_summary']),
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static RecoverySessionStatus _parseSessionStatus(String? statusStr) {
    if (statusStr == null) return RecoverySessionStatus.draft;
    // Backend sends UPPER_CASE with underscores
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
      case 'followup':
        return RecoverySessionStatus.followUp;
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'family_id': familyId,
      'created_by_user_id': createdByUserId,
      'topic': topic.apiValue,
      'custom_topic': customTopic,
      'status': status.name,
      'my_readiness': myReadiness?.toJson(),
      'partner_readiness_status': partnerReadinessStatus,
      'my_private_reflection': myPrivateReflection?.toJson(),
      'my_shared_statement': mySharedStatement,
      'partner_shared_statement': partnerSharedStatement,
      'partner_response': partnerResponse,
      'alignment_summary': alignmentSummary,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  RecoverySession copyWith({
    String? id,
    String? familyId,
    String? createdByUserId,
    RecoveryTopic? topic,
    String? customTopic,
    RecoverySessionStatus? status,
    RecoveryReadiness? myReadiness,
    String? partnerReadinessStatus,
    PrivateReflection? myPrivateReflection,
    String? mySharedStatement,
    String? partnerSharedStatement,
    String? partnerResponse,
    String? alignmentSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecoverySession(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      topic: topic ?? this.topic,
      customTopic: customTopic ?? this.customTopic,
      status: status ?? this.status,
      myReadiness: myReadiness ?? this.myReadiness,
      partnerReadinessStatus:
          partnerReadinessStatus ?? this.partnerReadinessStatus,
      myPrivateReflection: myPrivateReflection ?? this.myPrivateReflection,
      mySharedStatement: mySharedStatement ?? this.mySharedStatement,
      partnerSharedStatement:
          partnerSharedStatement ?? this.partnerSharedStatement,
      partnerResponse: partnerResponse ?? this.partnerResponse,
      alignmentSummary: alignmentSummary ?? this.alignmentSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ─────────────────────────────────────────────
// Commitment model
// ─────────────────────────────────────────────

enum CommitmentStatus {
  draft,
  pendingPartnerApproval,
  active,
  completed,
  cancelled,
  overdue,
  revised,
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
      id: _safeString(json['id']) ?? '',
      recoverySessionId: _safeString(json['recovery_session_id']) ?? '',
      title: _safeString(json['title']) ?? '',
      description: _safeString(json['description']) ?? '',
      targetDate: json['target_date'] != null
          ? (DateTime.tryParse(json['target_date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      status: _parseCommitmentStatus(_safeString(json['status'])),
      createdBy: _safeString(json['created_by']) ?? '',
      approvedByPartner: json['approved_by_partner'] as bool? ?? false,
      progressPercentage: (json['progress_percentage'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
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
