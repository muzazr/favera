enum AssessmentLevel {
  stable,
  needsAttention,
  intensiveSupportRecommended,
  safetySupportRequired,
}

enum CheckInStatus {
  open,
  waitingForPartner,
  processing,
  completed,
  expired,
}

class WeeklyCheckIn {
  final String id;
  final String weekPeriod;
  final CheckInStatus status;
  final String myEmotion;
  final String mainConcern;
  final bool partnerSubmitted;
  final String? sharedSummary;
  final DateTime createdAt;

  const WeeklyCheckIn({
    required this.id,
    required this.weekPeriod,
    required this.status,
    required this.myEmotion,
    required this.mainConcern,
    this.partnerSubmitted = false,
    this.sharedSummary,
    required this.createdAt,
  });

  factory WeeklyCheckIn.fromJson(Map<String, dynamic> json) {
    return WeeklyCheckIn(
      id: json['id'] as String? ?? 'chk-${DateTime.now().millisecondsSinceEpoch}',
      weekPeriod: json['week_period'] as String? ?? json['period'] as String? ?? 'Minggu Ini',
      status: _parseStatus(json['status'] as String?),
      myEmotion: json['my_emotion'] as String? ?? 'cukup_baik',
      mainConcern: json['main_concern'] as String? ?? 'keuangan',
      partnerSubmitted: json['partner_submitted'] as bool? ?? false,
      sharedSummary: json['shared_summary'] as String?,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static CheckInStatus _parseStatus(String? statusStr) {
    if (statusStr == null) return CheckInStatus.open;
    switch (statusStr.toLowerCase()) {
      case 'waiting_for_partner':
      case 'waitingforpartner':
        return CheckInStatus.waitingForPartner;
      case 'processing':
        return CheckInStatus.processing;
      case 'completed':
        return CheckInStatus.completed;
      case 'expired':
        return CheckInStatus.expired;
      case 'open':
      default:
        return CheckInStatus.open;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_period': weekPeriod,
      'status': _statusToString(status),
      'my_emotion': myEmotion,
      'main_concern': mainConcern,
      'partner_submitted': partnerSubmitted,
      'shared_summary': sharedSummary,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  static String _statusToString(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.waitingForPartner:
        return 'waiting_for_partner';
      case CheckInStatus.processing:
        return 'processing';
      case CheckInStatus.completed:
        return 'completed';
      case CheckInStatus.expired:
        return 'expired';
      case CheckInStatus.open:
        return 'open';
    }
  }

  WeeklyCheckIn copyWith({
    String? id,
    String? weekPeriod,
    CheckInStatus? status,
    String? myEmotion,
    String? mainConcern,
    bool? partnerSubmitted,
    String? sharedSummary,
    DateTime? createdAt,
  }) {
    return WeeklyCheckIn(
      id: id ?? this.id,
      weekPeriod: weekPeriod ?? this.weekPeriod,
      status: status ?? this.status,
      myEmotion: myEmotion ?? this.myEmotion,
      mainConcern: mainConcern ?? this.mainConcern,
      partnerSubmitted: partnerSubmitted ?? this.partnerSubmitted,
      sharedSummary: sharedSummary ?? this.sharedSummary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class FamilyAssessment {
  final String id;
  final AssessmentLevel level;
  final String summaryText;
  final String recommendedAction;
  final DateTime createdAt;
  final String? trend;
  final Map<String, String>? domainLevels;
  final List<String>? mainFactors;
  final List<String>? recommendedActions;
  final bool safetyOverride;

  const FamilyAssessment({
    required this.id,
    required this.level,
    required this.summaryText,
    required this.recommendedAction,
    required this.createdAt,
    this.trend,
    this.domainLevels,
    this.mainFactors,
    this.recommendedActions,
    this.safetyOverride = false,
  });

  factory FamilyAssessment.fromJson(Map<String, dynamic> json) {
    return FamilyAssessment(
      id: json['id'] as String? ?? '',
      level: _parseLevel(json['level'] as String?),
      summaryText: json['summary_text'] as String? ?? '',
      recommendedAction: json['recommended_action'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : (json['generated_at'] != null
              ? (DateTime.tryParse(json['generated_at'] as String) ?? DateTime.now())
              : DateTime.now()),
      trend: json['trend'] as String?,
      domainLevels: (json['domain_levels'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      mainFactors: (json['main_factors'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      recommendedActions: (json['recommended_actions'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      safetyOverride: json['safety_override'] as bool? ?? false,
    );
  }

  static AssessmentLevel _parseLevel(String? levelStr) {
    switch (levelStr) {
      case 'needs_attention':
        return AssessmentLevel.needsAttention;
      case 'intensive_support_recommended':
        return AssessmentLevel.intensiveSupportRecommended;
      case 'safety_support_required':
        return AssessmentLevel.safetySupportRequired;
      default:
        return AssessmentLevel.stable;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': _levelToString(level),
      'summary_text': summaryText,
      'recommended_action': recommendedAction,
      'created_at': createdAt.toUtc().toIso8601String(),
      'trend': trend,
      'domain_levels': domainLevels,
      'main_factors': mainFactors,
      'recommended_actions': recommendedActions,
      'safety_override': safetyOverride,
    };
  }

  static String _levelToString(AssessmentLevel level) {
    switch (level) {
      case AssessmentLevel.needsAttention:
        return 'needs_attention';
      case AssessmentLevel.intensiveSupportRecommended:
        return 'intensive_support_recommended';
      case AssessmentLevel.safetySupportRequired:
        return 'safety_support_required';
      case AssessmentLevel.stable:
        return 'stable';
    }
  }
}

class FamilyAssessmentNarrative {
  final String headline;
  final String overview;
  final NarrativeActionPlan actionPlan;
  final String encouragement;
  final List<NarrativeDomainHighlight> domainHighlights;
  final NarrativeMeta meta;

  const FamilyAssessmentNarrative({
    required this.headline,
    required this.overview,
    required this.actionPlan,
    required this.encouragement,
    required this.domainHighlights,
    required this.meta,
  });

  factory FamilyAssessmentNarrative.fromJson(Map<String, dynamic> json) {
    return FamilyAssessmentNarrative(
      headline: json['headline'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      actionPlan: NarrativeActionPlan.fromJson(
        json['action_plan'] as Map<String, dynamic>? ?? {},
      ),
      encouragement: json['encouragement'] as String? ?? '',
      domainHighlights: (json['domain_highlights'] as List<dynamic>? ?? [])
          .map((e) => NarrativeDomainHighlight.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: NarrativeMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class NarrativeActionPlan {
  final String title;
  final String description;

  const NarrativeActionPlan({
    required this.title,
    required this.description,
  });

  factory NarrativeActionPlan.fromJson(Map<String, dynamic> json) {
    return NarrativeActionPlan(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class NarrativeDomainHighlight {
  final String note;
  final String domain;
  final String status;

  const NarrativeDomainHighlight({
    required this.note,
    required this.domain,
    required this.status,
  });

  factory NarrativeDomainHighlight.fromJson(Map<String, dynamic> json) {
    return NarrativeDomainHighlight(
      note: json['note'] as String? ?? '',
      domain: json['domain'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class NarrativeMeta {
  final bool isPartial;
  final bool isFallback;
  final DateTime? generatedAt;

  const NarrativeMeta({
    required this.isPartial,
    required this.isFallback,
    this.generatedAt,
  });

  factory NarrativeMeta.fromJson(Map<String, dynamic> json) {
    return NarrativeMeta(
      isPartial: json['is_partial'] as bool? ?? false,
      isFallback: json['is_fallback'] as bool? ?? false,
      generatedAt: json['generated_at'] != null
          ? DateTime.tryParse(json['generated_at'] as String)
          : null,
    );
  }
}
