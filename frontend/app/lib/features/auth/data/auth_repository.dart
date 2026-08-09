import '../../../shared/models/user_model.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required bool privacyConsent,
  });

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<User?> getCurrentUser();

  Future<User> updateProfile({
    String? name,
    String? avatarUrl,
  });

  Future<void> completeOnboarding();
}
