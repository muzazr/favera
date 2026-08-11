import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
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

  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        return responseData['data'] as Map<String, dynamic>;
      }
      return responseData;
    }
    return {};
  }

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

      final data = _extractData(response.data);
      final userJson = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      final user = User.fromJson(userJson);

      final accessToken = data['access_token'] as String? ?? '';
      final refreshToken = data['refresh_token'] as String? ?? '';

      if (accessToken.isNotEmpty) {
        await tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      return user;
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
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

      final data = _extractData(response.data);
      final userJson = data['user'] is Map<String, dynamic>
          ? data['user'] as Map<String, dynamic>
          : data;
      final user = User.fromJson(userJson);

      final accessToken = data['access_token'] as String? ?? '';
      final refreshToken = data['refresh_token'] as String? ?? '';

      if (accessToken.isNotEmpty) {
        await tokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      return user;
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
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
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await apiClient.dio.post('/auth/reset-password', data: {
        'token': token,
        'new_password': newPassword,
      });
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      final response = await apiClient.dio.get('/me');
      final data = _extractData(response.data);
      return User.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await tokenStorage.clearTokens();
        return null;
      }
      throw ApiErrorDecoder.decode(e);
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
      final data = _extractData(response.data);
      return User.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<User> completeOnboarding() async {
    try {
      final response = await apiClient.dio.post('/me/onboarding');
      final data = _extractData(response.data);
      return User.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
