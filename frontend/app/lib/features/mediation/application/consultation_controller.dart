import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/consultation_model.dart';
import '../../auth/application/auth_controller.dart';
import '../data/consultation_repository.dart';
import '../data/mock_consultation_repository.dart';
import '../data/remote_consultation_repository.dart';

final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.recovery);

  if (mode == DataSourceMode.remote) {
    return RemoteConsultationRepository(
      apiClient: ref.watch(apiClientProvider),
    );
  } else {
    return MockConsultationRepository(
      mockStore: ref.watch(mockStoreProvider),
      latency: ref.watch(mockLatencyProvider).defaultDuration,
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

final consultationListControllerProvider =
    AsyncNotifierProvider<ConsultationListController, List<Consultation>>(
  ConsultationListController.new,
);

class ConsultationListController extends AsyncNotifier<List<Consultation>> {
  ConsultationRepository get _repository => ref.read(consultationRepositoryProvider);

  @override
  Future<List<Consultation>> build() async {
    final repo = ref.watch(consultationRepositoryProvider);
    return repo.getConsultations();
  }

  Future<void> refreshList() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async => await _repository.getConsultations());
  }

  Future<Consultation> createConsultation({
    required String professionalId,
    required DateTime scheduledAt,
    String? topic,
  }) async {
    final newConsultation = await _repository.createConsultation(
      professionalId: professionalId,
      scheduledAt: scheduledAt,
      topic: topic,
    );
    ref.invalidateSelf();
    return newConsultation;
  }
}

final consultationDetailControllerProvider = FutureProvider.family
    .autoDispose<Consultation?, String>((ref, id) async {
  final repository = ref.watch(consultationRepositoryProvider);
  return repository.getConsultationDetail(id);
});
