import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/chat_model.dart';
import 'chat_repository.dart';

class RemoteChatRepository implements ChatRepository {
  final ApiClient apiClient;

  RemoteChatRepository({required this.apiClient});

  @override
  Future<List<ChatSession>> getChatSessions() async {
    try {
      final response = await apiClient.dio.get('/chat-sessions');
      // Backend returns {"items": [...]}, let's unwrap it defensively
      final dataMap = response.data as Map<String, dynamic>;
      final list = (dataMap['items'] ?? dataMap['data']) as List<dynamic>? ?? [];
      return list
          .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<ChatSession> createChatSession({String? title}) async {
    try {
      final response = await apiClient.dio.post('/chat-sessions', data: {
        if (title != null) 'title': title,
      });
      final dataMap = response.data as Map<String, dynamic>;
      final data = (dataMap['data'] ?? dataMap) as Map<String, dynamic>;
      return ChatSession.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    try {
      final response =
          await apiClient.dio.get('/chat-sessions/$sessionId/messages');
      final dataMap = response.data as Map<String, dynamic>;
      final list = (dataMap['items'] ?? dataMap['data']) as List<dynamic>? ?? [];
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/chat-sessions/$sessionId/messages',
        data: {'content': content},
      );
      final dataMap = response.data as Map<String, dynamic>;
      final data = (dataMap['data'] ?? dataMap) as Map<String, dynamic>;
      return ChatMessage.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await apiClient.dio.delete('/chat-sessions/$sessionId');
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
