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
      final response = await apiClient.dio.get('/chat/sessions');
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
      final response = await apiClient.dio.post(
        '/chat/sessions',
        data: {
          'title': title ?? 'Konsultasi AI Favera',
          'context_scope': [
            'latest_family_assessment',
            'financial_summary',
            'goals',
            'commitments',
          ],
        },
      );
      final dataMap = response.data as Map<String, dynamic>;
      final data = (dataMap['data'] ?? dataMap) as Map<String, dynamic>;
      return ChatSession.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  Future<String> _ensureValidSessionId(String sessionId) async {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidRegex.hasMatch(sessionId)) {
      return sessionId;
    }
    final sessions = await getChatSessions();
    if (sessions.isNotEmpty) {
      return sessions.first.id;
    }
    final newSession = await createChatSession(title: 'Konsultasi AI Favera');
    return newSession.id;
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    final validId = await _ensureValidSessionId(sessionId);
    try {
      final response =
          await apiClient.dio.get('/chat/sessions/$validId/messages');
      final dataMap = response.data as Map<String, dynamic>;
      final list = (dataMap['items'] ?? dataMap['messages'] ?? dataMap['data'])
              as List<dynamic>? ??
          [];
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    final validId = await _ensureValidSessionId(sessionId);
    try {
      final response = await apiClient.dio.post(
        '/chat/sessions/$validId/messages',
        data: {
          'message': content,
        },
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
    final validId = await _ensureValidSessionId(sessionId);
    try {
      await apiClient.dio.delete('/chat/sessions/$validId');
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
