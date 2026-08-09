import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/errors/app_failure.dart';
import 'package:app/core/storage/auth_token_storage.dart';
import 'package:app/features/auth/data/mock_auth_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_error_policy.dart';
import 'package:app/mock/mock_latency.dart';
import 'package:app/mock/mock_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockAuthRepository Tests', () {
    late MockStore store;
    late AuthTokenStorage tokenStorage;
    late MockAuthRepository authRepository;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      store = MockStore(clock: MockClock());
      tokenStorage = AuthTokenStorage();
      authRepository = MockAuthRepository(
        mockStore: store,
        tokenStorage: tokenStorage,
        latency: const MockLatency(isFastMode: true),
        errorPolicy: MockErrorPolicy(),
      );
    });

    test('login with valid credentials saves tokens and returns User',
        () async {
      final user = await authRepository.login(
        email: 'joselin.demo@favera.local',
        password: '123456',
      );

      expect(user.email, equals('joselin.demo@favera.local'));
      expect(await tokenStorage.getAccessToken(), isNotNull);
    });

    test('login with short password throws AuthFailure', () async {
      expect(
        () => authRepository.login(
          email: 'test@favera.local',
          password: '123',
        ),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('register requires privacy consent', () async {
      expect(
        () => authRepository.register(
          name: 'Joselin',
          email: 'joselin@favera.local',
          password: '123456',
          privacyConsent: false,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('logout clears store user and tokens', () async {
      await authRepository.login(
        email: 'joselin.demo@favera.local',
        password: '123456',
      );

      await authRepository.logout();

      expect(store.currentUser, isNull);
      expect(await tokenStorage.getAccessToken(), isNull);
    });
  });
}
