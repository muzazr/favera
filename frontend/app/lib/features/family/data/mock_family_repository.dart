import '../../../core/errors/app_failure.dart';
import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_latency.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/check_in_model.dart';
import '../../../shared/models/family_model.dart';
import 'family_repository.dart';

class MockFamilyRepository implements FamilyRepository {
  final MockStore mockStore;
  final MockLatency latency;
  final MockErrorPolicy errorPolicy;

  MockFamilyRepository({
    required this.mockStore,
    required this.latency,
    required this.errorPolicy,
  });

  @override
  Future<FamilySpace?> getFamilySpace() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.family;
  }

  @override
  Future<List<FamilyInvitation>> getInvitations() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final family = mockStore.family;
    if (family != null && family.status == FamilyStatus.pendingPairing && family.inviteCode != null) {
      return [
        FamilyInvitation(
          id: 'inv-1',
          inviteCode: family.inviteCode!,
          inviterName: family.partnerName ?? 'Pasangan',
          status: 'pending',
          createdAt: family.createdAt,
        ),
      ];
    }
    return [];
  }

  @override
  Future<FamilyInvitation> createInvitation({String? inviteeEmail}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    final user = mockStore.currentUser;
    if (user == null) {
      throw const AuthFailure(message: 'Sesi anda telah berakhir');
    }

    final code =
        'FAV-${(10000 + (DateTime.now().millisecondsSinceEpoch % 89999)).toString()}';

    final space = FamilySpace(
      id: 'fam-${DateTime.now().millisecondsSinceEpoch}',
      inviteCode: code,
      status: FamilyStatus.pendingPairing,
      primaryUserId: user.id,
      createdAt: DateTime.now(),
    );

    mockStore.family = space;
    return FamilyInvitation(
      id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
      inviteCode: code,
      inviterUserId: user.id,
      inviterName: user.name,
      inviteeEmail: inviteeEmail,
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<FamilySpace> acceptInvitation({
    required String inviteCode,
    bool grantFinancialConsent = true,
    bool grantCheckInConsent = true,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    final user = mockStore.currentUser;
    final activeSpace = FamilySpace(
      id: 'fam-88219',
      inviteCode: inviteCode,
      status: FamilyStatus.active,
      primaryUserId: user?.id ?? 'usr-joselin-001',
      partnerUserId: 'usr-budi-002',
      partnerName: 'Budi',
      shareFinancialSummary: grantFinancialConsent,
      shareCheckInSummary: grantCheckInConsent,
      createdAt: DateTime.now(),
      pairedAt: DateTime.now(),
    );
    mockStore.family = activeSpace;
    return activeSpace;
  }

  @override
  Future<FamilyInvitation> rejectInvitation({required String inviteCode}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    mockStore.family = null;
    return FamilyInvitation(
      id: 'inv-rejected',
      inviteCode: inviteCode,
      status: 'rejected',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteInvitation({required String invitationId}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    mockStore.family = null;
  }

  @override
  Future<FamilySpace> updateSettings(Map<String, dynamic> settings) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final current = mockStore.family;
    if (current == null) {
      throw const NotFoundFailure(message: 'Ruang keluarga tidak ditemukan');
    }
    mockStore.family = current;
    return current;
  }

  @override
  Future<FamilySpace> updateConsents({
    required bool shareFinancialSummary,
    required bool shareCheckInSummary,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final current = mockStore.family;
    if (current == null) {
      throw const NotFoundFailure(message: 'Ruang keluarga tidak ditemukan');
    }
    final updated = current.copyWith(
      shareFinancialSummary: shareFinancialSummary,
      shareCheckInSummary: shareCheckInSummary,
    );
    mockStore.family = updated;
    return updated;
  }

  @override
  Future<void> disconnectFamily({String? password, String? reason}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    final current = mockStore.family;
    if (current != null) {
      mockStore.family = FamilySpace(
        id: current.id,
        inviteCode: current.inviteCode,
        status: FamilyStatus.disconnected,
        primaryUserId: current.primaryUserId,
        partnerUserId: null,
        partnerName: null,
        createdAt: current.createdAt,
      );
    }
  }

  @override
  Future<WeeklyCheckIn?> getCurrentCheckIn() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getCurrentCheckIn();
  }

  @override
  Future<WeeklyCheckIn> submitCheckInAnswers({
    required String checkInId,
    required String emotion,
    required String concern,
  }) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.submitCheckIn(checkInId, emotion, concern);
  }

  @override
  Future<WeeklyCheckIn?> simulatePartnerSubmit(String checkInId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.simulatePartnerSubmit(checkInId);
  }

  @override
  Future<FamilyAssessment?> getCurrentFamilyAssessment() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.getCurrentFamilyAssessment();
  }

  @override
  Future<FamilyAssessmentNarrative?> getFamilyAssessmentNarrative(String assessmentId) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return FamilyAssessmentNarrative(
      headline: 'Aman & Terkendali',
      overview: 'Berdasarkan check-in mingguan terbaru, hubungan komunikasi Budi dan Siti berjalan sangat harmonis. Arus kas positif ditunjang oleh pemahaman bersama atas batas pengeluaran gaya hidup.',
      actionPlan: const NarrativeActionPlan(
        title: 'Rencana Aksi Finansial',
        description: 'Pertahankan komitmen tabungan dan terus selaraskan pengeluaran harian.',
      ),
      encouragement: 'Teruskan keterbukaan ini untuk membangun ketahanan finansial masa depan!',
      domainHighlights: const [
        NarrativeDomainHighlight(
          domain: 'Keuangan',
          status: 'stable',
          note: 'Arus kas positif dengan tingkat tabungan yang sehat.',
        ),
        NarrativeDomainHighlight(
          domain: 'Komunikasi',
          status: 'stable',
          note: 'Komunikasi transparan dengan tingkat stres emosional yang rendah.',
        ),
      ],
      meta: NarrativeMeta(
        isPartial: false,
        isFallback: false,
        generatedAt: DateTime.now(),
      ),
    );
  }
}
