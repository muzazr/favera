import '../../../shared/models/chat_model.dart';

abstract class ChatRepository {
  Future<List<ChatSession>> getChatSessions();
  Future<ChatSession> createChatSession({String? title});
  Future<List<ChatMessage>> getChatMessages(String sessionId);
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
  });
  Future<void> deleteChatSession(String sessionId);
}
