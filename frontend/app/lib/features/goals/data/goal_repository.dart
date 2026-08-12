import '../../../shared/models/goal_model.dart';

abstract class GoalRepository {
  Future<List<FinancialGoal>> getGoals();
  Future<FinancialGoal?> getGoalById(String id);
  Future<FinancialGoal> createGoal(FinancialGoal goal);
  Future<FinancialGoal> updateGoal(String id, Map<String, dynamic> updates);
  Future<bool> deleteGoal(String id);

  /// [action]: 'approve' | 'reject'
  Future<FinancialGoal> approveGoal(String id, {String action = 'approve'});

  Future<GoalContribution> addContribution(
    String id, {
    required int amount,
    String? transactionId,
    String? note,
  });
}
