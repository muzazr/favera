import '../../../core/errors/app_failure.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_latency.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/user_model.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final MockStore mockStore;
  final AuthTokenStorage tokenStorage;
  final MockLatency latency;
  final MockErrorPolicy errorPolicy;

  MockAuthRepository({
    required this.mockStore,
    required this.tokenStorage,
    required this.latency,
    required this.errorPolicy,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw const ValidationFailure(
          message: 'Email dan password tidak boleh kosong');
    }

    if (password.length < 6) {
      throw const AuthFailure(
          message: 'Password salah atau kombinasi tidak ditemukan');
    }

    final user = User(
      id: 'usr-joselin-001',
      email: email,
      name: 'Joselin',
      onboardingCompleted: true,
      avatarUrl: 'assets/profile_women.png',
      createdAt: DateTime.now(),
    );

    mockStore.currentUser = user;
    await tokenStorage.saveTokens(
      accessToken: 'mock_access_token_${user.id}',
      refreshToken: 'mock_refresh_token_${user.id}',
    );

    return user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required bool privacyConsent,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    if (!privacyConsent) {
      throw const ValidationFailure(
          message: 'Anda harus menyetujui Kebijakan Privasi Favera');
    }

    if (email.trim().isEmpty || name.trim().isEmpty) {
      throw const ValidationFailure(
          message: 'Nama dan Email wajib diisi dengan benar');
    }

    final newUser = User(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      onboardingCompleted: true,
      avatarUrl: 'assets/profile_women.png',
      createdAt: DateTime.now(),
    );

    mockStore.currentUser = newUser;
    await tokenStorage.saveTokens(
      accessToken: 'mock_access_token_${newUser.id}',
      refreshToken: 'mock_refresh_token_${newUser.id}',
    );

    return newUser;
  }

  @override
  Future<void> logout() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    mockStore.resetToSeed();
    await tokenStorage.clearTokens();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    if (email.trim().isEmpty) {
      throw const ValidationFailure(message: 'Masukkan email terdaftar anda');
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    if (newPassword.trim().length < 6) {
      throw const ValidationFailure(message: 'Password baru minimal 6 karakter');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    errorPolicy.checkAndThrow();
    final token = await tokenStorage.getAccessToken();
    if (token == null) return null;
    return mockStore.currentUser;
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final current = mockStore.currentUser;
    if (current == null) {
      throw const AuthFailure(message: 'Sesi anda telah berakhir');
    }

    final updated = current.copyWith(
      name: name,
      avatarUrl: avatarUrl,
    );
    mockStore.currentUser = updated;
    return updated;
  }

  @override
  Future<User> completeOnboarding() async {
    final current = mockStore.currentUser ??
        User(
          id: 'usr-guest-${DateTime.now().millisecondsSinceEpoch}',
          email: 'guest@favera.id',
          name: 'Pengguna',
          onboardingCompleted: true,
          createdAt: DateTime.now(),
        );

    final updated = current.copyWith(onboardingCompleted: true);
    mockStore.currentUser = updated;
    return updated;
  }
}
