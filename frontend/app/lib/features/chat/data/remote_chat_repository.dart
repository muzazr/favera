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
      Response response;
      try {
        response = await apiClient.dio.get('/chat/sessions');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await apiClient.dio.get('/chat-sessions');
        } else {
          rethrow;
        }
      }
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
      Response response;
      try {
        response = await apiClient.dio.post('/chat/sessions', data: {
          if (title != null) 'title': title,
        });
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await apiClient.dio.post('/chat-sessions', data: {
            if (title != null) 'title': title,
          });
        } else {
          rethrow;
        }
      }
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
      Response response;
      try {
        response =
            await apiClient.dio.get('/chat/sessions/$sessionId/messages');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response =
              await apiClient.dio.get('/chat-sessions/$sessionId/messages');
        } else {
          rethrow;
        }
      }
      final dataMap = response.data as Map<String, dynamic>;
      final list = (dataMap['items'] ?? dataMap['messages'] ?? dataMap['data'])
              as List<dynamic>? ??
          [];
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
      Response response;
      try {
        response = await apiClient.dio.post(
          '/chat/sessions/$sessionId/messages',
          data: {'content': content, 'message': content},
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await apiClient.dio.post(
            '/chat-sessions/$sessionId/messages',
            data: {'content': content, 'message': content},
          );
        } else {
          rethrow;
        }
      }
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
      try {
        await apiClient.dio.delete('/chat/sessions/$sessionId');
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          await apiClient.dio.delete('/chat-sessions/$sessionId');
        } else {
          rethrow;
        }
      }
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
