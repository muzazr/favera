import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/professional_model.dart';
import '../../auth/application/auth_controller.dart';
import '../data/mock_professional_repository.dart';
import '../data/professional_repository.dart';
import '../data/remote_professional_repository.dart';

final professionalRepositoryProvider = Provider<ProfessionalRepository>((ref) {
  ref.keepAlive();
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.professionals);

  if (mode == DataSourceMode.remote) {
    return RemoteProfessionalRepository(
        apiClient: ref.watch(apiClientProvider));
  } else {
    return MockProfessionalRepository(
      mockStore: ref.watch(mockStoreProvider),
      latency: ref.watch(mockLatencyProvider),
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

final professionalListProvider = FutureProvider.family
    .autoDispose<List<Professional>, String?>((ref, category) async {
  final repo = ref.watch(professionalRepositoryProvider);
  return repo.getProfessionals(category: category);
});
