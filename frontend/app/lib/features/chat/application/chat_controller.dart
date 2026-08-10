import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/chat_model.dart';
import '../../auth/application/auth_controller.dart';
import '../data/chat_repository.dart';
import '../data/mock_chat_repository.dart';
import '../data/remote_chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  ref.keepAlive();
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.chat);

  if (mode == DataSourceMode.remote) {
    return RemoteChatRepository(apiClient: ref.watch(apiClientProvider));
  } else {
    return MockChatRepository(
      mockStore: ref.watch(mockStoreProvider),
      latency: ref.watch(mockLatencyProvider),
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

final chatSessionsProvider =
    FutureProvider.autoDispose<List<ChatSession>>((ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatSessions();
});

final chatMessagesProvider = FutureProvider.family
    .autoDispose<List<ChatMessage>, String>((ref, sessionId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getChatMessages(sessionId);
});

class ChatController extends AsyncNotifier<void> {
  late final ChatRepository _repository;

  @override
  Future<void> build() async {
    _repository = ref.watch(chatRepositoryProvider);
  }

  Future<void> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.sendMessage(sessionId: sessionId, content: content);
      ref.invalidate(chatMessagesProvider(sessionId));
      ref.invalidate(chatSessionsProvider);
    });
  }

  Future<void> deleteSession(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteChatSession(sessionId);
      ref.invalidate(chatSessionsProvider);
      ref.invalidate(chatMessagesProvider(sessionId));
    });
  }
}

final chatControllerProvider =
    AsyncNotifierProvider<ChatController, void>(ChatController.new);
