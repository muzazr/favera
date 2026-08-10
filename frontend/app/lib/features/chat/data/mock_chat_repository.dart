import '../../../core/errors/app_failure.dart';
import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_latency.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/chat_model.dart';
import 'chat_repository.dart';

class MockChatRepository implements ChatRepository {
  final MockStore mockStore;
  final MockLatency latency;
  final MockErrorPolicy errorPolicy;

  MockChatRepository({
    required this.mockStore,
    required this.latency,
    required this.errorPolicy,
  });

  @override
  Future<List<ChatSession>> getChatSessions() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getChatSessions();
  }

  @override
  Future<ChatSession> createChatSession({String? title}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final session = ChatSession(
      id: 'session-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Konsultasi Finansial Empatik',
      createdAt: DateTime.now(),
    );
    return session;
  }

  @override
  Future<List<ChatMessage>> getChatMessages(String sessionId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getChatMessages(sessionId);
  }

  @override
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    if (content.trim().isEmpty) {
      throw const ValidationFailure(message: 'Pesan tidak boleh kosong');
    }
    return mockStore.sendChatMessage(sessionId, content);
  }

  @override
  Future<void> deleteChatSession(String sessionId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    mockStore.deleteChatSession(sessionId);
  }
}
