import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/chat/data/mock_chat_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_error_policy.dart';
import 'package:app/mock/mock_latency.dart';
import 'package:app/mock/mock_store.dart';
import 'package:app/shared/models/chat_model.dart';

void main() {
  group('MockChatRepository Tests', () {
    late MockStore store;
    late MockChatRepository repository;

    setUp(() {
      store = MockStore(clock: MockClock())..resetToSeed(preAuthenticate: true);
      repository = MockChatRepository(
        mockStore: store,
        latency: const MockLatency(isFastMode: true),
        errorPolicy: MockErrorPolicy(),
      );
    });

    test('getChatSessions returns initial seed session', () async {
      final sessions = await repository.getChatSessions();
      expect(sessions.isNotEmpty, isTrue);
      expect(sessions.first.id, equals('session-demo-001'));
    });

    test('getChatMessages returns initial seeded messages', () async {
      final msgs = await repository.getChatMessages('session-demo-001');
      expect(msgs.length, greaterThanOrEqualTo(2));
      expect(msgs.first.sender, equals(MessageSender.assistant));
      expect(msgs.first.content, contains('Budi & Siti'));
    });

    test('sendMessage appends user message and assistant reply', () async {
      final assistantReply = await repository.sendMessage(
        sessionId: 'session-demo-001',
        content: 'Bagaimana cara mengelola pengeluaran berlebih?',
      );
      expect(assistantReply.sender, equals(MessageSender.assistant));
      expect(assistantReply.content, isNotEmpty);

      final msgs = await repository.getChatMessages('session-demo-001');
      expect(msgs.length, greaterThanOrEqualTo(4));
    });

    test('sendMessage triggers urgent safety level on safety keywords',
        () async {
      final assistantReply = await repository.sendMessage(
        sessionId: 'session-demo-001',
        content: 'Saya dalam bahaya dan butuh bantuan segera',
      );
      expect(assistantReply.safetyLevel, equals(SafetyLevel.urgentSafety));
    });
  });
}
