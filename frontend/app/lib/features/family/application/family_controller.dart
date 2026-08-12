import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/router/route_redirect.dart';
import '../../../core/config/app_config.dart';
import '../../../core/config/data_source_mode.dart';
import '../../../mock/mock_providers.dart';
import '../../../shared/models/family_model.dart';
import '../../auth/application/auth_controller.dart';
import '../data/family_repository.dart';
import '../data/mock_family_repository.dart';
import '../data/remote_family_repository.dart';
import '../../../shared/models/check_in_model.dart';

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  ref.keepAlive();
  final config = ref.watch(appConfigProvider);
  final mode = config.dataSourceFor(DataDomain.family);

  if (mode == DataSourceMode.remote) {
    return RemoteFamilyRepository(apiClient: ref.watch(apiClientProvider));
  } else {
    return MockFamilyRepository(
      mockStore: ref.watch(mockStoreProvider),
      latency: ref.watch(mockLatencyProvider),
      errorPolicy: ref.watch(mockErrorPolicyProvider),
    );
  }
});

final familyInvitationsProvider =
    FutureProvider.autoDispose<List<FamilyInvitation>>((ref) async {
  final repo = ref.watch(familyRepositoryProvider);
  return repo.getInvitations();
});

final weeklyCheckInControllerProvider =
    FutureProvider.autoDispose<WeeklyCheckIn?>((ref) async {
  final repo = ref.watch(familyRepositoryProvider);
  return repo.getCurrentCheckIn();
});

final familyAssessmentControllerProvider =
    FutureProvider.autoDispose<FamilyAssessment?>((ref) async {
  final repo = ref.watch(familyRepositoryProvider);
  return repo.getCurrentFamilyAssessment();
});

class FamilyController extends AsyncNotifier<FamilySpace?> {
  late final FamilyRepository _repository;

  @override
  Future<FamilySpace?> build() async {
    _repository = ref.watch(familyRepositoryProvider);
    final space = await _repository.getFamilySpace();
    _syncRouteState(space);
    return space;
  }

  void _syncRouteState(FamilySpace? space) {
    final routeNotifier = ref.read(routeStateProvider.notifier);
    final isPaired = space != null && space.status == FamilyStatus.active;
    routeNotifier.setFamilyPaired(isPaired);
  }

  Future<FamilyInvitation?> createInvitation({String? inviteeEmail}) async {
    try {
      final invitation = await _repository.createInvitation(inviteeEmail: inviteeEmail);
      final space = await _repository.getFamilySpace();
      state = AsyncValue.data(space);
      _syncRouteState(space);
      ref.invalidate(familyInvitationsProvider);
      return invitation;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> acceptInvitation(
    String inviteCode, {
    bool grantFinancialConsent = true,
    bool grantCheckInConsent = true,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final currentSpace = await _repository.getFamilySpace();
        if (currentSpace != null && currentSpace.status == FamilyStatus.pendingPairing) {
          await _repository.disconnectFamily();
        }
      } catch (_) {}

      final space = await _repository.acceptInvitation(
        inviteCode: inviteCode,
        grantFinancialConsent: grantFinancialConsent,
        grantCheckInConsent: grantCheckInConsent,
      );
      _syncRouteState(space);
      ref.invalidate(familyInvitationsProvider);
      return space;
    });
    return state.hasValue && state.value?.status == FamilyStatus.active;
  }

  Future<bool> joinSpace(String inviteCode) async {
    return acceptInvitation(inviteCode);
  }

  Future<bool> rejectInvitation(String inviteCode) async {
    try {
      await _repository.rejectInvitation(inviteCode: inviteCode);
      ref.invalidate(familyInvitationsProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnectSpace(String spaceId, {String? password, String? reason}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.disconnectFamily(password: password, reason: reason);
      state = const AsyncValue.data(null);
      _syncRouteState(null);
      ref.invalidate(familyInvitationsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<WeeklyCheckIn> submitCheckIn({
    required String checkInId,
    required String emotion,
    required String concern,
  }) async {
    final repo = ref.read(familyRepositoryProvider);
    final updated = await repo.submitCheckInAnswers(
      checkInId: checkInId,
      emotion: emotion,
      concern: concern,
    );
    ref.invalidate(weeklyCheckInControllerProvider);
    ref.invalidate(familyAssessmentControllerProvider);
    return updated;
  }

  Future<WeeklyCheckIn?> simulatePartnerSubmit(String checkInId) async {
    final repo = ref.read(familyRepositoryProvider);
    final updated = await repo.simulatePartnerSubmit(checkInId);
    ref.invalidate(weeklyCheckInControllerProvider);
    ref.invalidate(familyAssessmentControllerProvider);
    return updated;
  }
}

final familyControllerProvider =
    AsyncNotifierProvider<FamilyController, FamilySpace?>(FamilyController.new);

final myInviteCodeProvider = FutureProvider.autoDispose<String>((ref) async {
  final repo = ref.watch(familyRepositoryProvider);

  final space = await repo.getFamilySpace();
  if (space != null) {
    if (space.inviteCode != null && space.inviteCode!.isNotEmpty) {
      return space.inviteCode!;
    }
    if (space.status == FamilyStatus.active) {
      return 'TERHUBUNG';
    }
  }

  try {
    final invitations = await repo.getInvitations();
    final currentUser = ref.read(authControllerProvider).value;
    if (currentUser != null) {
      final myPending = invitations.where((inv) =>
          inv.status == 'pending' && inv.inviterUserId == currentUser.id);
      if (myPending.isNotEmpty) {
        return myPending.first.inviteCode;
      }
    }

    final newInv = await repo.createInvitation();
    return newInv.inviteCode;
  } catch (_) {
    return space?.inviteCode ?? 'TERHUBUNG';
  }
});
