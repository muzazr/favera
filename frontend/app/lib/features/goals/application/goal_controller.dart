import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/application/dashboard_controller.dart';
import '../../goals/data/goal_repository_provider.dart';
import '../../../shared/models/goal_model.dart';

final goalListControllerProvider =
    AsyncNotifierProvider<GoalListController, List<FinancialGoal>>(
  GoalListController.new,
);

class GoalListController extends AsyncNotifier<List<FinancialGoal>> {
  @override
  Future<List<FinancialGoal>> build() async {
    final repo = ref.watch(goalRepositoryProvider);
    return repo.getGoals();
  }

  Future<FinancialGoal?> createGoal(FinancialGoal goal) async {
    final repo = ref.read(goalRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final created = await repo.createGoal(goal);
      ref.invalidateSelf();
      ref.invalidate(dashboardControllerProvider);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<FinancialGoal?> updateGoal(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final repo = ref.read(goalRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final updated = await repo.updateGoal(id, updates);
      ref.invalidateSelf();
      ref.invalidate(goalDetailControllerProvider(id));
      ref.invalidate(dashboardControllerProvider);
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> deleteGoal(String id) async {
    final repo = ref.read(goalRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final success = await repo.deleteGoal(id);
      ref.invalidateSelf();
      ref.invalidate(dashboardControllerProvider);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final goalDetailControllerProvider = FutureProvider.family
    .autoDispose<FinancialGoal?, String>((ref, String id) async {
  final repo = ref.watch(goalRepositoryProvider);
  return repo.getGoalById(id);
});

final addContributionControllerProvider = StateNotifierProvider.autoDispose<
    AddContributionController, AsyncValue<FinancialGoal?>>((ref) {
  return AddContributionController(ref);
});

class AddContributionController
    extends StateNotifier<AsyncValue<FinancialGoal?>> {
  final Ref ref;

  AddContributionController(this.ref) : super(const AsyncValue.data(null));

  Future<bool> addContribution(
    String goalId, {
    required String sourceName,
    required int amount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(goalRepositoryProvider);
      final updated = await repo.addContribution(
        goalId,
        sourceName: sourceName,
        amount: amount,
      );
      state = AsyncValue.data(updated);
      ref.invalidate(goalListControllerProvider);
      ref.invalidate(goalDetailControllerProvider(goalId));
      ref.invalidate(dashboardControllerProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
