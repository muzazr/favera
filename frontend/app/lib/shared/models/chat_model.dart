enum MessageSender {
  user,
  assistant,
}

enum SafetyLevel {
  none,
  supportRecommended,
  urgentSafety,
}

class ChatMessage {
  final String id;
  final String sessionId;
  final MessageSender sender;
  final String content;
  final DateTime timestamp;
  final List<String> suggestedActions;
  final SafetyLevel safetyLevel;

  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.suggestedActions = const [],
    this.safetyLevel = SafetyLevel.none,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final requiresProf = json['requires_professional_support'] == true;
    final safetyStr = json['safety_level'] as String?;
    SafetyLevel sLevel = SafetyLevel.none;
    if (requiresProf || safetyStr == 'urgent' || safetyStr == 'alert') {
      sLevel = SafetyLevel.urgentSafety;
    } else if (safetyStr == 'warning' || safetyStr == 'supportRecommended') {
      sLevel = SafetyLevel.supportRecommended;
    }

    return ChatMessage(
      id: json['id'] as String? ?? 'msg-${DateTime.now().millisecondsSinceEpoch}',
      sessionId: json['session_id'] as String? ?? '',
      sender: (json['sender'] == 'user' || json['role'] == 'user')
          ? MessageSender.user
          : MessageSender.assistant,
      content: json['content'] as String? ?? json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now())
          : (json['created_at'] != null
              ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
              : DateTime.now()),
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      safetyLevel: sLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'sender': sender.name,
      'content': content,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'suggested_actions': suggestedActions,
      'safety_level': safetyLevel.name,
    };
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final String? lastMessage;

  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    this.lastMessage,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String? ?? 'session-${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Sesi Konseling',
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'] as String) ?? DateTime.now())
          : DateTime.now(),
      lastMessage: json['last_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toUtc().toIso8601String(),
      'last_message': lastMessage,
    };
  }
}
