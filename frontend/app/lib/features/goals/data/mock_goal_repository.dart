import '../../../mock/mock_store.dart';
import '../../../shared/models/goal_model.dart';
import 'goal_repository.dart';

class MockGoalRepository implements GoalRepository {
  final MockStore _store;

  MockGoalRepository({MockStore? store}) : _store = store ?? MockStore();

  @override
  Future<List<FinancialGoal>> getGoals() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _store.getGoals();
  }

  @override
  Future<FinancialGoal?> getGoalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.getGoalById(id);
  }

  @override
  Future<FinancialGoal> createGoal(FinancialGoal goal) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newGoal = goal.id.startsWith('goal-')
        ? goal
        : goal.copyWith(id: 'goal-${DateTime.now().millisecondsSinceEpoch}');
    _store.addGoal(newGoal);
    return newGoal;
  }

  @override
  Future<FinancialGoal> updateGoal(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final existing = _store.getGoalById(id);
    if (existing == null) {
      throw Exception('Target keuangan tidak ditemukan');
    }

    final updated = existing.copyWith(
      name: updates['name'] as String? ?? existing.name,
      targetAmount: updates['target_amount'] as int? ?? existing.targetAmount,
      currentAmount:
          updates['current_amount'] as int? ?? existing.currentAmount,
      deadline: updates['deadline'] as String? ?? existing.deadline,
      themeIcon: updates['theme_icon'] as String? ?? existing.themeIcon,
      contributionScheme: updates['contribution_scheme'] as String? ??
          existing.contributionScheme,
      priority: updates['priority'] as String? ?? existing.priority,
      status: updates['status'] as GoalStatus? ?? existing.status,
    );

    _store.addGoal(updated);
    return updated;
  }

  @override
  Future<bool> deleteGoal(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.removeGoal(id);
  }

  @override
  Future<FinancialGoal> approveGoal(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final existing = _store.getGoalById(id);
    if (existing == null) {
      throw Exception('Target keuangan tidak ditemukan');
    }

    final updated = existing.copyWith(
      approvedByPartner: true,
      status: GoalStatus.active,
    );
    _store.addGoal(updated);
    return updated;
  }

  @override
  Future<FinancialGoal> addContribution(
    String id, {
    required String sourceName,
    required int amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final updated = _store.addContributionToGoal(
      id,
      sourceName: sourceName,
      amount: amount,
    );
    if (updated == null) {
      throw Exception('Target keuangan tidak ditemukan');
    }
    return updated;
  }
}
