import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/simulation_model.dart';
import '../data/mock_simulation_repository.dart';
import '../data/simulation_repository.dart';

// NOT BACKEND-INTEGRATED: /simulations route has been removed from the
// public API contract (Part 13 cleanup). Simulation feature is intentionally
// local/demo. Do NOT add backend calls here until a new contract is published.
final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  ref.keepAlive();
  return MockSimulationRepository(
    mockStore: ref.watch(mockStoreProvider),
    latency: ref.watch(mockLatencyProvider),
    errorPolicy: ref.watch(mockErrorPolicyProvider),
  );
});

final impactSimulationProvider =
    FutureProvider.autoDispose<ImpactSimulation>((ref) async {
  final repo = ref.watch(simulationRepositoryProvider);
  return repo.getImpactSimulation();
});
