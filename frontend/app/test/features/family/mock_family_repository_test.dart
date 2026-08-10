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

    test('createSpace generates a valid invite code and pending space',
        () async {
      final space = await repository.createSpace();
      expect(space.inviteCode.startsWith('FAV-'), isTrue);
      expect(space.status, equals(FamilyStatus.pending));
    });

    test('joinSpace with valid code transitions family to active paired status',
        () async {
      final joined = await repository.joinSpace(inviteCode: 'FAV-88219');
      expect(joined.status, equals(FamilyStatus.active));
      expect(joined.partnerName, equals('Budi'));
    });

    test('disconnectSpace marks family space as disconnected', () async {
      await repository.joinSpace(inviteCode: 'FAV-88219');
      await repository.disconnectSpace(spaceId: 'fam-88219');

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
  });
}
