import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/recovery/data/mock_recovery_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_error_policy.dart';
import 'package:app/mock/mock_latency.dart';
import 'package:app/mock/mock_store.dart';
import 'package:app/shared/models/recovery_model.dart';

void main() {
  group('MockRecoveryRepository Tests', () {
    late MockStore store;
    late MockRecoveryRepository repository;

    setUp(() {
      store = MockStore(clock: MockClock())..resetToSeed(preAuthenticate: true);
      repository = MockRecoveryRepository(
        mockStore: store,
        latency: const MockLatency(isFastMode: true),
        errorPolicy: MockErrorPolicy(),
      );
    });

    test('getRecoverySessions returns seeded recovery sessions', () async {
      final sessions = await repository.getRecoverySessions();
      expect(sessions.isNotEmpty, isTrue);
      expect(sessions.first.id, equals('rec-demo-001'));
    });

    test('submitReadiness with unsafe level triggers safety override state',
        () async {
      final updated = await repository.submitReadiness(
        sessionId: 'rec-demo-001',
        level: ReadinessLevel.unsafe,
      );
      // readinessLevel is now encoded in myReadiness.readinessLevel (int 1–5)
      // after submitReadiness the unsafe path triggers mediationRecommended
      expect(
          updated.status, equals(RecoverySessionStatus.mediationRecommended));
    });

    test('publishStatement updates published statement and waiting status',
        () async {
      final updated = await repository.publishStatement(
        sessionId: 'rec-demo-001',
        statement: 'Saya ingin kesepakatan batas anggaran hiburan.',
      );
      expect(updated.publishedStatement, contains('anggaran hiburan'));
      expect(updated.status, equals(RecoverySessionStatus.waitingForPartner));
    });

    test(
        'simulatePartnerResponse updates partner response and alignment status',
        () async {
      final updated = await repository.simulatePartnerResponse('rec-demo-001');
      // partnerResponseText getter maps to partnerSharedStatement
      expect(updated.partnerResponseText, isNotNull);
      // alignmentSummary is a direct String? field
      expect(updated.alignmentSummary, isNotNull);
      expect(updated.status, equals(RecoverySessionStatus.alignment));
    });

    test('createCommitment creates new active commitment', () async {
      final cmt = await repository.createCommitment(
        recoverySessionId: 'rec-demo-001',
        title: 'Batas Anggaran Hiburan',
        description: 'Maksimal Rp 1.5M/bulan',
        targetDate: DateTime.now().add(const Duration(days: 30)),
      );
      expect(cmt.title, equals('Batas Anggaran Hiburan'));
      expect(cmt.status, equals(CommitmentStatus.active));
    });

    test('updateCommitmentProgress updates progress percentage', () async {
      final cmt = await repository.createCommitment(
        recoverySessionId: 'rec-demo-001',
        title: 'Batas Anggaran Hiburan',
        description: 'Maksimal Rp 1.5M/bulan',
        targetDate: DateTime.now().add(const Duration(days: 30)),
      );

      final updated = await repository.updateCommitmentProgress(
        commitmentId: cmt.id,
        progress: 80,
      );
      expect(updated.progressPercentage, equals(80));
    });

    test('approveCommitment approves and activates commitment', () async {
      final cmt = await repository.createCommitment(
        recoverySessionId: 'rec-demo-001',
        title: 'Komitmen Tes',
        description: 'Deskripsi tes',
        targetDate: DateTime.now().add(const Duration(days: 30)),
      );

      final approved = await repository.approveCommitment(
        commitmentId: cmt.id,
        action: 'approve',
      );
      expect(approved.approvedByPartner, isTrue);
      expect(approved.status, equals(CommitmentStatus.active));
    });
  });
}
