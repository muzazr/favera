enum AssessmentLevel {
  stable,
  needsAttention,
  safetySupportRequired,
}

enum CheckInStatus {
  open,
  waitingForPartner,
  processing,
  completed,
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
      id: json['id'] as String,
      weekPeriod: json['week_period'] as String,
      status: CheckInStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CheckInStatus.open,
      ),
      myEmotion: json['my_emotion'] as String? ?? 'cukup_baik',
      mainConcern: json['main_concern'] as String? ?? 'keuangan',
      partnerSubmitted: json['partner_submitted'] as bool? ?? false,
      sharedSummary: json['shared_summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_period': weekPeriod,
      'status': status.name,
      'my_emotion': myEmotion,
      'main_concern': mainConcern,
      'partner_submitted': partnerSubmitted,
      'shared_summary': sharedSummary,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
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

  const FamilyAssessment({
    required this.id,
    required this.level,
    required this.summaryText,
    required this.recommendedAction,
    required this.createdAt,
  });

  factory FamilyAssessment.fromJson(Map<String, dynamic> json) {
    return FamilyAssessment(
      id: json['id'] as String,
      level: _parseLevel(json['level'] as String?),
      summaryText: json['summary_text'] as String,
      recommendedAction: json['recommended_action'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static AssessmentLevel _parseLevel(String? levelStr) {
    switch (levelStr) {
      case 'needs_attention':
        return AssessmentLevel.needsAttention;
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
    };
  }

  static String _levelToString(AssessmentLevel level) {
    switch (level) {
      case AssessmentLevel.needsAttention:
        return 'needs_attention';
      case AssessmentLevel.safetySupportRequired:
        return 'safety_support_required';
      case AssessmentLevel.stable:
        return 'stable';
    }
  }
}
