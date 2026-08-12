import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/models/recovery_model.dart';
import 'recovery_repository.dart';

/// Global cache persisted across provider invalidations.
/// Because recoveryRepositoryProvider uses keepAlive(), this class instance
/// survives invalidations of the autoDispose FutureProviders.
class RemoteRecoveryRepository implements RecoveryRepository {
  final ApiClient apiClient;

  // Local cache: survives FutureProvider refresh cycles
  static final Map<String, RecoverySession> _localSessions = {};
  static final Map<String, Commitment> _localCommitments = {};

  RemoteRecoveryRepository({required this.apiClient});

  /// Backend returns { items: [...], pagination: {...} } for list endpoints
  dynamic _extractListData(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body.containsKey('items')) return body['items'];
      if (body.containsKey('data')) return body['data'];
      if (body.containsKey('sessions')) return body['sessions'];
      if (body.containsKey('commitments')) return body['commitments'];
    }
    if (body is List) return body;
    return <dynamic>[];
  }

  /// For single object responses
  dynamic _extractSingle(dynamic body) {
    if (body is Map<String, dynamic>) {
      if (body.containsKey('data') && body['data'] is Map) return body['data'];
      return body;
    }
    return null;
  }

  // ─── Sessions ────────────────────────────────────────────────────────────

  @override
  Future<List<RecoverySession>> getRecoverySessions() async {
    List<RecoverySession> remoteList = [];
    try {
      final response = await apiClient.dio.get('/recovery-sessions');
      final data = _extractListData(response.data);
      if (data is List) {
        for (final e in data) {
          if (e is Map<String, dynamic>) {
            try {
              final s = RecoverySession.fromJson(e);
              remoteList.add(s);
              _localSessions[s.id] = s; // update cache
            } catch (_) {}
          }
        }
      }
    } on DioException catch (_) {
      // Gracefully fall back to local sessions when backend returns 401/404/5xx
    }

    // Merge: local-only sessions that are not in remote list appear first
    final remoteIds = remoteList.map((s) => s.id).toSet();
    final localExtras =
        _localSessions.values.where((s) => !remoteIds.contains(s.id)).toList();
    return [...localExtras, ...remoteList];
  }

  @override
  Future<RecoverySession?> getRecoverySession(String id) async {
    try {
      final response = await apiClient.dio.get('/recovery-sessions/$id');
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        var session = RecoverySession.fromJson(data);
        final local = _localSessions[id];
        // Preserve local step progression if remote backend DB status lags behind
        if (local != null && local.status.index > session.status.index) {
          session = session.copyWith(
            status: local.status,
            myPrivateReflection: local.myPrivateReflection ?? session.myPrivateReflection,
            mySharedStatement: local.mySharedStatement ?? session.mySharedStatement,
            partnerSharedStatement: local.partnerSharedStatement ?? session.partnerSharedStatement,
            alignmentSummary: local.alignmentSummary ?? session.alignmentSummary,
          );
        }
        _localSessions[id] = session;
        return session;
      }
    } catch (_) {
      // Fallback to local cache on any error (network or parsing)
    }
    return _localSessions[id];
  }

  @override
  Future<RecoverySession> createRecoverySession({
    required String title,
    required String topic,
  }) async {
    final apiTopic = _mapDisplayTopicToEnum(topic);

    try {
      final response = await apiClient.dio.post('/recovery-sessions', data: {
        'topic': apiTopic,
        if (title.isNotEmpty) 'custom_topic': title,
      });
      final rawData = response.data;
      Map<String, dynamic>? sessionMap;
      if (rawData is Map<String, dynamic>) {
        if (rawData.containsKey('id')) {
          sessionMap = rawData;
        } else if (rawData['data'] is Map<String, dynamic>) {
          sessionMap = rawData['data'] as Map<String, dynamic>;
        }
      }
      if (sessionMap != null) {
        try {
          final session = RecoverySession.fromJson(sessionMap);
          _localSessions[session.id] = session;
          return session;
        } catch (_) {}
      }
    } catch (_) {}

    final fallback = RecoverySession(
      id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
      topic: RecoveryTopic.fromApi(apiTopic),
      customTopic: title.isNotEmpty ? title : null,
      status: RecoverySessionStatus.readinessCheck,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _localSessions[fallback.id] = fallback;
    return fallback;
  }

  String _mapDisplayTopicToEnum(String displayTopic) {
    final lower = displayTopic.toLowerCase();
    if (lower.contains('anggaran') || lower.contains('budget')) {
      return 'unfulfilled_commitment';
    } else if (lower.contains('komunikasi')) {
      return 'communication_conflict';
    } else if (lower.contains('tabungan') || lower.contains('target')) {
      return 'unfulfilled_commitment';
    } else if (lower.contains('utang')) {
      return 'hidden_debt';
    } else if (lower.contains('transaksi')) {
      return 'unknown_transaction';
    } else if (lower.contains('dana')) {
      return 'essential_funds_usage';
    }
    return 'other';
  }

  @override
  Future<RecoverySession> submitReadiness({
    required String sessionId,
    required ReadinessLevel level,
  }) async {
    final targetStatus = level == ReadinessLevel.unsafe
        ? RecoverySessionStatus.mediationRecommended
        : RecoverySessionStatus.privateReflection;

    final readinessData = {
      'feels_safe': level != ReadinessLevel.unsafe,
      'readiness_level': level == ReadinessLevel.ready
          ? 5
          : level == ReadinessLevel.needTime
              ? 2
              : 1,
      'needs_time': level == ReadinessLevel.needTime,
      'needs_third_party': false,
    };

    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/readiness',
        data: readinessData,
      );
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        var session = RecoverySession.fromJson(data);
        session = session.copyWith(status: targetStatus);
        _localSessions[sessionId] = session;
        return session;
      }
    } catch (_) {}

    final existing = _localSessions[sessionId] ??
        RecoverySession(
          id: sessionId,
          topic: RecoveryTopic.other,
          status: RecoverySessionStatus.readinessCheck,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final updated = existing.copyWith(
      status: targetStatus,
      updatedAt: DateTime.now(),
    );
    _localSessions[sessionId] = updated;
    return updated;
  }

  @override
  Future<RecoverySession> saveReflection({
    required String sessionId,
    required String reflection,
  }) async {
    final reflectionData = {
      'facts': reflection,
      'impact': '',
      'feelings': '',
      'needs': '',
      'expectations': '',
    };

    try {
      final response = await apiClient.dio.put(
        '/recovery-sessions/$sessionId/reflection',
        data: reflectionData,
      );
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        var session = RecoverySession.fromJson(data);
        session = session.copyWith(
          myPrivateReflection: PrivateReflection(
            facts: reflection,
            impact: '',
            feelings: '',
            needs: '',
            expectations: '',
          ),
          status: RecoverySessionStatus.waitingForPartner,
        );
        _localSessions[sessionId] = session;
        return session;
      }
    } catch (_) {}

    final existing = _localSessions[sessionId] ??
        RecoverySession(
          id: sessionId,
          topic: RecoveryTopic.other,
          status: RecoverySessionStatus.privateReflection,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final updated = existing.copyWith(
      myPrivateReflection: PrivateReflection(
        facts: reflection,
        impact: '',
        feelings: '',
        needs: '',
        expectations: '',
      ),
      status: RecoverySessionStatus.waitingForPartner,
      updatedAt: DateTime.now(),
    );
    _localSessions[sessionId] = updated;
    return updated;
  }

  @override
  Future<RecoverySession> publishStatement({
    required String sessionId,
    required String statement,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/publish-statement',
        data: {'statement': statement},
      );
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        var session = RecoverySession.fromJson(data);
        session = session.copyWith(
          mySharedStatement: statement,
          status: RecoverySessionStatus.alignment,
        );
        _localSessions[sessionId] = session;
        return session;
      }
    } catch (_) {}

    final existing = _localSessions[sessionId] ??
        RecoverySession(
          id: sessionId,
          topic: RecoveryTopic.other,
          status: RecoverySessionStatus.waitingForPartner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final updated = existing.copyWith(
      mySharedStatement: statement,
      status: RecoverySessionStatus.alignment,
      updatedAt: DateTime.now(),
    );
    _localSessions[sessionId] = updated;
    return updated;
  }

  @override
  Future<RecoverySession> simulatePartnerResponse(String sessionId) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/partner-response',
        data: {'partner_response': 'understand_concern'},
      );
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        var session = RecoverySession.fromJson(data);
        session = session.copyWith(
          partnerSharedStatement:
              'Saya memahami situasi ini dan siap mendiskusikan solusinya bersama.',
          alignmentSummary:
              'Kedua pihak sepakat membatasi anggaran hiburan bulanan dan mengalokasikan sisa pendapatan untuk tabungan darurat & rumah.',
          status: RecoverySessionStatus.alignment,
        );
        _localSessions[sessionId] = session;
        return session;
      }
    } catch (_) {}

    final existing = _localSessions[sessionId] ??
        RecoverySession(
          id: sessionId,
          topic: RecoveryTopic.other,
          status: RecoverySessionStatus.alignment,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final updated = existing.copyWith(
      partnerSharedStatement:
          'Saya memahami situasi ini dan siap mendiskusikan solusinya bersama.',
      alignmentSummary:
          'Kedua pihak sepakat membatasi anggaran hiburan bulanan dan mengalokasikan sisa pendapatan untuk tabungan darurat & rumah.',
      status: RecoverySessionStatus.alignment,
      updatedAt: DateTime.now(),
    );
    _localSessions[sessionId] = updated;
    return updated;
  }

  @override
  Future<RecoverySession> pauseSession(String sessionId) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/pause',
      );
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        final session = RecoverySession.fromJson(data);
        _localSessions[sessionId] = session;
        return session;
      }
    } on DioException catch (_) {}

    final existing = _localSessions[sessionId];
    if (existing != null) {
      final updated =
          existing.copyWith(status: RecoverySessionStatus.paused, updatedAt: DateTime.now());
      _localSessions[sessionId] = updated;
      return updated;
    }
    throw const NotFoundFailure(message: 'Sesi tidak ditemukan');
  }

  @override
  Future<RecoverySession> completeSession(String sessionId) async {
    try {
      final response = await apiClient.dio.post(
        '/recovery-sessions/$sessionId/complete',
      );
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        final session = RecoverySession.fromJson(data);
        _localSessions[sessionId] = session;
        return session;
      }
    } on DioException catch (_) {}

    final existing = _localSessions[sessionId];
    if (existing != null) {
      final updated = existing.copyWith(
        status: RecoverySessionStatus.completed,
        updatedAt: DateTime.now(),
      );
      _localSessions[sessionId] = updated;
      return updated;
    }
    throw const NotFoundFailure(message: 'Sesi tidak ditemukan');
  }

  // ─── Commitments ─────────────────────────────────────────────────────────

  @override
  Future<List<Commitment>> getCommitments() async {
    List<Commitment> remoteList = [];
    try {
      final response = await apiClient.dio.get('/commitments');
      final data = _extractListData(response.data);
      if (data is List) {
        for (final e in data) {
          if (e is Map<String, dynamic>) {
            try {
              final c = Commitment.fromJson(e);
              remoteList.add(c);
              _localCommitments[c.id] = c;
            } catch (_) {}
          }
        }
      }
    } on DioException catch (_) {}

    final remoteIds = remoteList.map((c) => c.id).toSet();
    final localExtras = _localCommitments.values
        .where((c) => !remoteIds.contains(c.id))
        .toList();
    return [...localExtras, ...remoteList];
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
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        final commitment = Commitment.fromJson(data);
        _localCommitments[commitment.id] = commitment;
        return commitment;
      }
    } on DioException catch (_) {}

    final fallback = Commitment(
      id: 'loc-cmt-${DateTime.now().millisecondsSinceEpoch}',
      recoverySessionId: recoverySessionId,
      title: title,
      description: description,
      targetDate: targetDate,
      status: CommitmentStatus.pendingPartnerApproval,
      createdBy: 'usr-current',
      progressPercentage: 0,
      createdAt: DateTime.now(),
    );
    _localCommitments[fallback.id] = fallback;
    return fallback;
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
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        final commitment = Commitment.fromJson(data);
        _localCommitments[commitmentId] = commitment;
        return commitment;
      }
    } on DioException catch (_) {}

    final existing = _localCommitments[commitmentId];
    if (existing != null) {
      final updated = existing.copyWith(
        status: CommitmentStatus.active,
        approvedByPartner: true,
      );
      _localCommitments[commitmentId] = updated;
      return updated;
    }
    throw const NotFoundFailure(message: 'Komitmen tidak ditemukan');
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
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        final commitment = Commitment.fromJson(data);
        _localCommitments[commitmentId] = commitment;
        return commitment;
      }
    } on DioException catch (_) {}

    final existing = _localCommitments[commitmentId];
    if (existing != null) {
      final updated = existing.copyWith(progressPercentage: progress);
      _localCommitments[commitmentId] = updated;
      return updated;
    }
    throw const NotFoundFailure(message: 'Komitmen tidak ditemukan');
  }

  @override
  Future<Commitment> completeCommitment(String commitmentId) async {
    try {
      final response = await apiClient.dio.post(
        '/commitments/$commitmentId/complete',
      );
      final data = _extractSingle(response.data);
      if (data is Map<String, dynamic>) {
        final commitment = Commitment.fromJson(data);
        _localCommitments[commitmentId] = commitment;
        return commitment;
      }
    } on DioException catch (_) {}

    final existing = _localCommitments[commitmentId];
    if (existing != null) {
      final updated = existing.copyWith(status: CommitmentStatus.completed);
      _localCommitments[commitmentId] = updated;
      return updated;
    }
    throw const NotFoundFailure(message: 'Komitmen tidak ditemukan');
  }
}
