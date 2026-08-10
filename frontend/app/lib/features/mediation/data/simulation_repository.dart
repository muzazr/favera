import '../../../shared/models/simulation_model.dart';

abstract class SimulationRepository {
  Future<ImpactSimulation> getImpactSimulation({
    int? monthlyLivingCost,
    int? childCount,
    int? debtAmount,
  });
}
