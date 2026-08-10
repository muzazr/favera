import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../features/auth/application/auth_controller.dart';
import '../../../mock/mock_providers.dart';
import 'mock_statement_repository.dart';
import 'remote_statement_repository.dart';
import 'statement_repository.dart';

final statementRepositoryProvider = Provider<StatementRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.statementImport);
  if (mode == DataSourceMode.remote) {
    final client = ref.watch(apiClientProvider);
    return RemoteStatementRepository(dio: client.dio);
  }
  final store = ref.watch(mockStoreProvider);
  return MockStatementRepository(store: store);
});
