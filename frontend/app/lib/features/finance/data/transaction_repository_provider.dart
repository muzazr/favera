import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/data_source_mode.dart';
import '../../auth/application/auth_controller.dart';
import '../../../../mock/mock_providers.dart';
import 'mock_transaction_repository.dart';
import 'remote_transaction_repository.dart';
import 'transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  ref.keepAlive();
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.transactions);
  if (mode == DataSourceMode.remote) {
    return RemoteTransactionRepository(
      apiClient: ref.watch(apiClientProvider),
    );
  }
  final store = ref.watch(mockStoreProvider);
  return MockTransactionRepository(store: store);
});
