import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../mock/mock_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/dashboard_model.dart';
import '../data/dashboard_repository.dart';
import '../data/mock_dashboard_repository.dart';
import '../data/remote_dashboard_repository.dart';

final hideBalanceStateProvider = StateProvider<bool>((ref) => false);

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.dashboard);

  if (mode == DataSourceMode.remote) {
    return RemoteDashboardRepository(apiClient: ref.watch(apiClientProvider));
  } else {
    return MockDashboardRepository(
      mockStore: ref.watch(mockStoreProvider),
      latency: ref.watch(mockLatencyProvider),
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

class DashboardController extends AsyncNotifier<DashboardSummary> {
  DashboardRepository get _repository => ref.read(dashboardRepositoryProvider);

  @override
  Future<DashboardSummary> build() async {
    final repo = ref.watch(dashboardRepositoryProvider);
    return await repo.getDashboardSummary();
  }

  Future<void> refreshSummary() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () async => await _repository.getDashboardSummary());
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardSummary>(
        DashboardController.new);
