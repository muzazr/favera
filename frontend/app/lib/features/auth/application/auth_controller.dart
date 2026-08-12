import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/router/route_redirect.dart';
import '../../../core/api/api_client.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/user_model.dart';
import '../data/auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../data/remote_auth_repository.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  return AuthTokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final tokenStorage = ref.watch(authTokenStorageProvider);
  return ApiClient(config: config, tokenStorage: tokenStorage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.auth);

  if (mode == DataSourceMode.remote) {
    return RemoteAuthRepository(
      apiClient: ref.watch(apiClientProvider),
      tokenStorage: ref.watch(authTokenStorageProvider),
    );
  } else {
    return MockAuthRepository(
      mockStore: ref.watch(mockStoreProvider),
      tokenStorage: ref.watch(authTokenStorageProvider),
      latency: ref.watch(mockLatencyProvider),
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

class AuthController extends AsyncNotifier<User?> {
  late final AuthRepository _repository;

  @override
  Future<User?> build() async {
    _repository = ref.watch(authRepositoryProvider);
    final user = await _repository.getCurrentUser();
    _syncRouteState(user);
    return user;
  }

  void _syncRouteState(User? user) {
    final routeNotifier = ref.read(routeStateProvider.notifier);
    if (user != null) {
      routeNotifier.setAuthenticated(true);
      routeNotifier.setOnboardingCompleted(true);
      routeNotifier.setProfileCompleted(user.name.isNotEmpty);
    } else {
      routeNotifier.setAuthenticated(false);
      routeNotifier.setProfileCompleted(false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await _repository.login(email: email, password: password);
      _syncRouteState(user);
      return user;
    });
    return state.hasValue && state.value != null;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required bool privacyConsent,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.register(
        name: name,
        email: email,
        password: password,
        privacyConsent: privacyConsent,
      );
      await _repository.logout();
      state = const AsyncValue.data(null);
      _syncRouteState(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.logout();
    state = const AsyncValue.data(null);
    _syncRouteState(null);
  }

  Future<void> forgotPassword(String email) async {
    await _repository.forgotPassword(email: email);
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _repository.resetPassword(token: token, newPassword: newPassword);
  }

  Future<bool> updateProfile({String? name, String? avatarUrl}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updated = await _repository.updateProfile(
        name: name,
        avatarUrl: avatarUrl,
      );
      _syncRouteState(updated);
      return updated;
    });
    return state.hasValue && state.value != null;
  }

  Future<void> completeOnboarding() async {
    final currentUser = state.value;
    if (currentUser != null) {
      state = const AsyncValue.loading();
      try {
        final updated = await _repository.completeOnboarding();
        state = AsyncValue.data(updated);
        _syncRouteState(updated);
      } catch (_) {
        // Fallback: If backend returns 500 on /me/onboarding, mark onboarding completed locally
        final fallbackUser = currentUser.copyWith(onboardingCompleted: true);
        state = AsyncValue.data(fallbackUser);
        _syncRouteState(fallbackUser);
      }
    } else {
      ref.read(routeStateProvider.notifier).setOnboardingCompleted(true);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);
