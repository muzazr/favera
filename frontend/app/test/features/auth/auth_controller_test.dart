import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/app/router/route_redirect.dart';
import 'package:app/features/auth/application/auth_controller.dart';
import 'package:app/features/auth/data/auth_repository.dart';
import 'package:app/shared/models/user_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late ProviderContainer container;

  final testUser = User(
    id: 'usr-test-123',
    email: 'test@favera.id',
    name: 'Test User',
    onboardingCompleted: true,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController', () {
    test('build hydrates current user when token and user exist', () async {
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => testUser);

      final user = await container.read(authControllerProvider.future);

      expect(user, equals(testUser));
      final routeState = container.read(routeStateProvider);
      expect(routeState.isAuthenticated, isTrue);
      expect(routeState.onboardingCompleted, isTrue);
    });

    test('login succeeds and updates route state', () async {
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
      when(() => mockRepo.login(email: 'test@favera.id', password: 'password123'))
          .thenAnswer((_) async => testUser);

      await container.read(authControllerProvider.future);

      final result = await container
          .read(authControllerProvider.notifier)
          .login('test@favera.id', 'password123');

      expect(result, isTrue);
      final routeState = container.read(routeStateProvider);
      expect(routeState.isAuthenticated, isTrue);
    });

    test('logout clears user state and resets route state', () async {
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => testUser);
      when(() => mockRepo.logout()).thenAnswer((_) async {});

      await container.read(authControllerProvider.future);
      await container.read(authControllerProvider.notifier).logout();

      final currentUser = container.read(authControllerProvider).value;
      expect(currentUser, isNull);

      final routeState = container.read(routeStateProvider);
      expect(routeState.isAuthenticated, isFalse);
    });

    test('completeOnboarding updates user onboardingCompleted status', () async {
      final unonboardedUser = testUser.copyWith(onboardingCompleted: false);
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => unonboardedUser);
      when(() => mockRepo.completeOnboarding()).thenAnswer((_) async => testUser);

      await container.read(authControllerProvider.future);
      await container.read(authControllerProvider.notifier).completeOnboarding();

      final currentUser = container.read(authControllerProvider).value;
      expect(currentUser?.onboardingCompleted, isTrue);

      final routeState = container.read(routeStateProvider);
      expect(routeState.onboardingCompleted, isTrue);
    });
  });
}
