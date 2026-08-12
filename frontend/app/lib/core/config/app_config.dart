import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_environment.dart';
import 'data_source_mode.dart';

class AppConfig {
  final String appMode; // 'mock', 'remote', 'hybrid'
  final String apiBaseUrl;
  final AppEnvironment environment;
  final Map<DataDomain, DataSourceMode> domainOverrides;

  const AppConfig({
    required this.appMode,
    required this.apiBaseUrl,
    required this.environment,
    this.domainOverrides = const {},
  });

  factory AppConfig.fromEnvironment() {
    const rawMode = String.fromEnvironment('APP_MODE', defaultValue: 'mock');
    const rawApiUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://favera-backend.vercel.app',
    );
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');

    final env = switch (rawEnv.toLowerCase()) {
      'staging' => AppEnvironment.staging,
      'prod' || 'production' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };

    final defaultHybridOverrides = <DataDomain, DataSourceMode>{
      DataDomain.auth: DataSourceMode.remote,
      DataDomain.family: DataSourceMode.remote,
      DataDomain.dashboard: DataSourceMode.remote,
      DataDomain.transactions: DataSourceMode.remote,
      DataDomain.statementImport: DataSourceMode.remote,
      DataDomain.checkIn: DataSourceMode.remote,
      DataDomain.assessment: DataSourceMode.remote,
      DataDomain.chat: DataSourceMode.mock,
      DataDomain.goals: DataSourceMode.remote,
      DataDomain.recovery: DataSourceMode.remote,
      DataDomain.commitments: DataSourceMode.remote,
      DataDomain.professionals: DataSourceMode.mock,
      DataDomain.consultations: DataSourceMode.mock,
      DataDomain.simulations: DataSourceMode.mock,
      DataDomain.notifications: DataSourceMode.mock,
    };

    return AppConfig(
      appMode: rawMode.toLowerCase(),
      apiBaseUrl: rawApiUrl,
      environment: env,
      domainOverrides: defaultHybridOverrides,
    );
  }

  DataSourceMode dataSourceFor(DataDomain domain) {
    return switch (appMode) {
      'remote' => DataSourceMode.remote,
      'hybrid' => domainOverrides[domain] ?? DataSourceMode.mock,
      _ => DataSourceMode.mock,
    };
  }

  bool get isMock => appMode == 'mock';
  bool get isRemote => appMode == 'remote';
  bool get isHybrid => appMode == 'hybrid';
  bool get isDev => environment == AppEnvironment.dev;
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
