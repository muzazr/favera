import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/api_error_decoder.dart';
import '../errors/app_failure.dart';
import '../storage/auth_token_storage.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({
    required AppConfig config,
    required AuthTokenStorage tokenStorage,
    Dio? dioOverride,
  }) {
    dio = dioOverride ??
        Dio(
          BaseOptions(
            baseUrl: config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    if (dioOverride == null) {
      dio.interceptors.add(
        AuthInterceptor(
          tokenStorage: tokenStorage,
          apiBaseUrl: config.apiBaseUrl,
        ),
      );

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

      // Add Sanitized Logger Interceptor for Debug mode
      if (kDebugMode) {
        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              debugPrint('[API Request] ${options.method} ${options.uri}');
              handler.next(options);
            },
            onResponse: (response, handler) {
              debugPrint(
                  '[API Response] ${response.statusCode} ${response.requestOptions.uri}');
              handler.next(response);
            },
            onError: (err, handler) {
              debugPrint(
                  '[API Error] ${err.response?.statusCode} ${err.requestOptions.uri} - ${err.message}');
              handler.next(err);
            },
          ),
        );
      }
    }
  }

  /// Smoke test endpoint GET /health
  Future<bool> checkHealth() async {
    try {
      final response = await dio.get('/health');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    } catch (e) {
      throw const NetworkFailure(message: 'Gagal menghubungi server health check');
    }
  }
}
