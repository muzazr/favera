import '../../../shared/models/goal_model.dart';

abstract class GoalRepository {
  Future<List<FinancialGoal>> getGoals();
  Future<FinancialGoal?> getGoalById(String id);
  Future<FinancialGoal> createGoal(FinancialGoal goal);
  Future<FinancialGoal> updateGoal(String id, Map<String, dynamic> updates);
  Future<bool> deleteGoal(String id);
  Future<FinancialGoal> approveGoal(String id);
  Future<FinancialGoal> addContribution(
    String id, {
    required String sourceName,
    required int amount,
  });
}
