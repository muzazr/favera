import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/goal_model.dart';
import 'goal_repository.dart';

class RemoteGoalRepository implements GoalRepository {
  final ApiClient _apiClient;

  RemoteGoalRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  static dynamic _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  @override
  Future<List<FinancialGoal>> getGoals({String? cursor, int limit = 20}) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
      final response = await _apiClient.dio.get(
        '/goals',
        queryParameters: query,
      );
      final raw = _unwrap(response.data);
      if (raw is List) {
        return raw
            .map((j) => FinancialGoal.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      // Handle paginated response shape { items: [...] }
      final items = (raw as Map<String, dynamic>)['items'] as List<dynamic>? ??
          (raw['goals'] as List<dynamic>?) ??
          [];
      return items
          .map((j) => FinancialGoal.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FinancialGoal?> getGoalById(String id) async {
    try {
      final response = await _apiClient.dio.get('/goals/$id');
      final raw = _unwrap(response.data);
      return FinancialGoal.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FinancialGoal> createGoal(FinancialGoal goal) async {
    try {
      // Send only CreateGoalRequest-compatible fields, no id/created_at.
      final body = <String, dynamic>{
        'name': goal.name,
        'target_amount': goal.targetAmount,
        'deadline': goal.deadline,
        'theme_icon': goal.themeIcon,
        'contribution_scheme': goal.contributionScheme,
        'priority': goal.priority,
      };
      final response = await _apiClient.dio.post('/goals', data: body);
      final raw = _unwrap(response.data);
      return FinancialGoal.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FinancialGoal> updateGoal(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.dio.patch('/goals/$id', data: updates);
      final raw = _unwrap(response.data);
      return FinancialGoal.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<bool> deleteGoal(String id) async {
    try {
      await _apiClient.dio.delete('/goals/$id');
      return true;
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FinancialGoal> approveGoal(String id, {String action = 'approve'}) async {
    try {
      final response = await _apiClient.dio.post(
        '/goals/$id/approval',
        data: {'action': action},
      );
      final raw = _unwrap(response.data);
      return FinancialGoal.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<GoalContribution> addContribution(
    String id, {
    required int amount,
    String? transactionId,
    String? note,
  }) async {
    try {
      final body = <String, dynamic>{'amount': amount};
      if (transactionId != null && transactionId.isNotEmpty) {
        body['transaction_id'] = transactionId;
      }
      if (note != null && note.isNotEmpty) body['note'] = note;

      final response = await _apiClient.dio.post(
        '/goals/$id/contributions',
        data: body,
      );
      final raw = _unwrap(response.data);
      return GoalContribution.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
