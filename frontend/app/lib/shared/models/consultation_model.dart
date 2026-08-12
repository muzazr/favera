enum ConsultationStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
}

class ConsultationCheckitem {
  final String id;
  final String label;
  final bool isCompleted;

  const ConsultationCheckitem({
    required this.id,
    required this.label,
    this.isCompleted = false,
  });

  factory ConsultationCheckitem.fromJson(Map<String, dynamic> json) {
    return ConsultationCheckitem(
      id: json['id'] as String? ?? 'check-${DateTime.now().millisecondsSinceEpoch}',
      label: json['label'] as String? ?? json['text'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'is_completed': isCompleted,
    };
  }

  ConsultationCheckitem copyWith({
    String? id,
    String? label,
    bool? isCompleted,
  }) {
    return ConsultationCheckitem(
      id: id ?? this.id,
      label: label ?? this.label,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ConsultationNote {
  final String id;
  final String content;
  final String authorName;
  final bool isSharedWithPartner;
  final DateTime createdAt;

  const ConsultationNote({
    required this.id,
    required this.content,
    required this.authorName,
    this.isSharedWithPartner = false,
    required this.createdAt,
  });

  factory ConsultationNote.fromJson(Map<String, dynamic> json) {
    return ConsultationNote(
      id: json['id'] as String? ?? 'note-${DateTime.now().millisecondsSinceEpoch}',
      content: json['content'] as String? ?? json['text'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Konsultan',
      isSharedWithPartner: json['is_shared_with_partner'] as bool? ??
          json['shared'] as bool? ??
          false,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author_name': authorName,
      'is_shared_with_partner': isSharedWithPartner,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}

class Consultation {
  final String id;
  final String professionalId;
  final String professionalName;
  final String professionalTitle;
  final DateTime scheduledAt;
  final ConsultationStatus status;
  final String? topic;
  final List<ConsultationCheckitem> checklist;
  final List<ConsultationNote> notes;
  final DateTime createdAt;

  const Consultation({
    required this.id,
    required this.professionalId,
    required this.professionalName,
    required this.professionalTitle,
    required this.scheduledAt,
    this.status = ConsultationStatus.scheduled,
    this.topic,
    this.checklist = const [],
    this.notes = const [],
    required this.createdAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String? ?? 'cons-${DateTime.now().millisecondsSinceEpoch}',
      professionalId: json['professional_id'] as String? ?? '',
      professionalName: json['professional_name'] as String? ?? 'Ahli Perencana',
      professionalTitle: json['professional_title'] as String? ?? 'Perencana Keuangan',
      scheduledAt: json['scheduled_at'] != null
          ? (DateTime.tryParse(json['scheduled_at'] as String) ?? DateTime.now())
          : DateTime.now(),
      status: _parseStatus(json['status'] as String?),
      topic: json['topic'] as String?,
      checklist: (json['checklist'] as List<dynamic>?)
              ?.map((e) => ConsultationCheckitem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => ConsultationNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  static ConsultationStatus _parseStatus(String? statusStr) {
    switch (statusStr) {
      case 'ongoing':
        return ConsultationStatus.ongoing;
      case 'completed':
        return ConsultationStatus.completed;
      case 'cancelled':
        return ConsultationStatus.cancelled;
      default:
        return ConsultationStatus.scheduled;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'professional_name': professionalName,
      'professional_title': professionalTitle,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'status': status.name,
      'topic': topic,
      'checklist': checklist.map((e) => e.toJson()).toList(),
      'notes': notes.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  Consultation copyWith({
    String? id,
    String? professionalId,
    String? professionalName,
    String? professionalTitle,
    DateTime? scheduledAt,
    ConsultationStatus? status,
    String? topic,
    List<ConsultationCheckitem>? checklist,
    List<ConsultationNote>? notes,
    DateTime? createdAt,
  }) {
    return Consultation(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      topic: topic ?? this.topic,
      checklist: checklist ?? this.checklist,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
