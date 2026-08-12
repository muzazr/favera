import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/models/recovery_model.dart';
import 'recovery_repository.dart';

class RemoteRecoveryRepository implements RecoveryRepository {
  final ApiClient apiClient;

  RemoteRecoveryRepository({required this.apiClient});

  @override
  Future<List<RecoverySession>> getRecoverySessions() async {
    try {
      final response = await apiClient.dio.get('/recovery-sessions');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => RecoverySession.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession?> getRecoverySession(String id) async {
    try {
      final response = await apiClient.dio.get('/recovery-sessions/$id');
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession> createRecoverySession({
    required String title,
    required String topic,
  }) async {
    try {
      final response = await apiClient.dio.post('/recovery-sessions', data: {
        'title': title,
        'topic': topic,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession> submitReadiness({
    required String sessionId,
    required ReadinessLevel level,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/readiness',
        data: {'readiness_level': level.name},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession> saveReflection({
    required String sessionId,
    required String reflection,
  }) async {
    try {
      final response = await apiClient.dio.put(
        '/recovery-sessions/$sessionId/reflection',
        data: {'private_reflection': reflection},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession> publishStatement({
    required String sessionId,
    required String statement,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/publish-statement',
        data: {'published_statement': statement},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession> simulatePartnerResponse(String sessionId) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/partner-response',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession> pauseSession(String sessionId) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/pause',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RecoverySession> completeSession(String sessionId) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/complete',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return RecoverySession.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // --- Commitments ---
  @override
  Future<List<Commitment>> getCommitments() async {
    try {
      final response = await apiClient.dio.get('/commitments');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => Commitment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Commitment> createCommitment({
    required String recoverySessionId,
    required String title,
    required String description,
    required DateTime targetDate,
  }) async {
    try {
      final response = await apiClient.dio.post('/commitments', data: {
        'recovery_session_id': recoverySessionId,
        'title': title,
        'description': description,
        'target_date': targetDate.toUtc().toIso8601String(),
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return Commitment.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Commitment> approveCommitment({
    required String commitmentId,
    String action = 'approve',
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/commitments/$commitmentId/approval',
        data: {'action': action},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return Commitment.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Commitment> updateCommitmentProgress({
    required String commitmentId,
    required int progress,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/commitments/$commitmentId/progress',
        data: {'progress_percentage': progress},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return Commitment.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Commitment> completeCommitment(String commitmentId) async {
    try {
      final response = await apiClient.dio.post(
        '/commitments/$commitmentId/complete',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return Commitment.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppFailure _handleDioError(DioException e) {
    return ApiErrorDecoder.decode(e);
  }
}
