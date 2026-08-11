import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app/core/api/api_client.dart';
import 'package:app/core/api/auth_interceptor.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/core/errors/api_error_decoder.dart';
import 'package:app/core/errors/app_failure.dart';
import 'package:app/core/storage/auth_token_storage.dart';

class MockAuthTokenStorage extends Mock implements AuthTokenStorage {}
class MockDio extends Mock implements Dio {}

void main() {
  late MockAuthTokenStorage mockStorage;

  setUp(() {
    mockStorage = MockAuthTokenStorage();
  });

  group('ApiClient Health Check', () {
    test('checkHealth returns true when status is 200', () async {
      final mockDio = MockDio();
      when(() => mockDio.get('/health')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/health'),
          statusCode: 200,
          data: {'status': 'ok'},
        ),
      );

      final client = ApiClient(
        config: AppConfig.fromEnvironment(),
        tokenStorage: mockStorage,
        dioOverride: mockDio,
      );

      final result = await client.checkHealth();
      expect(result, isTrue);
    });

    test('checkHealth throws NetworkFailure when connection fails', () async {
      final mockDio = MockDio();
      when(() => mockDio.get('/health')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/health'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final client = ApiClient(
        config: AppConfig.fromEnvironment(),
        tokenStorage: mockStorage,
        dioOverride: mockDio,
      );

      expect(() => client.checkHealth(), throwsA(isA<NetworkFailure>()));
    });
  });

  group('ApiErrorDecoder & 204 Handling', () {
    test('isNoContent returns true for 204 status code', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/test'),
        statusCode: 204,
      );
      expect(ApiErrorDecoder.isNoContent(res), isTrue);
    });

    test('decode maps 401 to UnauthorizedFailure', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'message': 'Token expired'},
        ),
      );
      final failure = ApiErrorDecoder.decode(err);
      expect(failure, isA<UnauthorizedFailure>());
    });

    test('decode maps 422 validation errors with fields', () {
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
          data: {
            'message': 'Validation failed',
            'errors': {'email': 'Invalid format'},
          },
        ),
      );
      final failure = ApiErrorDecoder.decode(err);
      expect(failure, isA<ValidationFailure>());
      final valFailure = failure as ValidationFailure;
      expect(valFailure.fields['email'], equals('Invalid format'));
    });
  });

  group('AuthInterceptor', () {
    test('attaches Authorization header for protected endpoints when token exists', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => 'test_access_token');

      final interceptor = AuthInterceptor(
        tokenStorage: mockStorage,
        apiBaseUrl: 'https://favera-backend.vercel.app/api/v1',
      );

      final options = RequestOptions(path: '/me');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], equals('Bearer test_access_token'));
    });

    test('skips Authorization header for public endpoints', () async {
      when(() => mockStorage.getAccessToken()).thenAnswer((_) async => 'test_access_token');

      final interceptor = AuthInterceptor(
        tokenStorage: mockStorage,
        apiBaseUrl: 'https://favera-backend.vercel.app/api/v1',
      );

      final options = RequestOptions(path: '/auth/login');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });
}
