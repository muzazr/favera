import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../features/auth/application/auth_controller.dart';
import '../../../mock/mock_providers.dart';
import 'goal_repository.dart';
import 'mock_goal_repository.dart';
import 'remote_goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.goals);
  if (mode == DataSourceMode.remote) {
    final client = ref.watch(apiClientProvider);
    return RemoteGoalRepository(dio: client.dio);
  }
  final store = ref.watch(mockStoreProvider);
  return MockGoalRepository(store: store);
});
