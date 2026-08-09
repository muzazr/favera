import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/auth_token_storage.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({
    required AppConfig config,
    required AuthTokenStorage tokenStorage,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage));

    // Add Request ID Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Request-ID'] =
              'req-${DateTime.now().millisecondsSinceEpoch}';
          handler.next(options);
        },
      ),
    );
  }
}
