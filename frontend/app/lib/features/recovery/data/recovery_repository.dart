import '../../../shared/models/recovery_model.dart';

abstract class RecoveryRepository {
  Future<List<RecoverySession>> getRecoverySessions();
  Future<RecoverySession?> getRecoverySession(String id);
  Future<RecoverySession> createRecoverySession({
    required String title,
    required String topic,
  });
  Future<RecoverySession> submitReadiness({
    required String sessionId,
    required ReadinessLevel level,
  });
  Future<RecoverySession> saveReflection({
    required String sessionId,
    required String reflection,
  });
  Future<RecoverySession> publishStatement({
    required String sessionId,
    required String statement,
  });
  Future<RecoverySession> simulatePartnerResponse(String sessionId);
  Future<RecoverySession> pauseSession(String sessionId);
  Future<RecoverySession> completeSession(String sessionId);

  // Commitments
  Future<List<Commitment>> getCommitments();
  Future<Commitment> createCommitment({
    required String recoverySessionId,
    required String title,
    required String description,
    required DateTime targetDate,
  });
  Future<Commitment> approveCommitment({
    required String commitmentId,
    String action = 'approve',
  });
  Future<Commitment> updateCommitmentProgress({
    required String commitmentId,
    required int progress,
  });
  Future<Commitment> completeCommitment(String commitmentId);
}
