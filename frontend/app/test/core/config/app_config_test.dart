import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/core/config/data_source_mode.dart';
import 'package:app/core/config/app_environment.dart';

void main() {
  group('AppConfig Tests', () {
    test('default fromEnvironment returns mock mode and dev environment', () {
      final config = AppConfig.fromEnvironment();

      expect(config.appMode, equals('mock'));
      expect(config.isMock, isTrue);
      expect(config.isRemote, isFalse);
      expect(config.isHybrid, isFalse);
      expect(config.environment, equals(AppEnvironment.dev));
      expect(config.apiBaseUrl, equals('http://localhost:3000/api/v1'));
    });

    test('dataSourceFor in mock mode returns mock for all domains', () {
      final config = AppConfig.fromEnvironment();

      expect(
          config.dataSourceFor(DataDomain.auth), equals(DataSourceMode.mock));
      expect(config.dataSourceFor(DataDomain.dashboard),
          equals(DataSourceMode.mock));
      expect(config.dataSourceFor(DataDomain.statementImport),
          equals(DataSourceMode.mock));
    });

    test('dataSourceFor in remote mode returns remote for all domains', () {
      const config = AppConfig(
        appMode: 'remote',
        apiBaseUrl: 'https://api.favera.id/api/v1',
        environment: AppEnvironment.prod,
      );

      expect(config.isRemote, isTrue);
      expect(
          config.dataSourceFor(DataDomain.auth), equals(DataSourceMode.remote));
      expect(config.dataSourceFor(DataDomain.simulations),
          equals(DataSourceMode.remote));
    });

    test('dataSourceFor in hybrid mode respects domain overrides', () {
      const config = AppConfig(
        appMode: 'hybrid',
        apiBaseUrl: 'http://localhost:3000/api/v1',
        environment: AppEnvironment.dev,
        domainOverrides: {
          DataDomain.auth: DataSourceMode.remote,
          DataDomain.simulations: DataSourceMode.mock,
        },
      );

      expect(config.isHybrid, isTrue);
      expect(
          config.dataSourceFor(DataDomain.auth), equals(DataSourceMode.remote));
      expect(config.dataSourceFor(DataDomain.simulations),
          equals(DataSourceMode.mock));
    });
  });
}
