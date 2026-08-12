import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/recovery_model.dart';
import '../../auth/application/auth_controller.dart';
import '../data/mock_recovery_repository.dart';
import '../data/recovery_repository.dart';
import '../data/remote_recovery_repository.dart';

final recoveryRepositoryProvider = Provider<RecoveryRepository>((ref) {
  ref.keepAlive();
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.recovery);

  if (mode == DataSourceMode.remote) {
    return RemoteRecoveryRepository(apiClient: ref.watch(apiClientProvider));
  } else {
    return MockRecoveryRepository(
      mockStore: ref.watch(mockStoreProvider),
      latency: ref.watch(mockLatencyProvider),
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

final recoverySessionListProvider =
    FutureProvider.autoDispose<List<RecoverySession>>((ref) async {
  final repo = ref.watch(recoveryRepositoryProvider);
  return repo.getRecoverySessions();
});

final recoverySessionDetailProvider = FutureProvider.family
    .autoDispose<RecoverySession?, String>((ref, id) async {
  final repo = ref.watch(recoveryRepositoryProvider);
  return repo.getRecoverySession(id);
});

final activeCommitmentsProvider =
    FutureProvider.autoDispose<List<Commitment>>((ref) async {
  final repo = ref.watch(recoveryRepositoryProvider);
  return repo.getCommitments();
});

class RecoveryController extends AsyncNotifier<void> {
  RecoveryRepository get _repository => ref.read(recoveryRepositoryProvider);

  @override
  Future<void> build() async {}

  void _invalidateAll() {
    ref.invalidate(recoverySessionListProvider);
    ref.invalidate(recoverySessionDetailProvider);
    ref.invalidate(activeCommitmentsProvider);
  }

  Future<RecoverySession?> createSession({
    required String title,
    required String topic,
  }) async {
    state = const AsyncValue.loading();
    RecoverySession? created;
    state = await AsyncValue.guard(() async {
      created = await _repository.createRecoverySession(
        title: title,
        topic: topic,
      );
      _invalidateAll();
    });
    return created;
  }

  Future<void> submitReadiness({
    required String sessionId,
    required ReadinessLevel level,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.submitReadiness(sessionId: sessionId, level: level);
      _invalidateAll();
    });
  }

  Future<void> saveReflection({
    required String sessionId,
    required String reflection,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.saveReflection(
        sessionId: sessionId,
        reflection: reflection,
      );
      _invalidateAll();
    });
  }

  Future<void> publishStatement({
    required String sessionId,
    required String statement,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.publishStatement(
        sessionId: sessionId,
        statement: statement,
      );
      _invalidateAll();
    });
  }

  Future<void> simulatePartnerResponse(String sessionId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.simulatePartnerResponse(sessionId);
      _invalidateAll();
    });
  }

  Future<void> createCommitment({
    required String recoverySessionId,
    required String title,
    required String description,
    required DateTime targetDate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createCommitment(
        recoverySessionId: recoverySessionId,
        title: title,
        description: description,
        targetDate: targetDate,
      );
      _invalidateAll();
    });
  }

  Future<void> updateCommitmentProgress({
    required String commitmentId,
    required int progress,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateCommitmentProgress(
        commitmentId: commitmentId,
        progress: progress,
      );
      _invalidateAll();
    });
  }

  Future<void> approveCommitment({
    required String commitmentId,
    String action = 'approve',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.approveCommitment(
        commitmentId: commitmentId,
        action: action,
      );
      _invalidateAll();
    });
  }
}

final recoveryControllerProvider =
    AsyncNotifierProvider<RecoveryController, void>(RecoveryController.new);
