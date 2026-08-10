import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_latency.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/professional_model.dart';
import 'professional_repository.dart';

class MockProfessionalRepository implements ProfessionalRepository {
  final MockStore mockStore;
  final MockLatency latency;
  final MockErrorPolicy errorPolicy;

  MockProfessionalRepository({
    required this.mockStore,
    required this.latency,
    required this.errorPolicy,
  });

  @override
  Future<List<Professional>> getProfessionals({String? category}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getProfessionals(category);
  }

  @override
  Future<Professional?> getProfessionalDetail(String id) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final list = mockStore.getProfessionals();
    return list.firstWhere((p) => p.id == id, orElse: () => list.first);
  }
}
