import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/models/chat_model.dart';
import 'chat_repository.dart';

class RemoteChatRepository implements ChatRepository {
  final ApiClient apiClient;

  RemoteChatRepository({required this.apiClient});

  @override
  Future<List<ChatSession>> getChatSessions() async {
    try {
      final response = await apiClient.dio.get('/chat-sessions');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ChatSession> createChatSession({String? title}) async {
    try {
      final response = await apiClient.dio.post('/chat-sessions', data: {
        if (title != null) 'title': title,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return ChatSession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    try {
      final response =
          await apiClient.dio.get('/chat-sessions/$sessionId/messages');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
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
      final data = response.data['data'] as Map<String, dynamic>;
      return ChatMessage.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    try {
      await apiClient.dio.delete('/chat-sessions/$sessionId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppFailure _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data?['message'] as String? ??
        e.message ??
        'Terjadi kesalahan server';
    if (status == 401) return AuthFailure(message: msg);
    if (status == 404) return NotFoundFailure(message: msg);
    if (status == 400 || status == 422) return ValidationFailure(message: msg);
    return NetworkFailure(message: msg);
  }
}
