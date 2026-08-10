import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/mediation/data/mock_professional_repository.dart';
import 'package:app/features/mediation/data/mock_simulation_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_error_policy.dart';
import 'package:app/mock/mock_latency.dart';
import 'package:app/mock/mock_store.dart';

void main() {
  group('MockMediationRepositories Tests', () {
    late MockStore store;
    late MockProfessionalRepository profRepo;
    late MockSimulationRepository simRepo;

    setUp(() {
      store = MockStore(clock: MockClock())..resetToSeed(preAuthenticate: true);
      profRepo = MockProfessionalRepository(
        mockStore: store,
        latency: const MockLatency(isFastMode: true),
        errorPolicy: MockErrorPolicy(),
      );
      simRepo = MockSimulationRepository(
        mockStore: store,
        latency: const MockLatency(isFastMode: true),
        errorPolicy: MockErrorPolicy(),
      );
    });

    test('getProfessionals returns seeded list of professionals', () async {
      final list = await profRepo.getProfessionals();
      expect(list.isNotEmpty, isTrue);
      expect(list.first.name, equals('Dra. Sarah Amelia, M.Psi'));
      expect(list.first.schedule, contains('Senin - Jumat'));
    });

    test('getProfessionals filters by category correctly', () async {
      final list = await profRepo.getProfessionals(category: 'psikolog');
      expect(list.every((p) => p.category == 'psikolog'), isTrue);
    });

    test('getImpactSimulation returns deterministic impact projection',
        () async {
      final sim = await simRepo.getImpactSimulation();
      expect(sim.monthlyLivingCost, equals(12500000));
      expect(sim.disclaimer, isNotEmpty);
    });
  });
}
