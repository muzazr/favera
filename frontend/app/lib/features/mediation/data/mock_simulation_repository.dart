import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_latency.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/simulation_model.dart';
import 'simulation_repository.dart';

class MockSimulationRepository implements SimulationRepository {
  final MockStore mockStore;
  final MockLatency latency;
  final MockErrorPolicy errorPolicy;

  MockSimulationRepository({
    required this.mockStore,
    required this.latency,
    required this.errorPolicy,
  });

  @override
  Future<ImpactSimulation> getImpactSimulation({
    int? monthlyLivingCost,
    int? childCount,
    int? debtAmount,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getImpactSimulation();
  }
}
