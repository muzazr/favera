import '../../../core/errors/app_failure.dart';
import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_latency.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/recovery_model.dart';
import 'recovery_repository.dart';

class MockRecoveryRepository implements RecoveryRepository {
  final MockStore mockStore;
  final MockLatency latency;
  final MockErrorPolicy errorPolicy;

  MockRecoveryRepository({
    required this.mockStore,
    required this.latency,
    required this.errorPolicy,
  });

  @override
  Future<List<RecoverySession>> getRecoverySessions() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getRecoverySessions();
  }

  @override
  Future<RecoverySession?> getRecoverySession(String id) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getRecoverySession(id);
  }

  @override
  Future<RecoverySession> createRecoverySession({
    required String title,
    required String topic,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.createRecoverySession(title, topic);
  }

  @override
  Future<RecoverySession> submitReadiness({
    required String sessionId,
    required ReadinessLevel level,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final session = mockStore.getRecoverySession(sessionId);

    if (level == ReadinessLevel.unsafe) {
      final updated = session.copyWith(
        readinessLevel: level,
        status: RecoverySessionStatus.mediationRecommended,
        updatedAt: DateTime.now(),
      );
      return mockStore.updateRecoverySession(updated);
    }

    final updated = session.copyWith(
      readinessLevel: level,
      status: RecoverySessionStatus.privateReflection,
      updatedAt: DateTime.now(),
    );
    return mockStore.updateRecoverySession(updated);
  }

  @override
  Future<RecoverySession> saveReflection({
    required String sessionId,
    required String reflection,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final session = mockStore.getRecoverySession(sessionId);
    final updated = session.copyWith(
      privateReflection: reflection,
      updatedAt: DateTime.now(),
    );
    return mockStore.updateRecoverySession(updated);
  }

  @override
  Future<RecoverySession> publishStatement({
    required String sessionId,
    required String statement,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final session = mockStore.getRecoverySession(sessionId);
    final updated = session.copyWith(
      publishedStatement: statement,
      status: RecoverySessionStatus.waitingForPartner,
      updatedAt: DateTime.now(),
    );
    return mockStore.updateRecoverySession(updated);
  }

  @override
  Future<RecoverySession> simulatePartnerResponse(String sessionId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final session = mockStore.getRecoverySession(sessionId);
    final updated = session.copyWith(
      partnerResponseText:
          'Saya memahami kekhawatiranmu. Mari kita atur alokasi hiburan maksimal Rp 1.5M/bulan dan sisanya kita prioritaskan ke tabungan rumah.',
      alignmentSummary:
          'Kedua pihak sepakat membatasi anggaran hiburan bulanan dan mengalokasikan sisa pendapatan untuk tabungan darurat & rumah.',
      status: RecoverySessionStatus.alignment,
      updatedAt: DateTime.now(),
    );
    return mockStore.updateRecoverySession(updated);
  }

  @override
  Future<RecoverySession> pauseSession(String sessionId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final session = mockStore.getRecoverySession(sessionId);
    final updated = session.copyWith(
      status: RecoverySessionStatus.paused,
      updatedAt: DateTime.now(),
    );
    return mockStore.updateRecoverySession(updated);
  }

  @override
  Future<RecoverySession> completeSession(String sessionId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final session = mockStore.getRecoverySession(sessionId);
    final updated = session.copyWith(
      status: RecoverySessionStatus.completed,
      updatedAt: DateTime.now(),
    );
    return mockStore.updateRecoverySession(updated);
  }

  // --- Commitments ---
  @override
  Future<List<Commitment>> getCommitments() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getCommitments();
  }

  @override
  Future<Commitment> createCommitment({
    required String recoverySessionId,
    required String title,
    required String description,
    required DateTime targetDate,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final cmt = mockStore.createCommitment(
      recoverySessionId: recoverySessionId,
      title: title,
      description: description,
      targetDate: targetDate,
    );
    final session = mockStore.getRecoverySession(recoverySessionId);
    mockStore.updateRecoverySession(session.copyWith(
      status: RecoverySessionStatus.commitmentActive,
      updatedAt: DateTime.now(),
    ));
    return cmt;
  }

  @override
  Future<Commitment> approveCommitment({
    required String commitmentId,
    String action = 'approve',
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final list = mockStore.getCommitments();
    final cmt = list.firstWhere(
      (c) => c.id == commitmentId,
      orElse: () =>
          throw const NotFoundFailure(message: 'Komitmen tidak ditemukan'),
    );
    final isApproved = action == 'approve';
    final updated = cmt.copyWith(
      approvedByPartner: isApproved,
      status: isApproved ? CommitmentStatus.active : CommitmentStatus.cancelled,
    );
    return mockStore.updateCommitment(updated);
  }

  @override
  Future<Commitment> updateCommitmentProgress({
    required String commitmentId,
    required int progress,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final list = mockStore.getCommitments();
    final cmt = list.firstWhere(
      (c) => c.id == commitmentId,
      orElse: () =>
          throw const NotFoundFailure(message: 'Komitmen tidak ditemukan'),
    );
    final updated = cmt.copyWith(
      progressPercentage: progress.clamp(0, 100),
      status: progress >= 100
          ? CommitmentStatus.completed
          : CommitmentStatus.active,
    );
    return mockStore.updateCommitment(updated);
  }

  @override
  Future<Commitment> completeCommitment(String commitmentId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final list = mockStore.getCommitments();
    final cmt = list.firstWhere(
      (c) => c.id == commitmentId,
      orElse: () =>
          throw const NotFoundFailure(message: 'Komitmen tidak ditemukan'),
    );
    final updated = cmt.copyWith(
      progressPercentage: 100,
      status: CommitmentStatus.completed,
    );
    return mockStore.updateCommitment(updated);
  }
}
