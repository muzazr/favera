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

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
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

  Future<FamilySpace?> createSpace() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final space = await _repository.createSpace();
      _syncRouteState(space);
      return space;
    });
    return state.value;
  }

  Future<bool> joinSpace(String inviteCode) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final space = await _repository.joinSpace(inviteCode: inviteCode);
      _syncRouteState(space);
      return space;
    });
    return state.hasValue && state.value?.status == FamilyStatus.active;
  }

  Future<void> disconnectSpace(String spaceId) async {
    state = const AsyncValue.loading();
    await _repository.disconnectSpace(spaceId: spaceId);
    final space = await _repository.getFamilySpace();
    state = AsyncValue.data(space);
    _syncRouteState(space);
  }
}

final familyControllerProvider =
    AsyncNotifierProvider<FamilyController, FamilySpace?>(FamilyController.new);
