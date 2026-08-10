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
  Future<FamilySpace> createSpace() async {
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
      status: FamilyStatus.pending,
      primaryUserId: user.id,
      createdAt: DateTime.now(),
    );

    mockStore.family = space;
    return space;
  }

  @override
  Future<FamilySpace?> getFamilySpace() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    return mockStore.family;
  }

  @override
  Future<FamilySpace> joinSpace({required String inviteCode}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    final cleanCode = inviteCode.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      throw const ValidationFailure(
          message: 'Masukkan 6 karakter kode undangan pasangan anda');
    }

    final user = mockStore.currentUser;
    final currentFamily = mockStore.family;

    if (currentFamily != null && currentFamily.inviteCode == cleanCode) {
      // Joining own space or valid code
      final joined = currentFamily.copyWith(
        status: FamilyStatus.active,
        partnerUserId: 'usr-budi-002',
        partnerName: 'Budi',
        pairedAt: DateTime.now(),
      );
      mockStore.family = joined;
      return joined;
    }

    // Default mock join space
    final newFamily = FamilySpace(
      id: 'fam-88219',
      inviteCode: cleanCode,
      status: FamilyStatus.active,
      primaryUserId: user?.id ?? 'usr-joselin-001',
      partnerUserId: 'usr-budi-002',
      partnerName: 'Budi',
      createdAt: DateTime.now(),
      pairedAt: DateTime.now(),
    );

    mockStore.family = newFamily;
    return newFamily;
  }

  @override
  Future<void> disconnectSpace({required String spaceId}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    final current = mockStore.family;
    if (current != null && current.id == spaceId) {
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
  Future<List<FamilySpace>> getInvitations() async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final family = mockStore.family;
    if (family != null && family.status == FamilyStatus.pending) {
      return [family];
    }
    return [];
  }

  @override
  Future<FamilySpace> acceptInvitation({required String invitationId}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    final current = mockStore.family;
    if (current == null) {
      throw const NotFoundFailure(message: 'Undangan tidak ditemukan');
    }

    final activeSpace = current.copyWith(
      status: FamilyStatus.active,
      pairedAt: DateTime.now(),
    );
    mockStore.family = activeSpace;
    return activeSpace;
  }

  @override
  Future<void> rejectInvitation({required String invitationId}) async {
    errorPolicy.checkAndThrow();
    await latency.delay();
    mockStore.family = null;
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
}
