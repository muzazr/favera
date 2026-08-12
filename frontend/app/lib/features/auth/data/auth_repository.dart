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

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<User?> getCurrentUser();

  Future<User> updateProfile({
    String? name,
    String? avatarUrl,
  });

  Future<User> completeOnboarding();
}
