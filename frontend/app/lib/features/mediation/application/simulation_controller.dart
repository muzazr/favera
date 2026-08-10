import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/simulation_model.dart';
import '../../auth/application/auth_controller.dart';
import '../data/mock_simulation_repository.dart';
import '../data/remote_simulation_repository.dart';
import '../data/simulation_repository.dart';

final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  ref.keepAlive();
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.simulations);

  if (mode == DataSourceMode.remote) {
    return RemoteSimulationRepository(apiClient: ref.watch(apiClientProvider));
  } else {
    return MockSimulationRepository(
      mockStore: ref.watch(mockStoreProvider),
      latency: ref.watch(mockLatencyProvider),
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

final impactSimulationProvider =
    FutureProvider.autoDispose<ImpactSimulation>((ref) async {
  final repo = ref.watch(simulationRepositoryProvider);
  return repo.getImpactSimulation();
});
