import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/storage/auth_token_storage.dart';
import '../../../shared/models/user_model.dart';
import 'auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final AuthTokenStorage tokenStorage;

  RemoteAuthRepository({
    required this.apiClient,
    required this.tokenStorage,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required bool privacyConsent,
  }) async {
    try {
      final response = await apiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'privacy_consent': privacyConsent,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String;

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      return user;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/logout');
    } catch (_) {}
    await tokenStorage.clearTokens();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await apiClient.dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get('/me');
      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await tokenStorage.clearTokens();
        return null;
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      final response = await apiClient.dio.patch('/me', data: {
        if (name != null) 'name': name,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await apiClient.dio.post('/me/onboarding');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppFailure _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data?['message'] as String? ??
        e.message ??
        'Terjadi kesalahan server';
    if (status == 401) return AuthFailure(message: msg);
    if (status == 400 || status == 422) return ValidationFailure(message: msg);
    return NetworkFailure(message: msg);
  }
}
