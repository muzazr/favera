import 'package:dio/dio.dart';
import '../storage/auth_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenStorage tokenStorage;
  bool _isRefreshing = false;

  AuthInterceptor({required this.tokenStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          await tokenStorage.clearTokens();
          return handler.next(err);
        }

        // In remote mode, token refresh call will be executed
        // Clear tokens on persistent failure
        _isRefreshing = false;
      } catch (_) {
        _isRefreshing = false;
        await tokenStorage.clearTokens();
      }
    }
    handler.next(err);
  }
}
