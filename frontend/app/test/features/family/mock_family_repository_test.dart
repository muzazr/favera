import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/family/data/mock_family_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_error_policy.dart';
import 'package:app/mock/mock_latency.dart';
import 'package:app/mock/mock_store.dart';
import 'package:app/shared/models/check_in_model.dart';
import 'package:app/shared/models/family_model.dart';

void main() {
  group('MockFamilyRepository Tests', () {
    late MockStore store;
    late MockFamilyRepository repository;

    setUp(() {
      store = MockStore(clock: MockClock())..resetToSeed(preAuthenticate: true);
      repository = MockFamilyRepository(
        mockStore: store,
        latency: const MockLatency(isFastMode: true),
        errorPolicy: MockErrorPolicy(),
      );
    });

    test('createInvitation generates a valid invite code and pending invitation',
        () async {
      final invitation = await repository.createInvitation();
      expect(invitation.inviteCode.startsWith('FAV-'), isTrue);
      expect(invitation.status, equals('pending'));
    });

    test('acceptInvitation with valid code transitions family to active paired status',
        () async {
      final joined = await repository.acceptInvitation(inviteCode: 'FAV-88219');
      expect(joined.status, equals(FamilyStatus.active));
      expect(joined.partnerName, equals('Budi'));
    });

    test('disconnectFamily marks family space as disconnected', () async {
      await repository.acceptInvitation(inviteCode: 'FAV-88219');
      await repository.disconnectFamily(password: 'Password123!');

      final current = await repository.getFamilySpace();
      expect(current?.status, equals(FamilyStatus.disconnected));
      expect(current?.partnerUserId, isNull);
    });

    test('submitCheckInAnswers updates emotion, concern, and status', () async {
      final updated = await repository.submitCheckInAnswers(
        checkInId: 'chk-week-32',
        emotion: 'damai',
        concern: 'keuangan',
      );
      expect(updated.myEmotion, equals('damai'));
      expect(updated.mainConcern, equals('keuangan'));
      expect(updated.status, equals(CheckInStatus.completed));
    });

    test('getCurrentFamilyAssessment returns active family assessment',
        () async {
      final assessment = await repository.getCurrentFamilyAssessment();
      expect(assessment, isNotNull);
      expect(assessment?.level, equals(AssessmentLevel.stable));
      expect(assessment?.summaryText, contains('stabil'));
    });

    test('getFamilyAssessmentNarrative returns mock narrative',
        () async {
      final narrative = await repository.getFamilyAssessmentNarrative('asm-001');
      expect(narrative, isNotNull);
      expect(narrative?.headline, equals('Aman & Terkendali'));
      expect(narrative?.overview, contains('Budi dan Siti'));
    });
  });
}
