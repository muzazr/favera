import 'package:dio/dio.dart';
import '../storage/auth_token_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenStorage tokenStorage;
  final String apiBaseUrl;
  final Dio? customDioForRefresh;
  bool _isRefreshing = false;

  static const List<String> _publicPaths = [
    '/health',
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
  ];

  AuthInterceptor({
    required this.tokenStorage,
    required this.apiBaseUrl,
    this.customDioForRefresh,
  });

  bool _isPublicRoute(String path) {
    return _publicPaths.any((publicPath) => path.endsWith(publicPath));
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicRoute(options.path) &&
        !options.headers.containsKey('Authorization')) {
      final token = await tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    final isRetry = err.requestOptions.extra['isRetry'] == true;

    if (err.response?.statusCode == 401 && !isRetry && !_isPublicRoute(path)) {
      if (_isRefreshing) {
        return handler.next(err);
      }

      _isRefreshing = true;
      try {
        final refreshToken = await tokenStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _isRefreshing = false;
          await tokenStorage.clearTokens();
          return handler.next(err);
        }

        final refreshClient = customDioForRefresh ??
            Dio(
              BaseOptions(
                baseUrl: apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            );

        final response = await refreshClient.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          final body = response.data;
          final dataMap = (body is Map<String, dynamic> && body.containsKey('data'))
              ? body['data'] as Map<String, dynamic>
              : body as Map<String, dynamic>;

          final newAccessToken = dataMap['access_token'] as String?;
          final newRefreshToken = dataMap['refresh_token'] as String?;

          if (newAccessToken != null && newRefreshToken != null) {
            await tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            _isRefreshing = false;

            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            retryOptions.extra['isRetry'] = true;

            final retryDio = customDioForRefresh ?? Dio();
            final retriedResponse = await retryDio.fetch(retryOptions);
            return handler.resolve(retriedResponse);
          }
        }

        _isRefreshing = false;
        await tokenStorage.clearTokens();
        return handler.next(err);
      } catch (_) {
        _isRefreshing = false;
        await tokenStorage.clearTokens();
        return handler.next(err);
      }
    }

    handler.next(err);
  }
}
