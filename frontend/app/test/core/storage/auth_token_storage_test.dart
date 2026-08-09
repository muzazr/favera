import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/storage/auth_token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthTokenStorage Tests', () {
    late AuthTokenStorage storage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      storage = AuthTokenStorage();
    });

    test('saves and retrieves access & refresh tokens securely', () async {
      await storage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      final access = await storage.getAccessToken();
      final refresh = await storage.getRefreshToken();

      expect(access, equals('access_123'));
      expect(refresh, equals('refresh_456'));
    });

    test('clearTokens removes stored tokens', () async {
      await storage.saveTokens(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
      );

      await storage.clearTokens();

      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });
  });
}
