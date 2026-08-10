import 'package:dio/dio.dart';
import '../../../shared/models/goal_model.dart';
import 'goal_repository.dart';

class RemoteGoalRepository implements GoalRepository {
  final Dio dio;

  RemoteGoalRepository({required this.dio});

  @override
  Future<List<FinancialGoal>> getGoals() async {
    final response = await dio.get('/goals');
    final data = response.data as List<dynamic>;
    return data
        .map((json) => FinancialGoal.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<FinancialGoal?> getGoalById(String id) async {
    final response = await dio.get('/goals/$id');
    return FinancialGoal.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<FinancialGoal> createGoal(FinancialGoal goal) async {
    final response = await dio.post('/goals', data: goal.toJson());
    return FinancialGoal.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<FinancialGoal> updateGoal(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await dio.patch('/goals/$id', data: updates);
    return FinancialGoal.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> deleteGoal(String id) async {
    final response = await dio.delete('/goals/$id');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<FinancialGoal> approveGoal(String id) async {
    final response = await dio.post('/goals/$id/approval');
    return FinancialGoal.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<FinancialGoal> addContribution(
    String id, {
    required String sourceName,
    required int amount,
  }) async {
    final response = await dio.post(
      '/goals/$id/contributions',
      data: {
        'source_name': sourceName,
        'amount': amount,
      },
    );
    return FinancialGoal.fromJson(response.data as Map<String, dynamic>);
  }
}
