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
    return ChatMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      sender: json['sender'] == 'user'
          ? MessageSender.user
          : MessageSender.assistant,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      suggestedActions: (json['suggested_actions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      safetyLevel: SafetyLevel.values.firstWhere(
        (e) => e.name == json['safety_level'],
        orElse: () => SafetyLevel.none,
      ),
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
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
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
