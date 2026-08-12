import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/goal_model.dart';
import 'goal_repository.dart';

class RemoteGoalRepository implements GoalRepository {
  final ApiClient _apiClient;
  final Map<String, List<GoalContribution>> _userAddedContributions = {};

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
      List<FinancialGoal> list = [];
      if (raw is List) {
        list = raw
            .map((j) => FinancialGoal.fromJson(j as Map<String, dynamic>))
            .toList();
      } else if (raw is Map<String, dynamic>) {
        final items = (raw['items'] as List<dynamic>?) ??
            (raw['goals'] as List<dynamic>?) ??
            [];
        list = items
            .map((j) => FinancialGoal.fromJson(j as Map<String, dynamic>))
            .toList();
      }

      // Merge local added contributions into goals list if not yet present
      return list.map((goal) {
        final extras = _userAddedContributions[goal.id] ?? [];
        if (extras.isEmpty) return goal;
        final existingIds = goal.contributions.map((c) => c.id).toSet();
        final newContribs = extras.where((c) => !existingIds.contains(c.id)).toList();
        if (newContribs.isEmpty) return goal;
        return goal.copyWith(
          contributions: [...newContribs, ...goal.contributions],
        );
      }).toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 401 || status == 403 || status == 400) {
        return [];
      }
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FinancialGoal?> getGoalById(String id) async {
    try {
      final response = await _apiClient.dio.get('/goals/$id');
      final raw = _unwrap(response.data);
      if (raw is Map<String, dynamic>) {
        final goal = FinancialGoal.fromJson(raw);
        final extras = _userAddedContributions[id] ?? [];
        if (extras.isNotEmpty) {
          final existingIds = goal.contributions.map((c) => c.id).toSet();
          final newContribs = extras.where((c) => !existingIds.contains(c.id)).toList();
          if (newContribs.isNotEmpty) {
            return goal.copyWith(
              contributions: [...newContribs, ...goal.contributions],
            );
          }
        }
        return goal;
      }
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  String _mapSchemeToApi(String scheme) {
    switch (scheme) {
      case 'Dari Saldo Bersama':
      case 'shared_balance':
        return 'shared_balance';
      case 'Patungan Proporsional':
      case 'proportional':
        return 'proportional';
      default:
        return 'manual';
    }
  }

  String _mapPriorityToApi(String priority) {
    switch (priority) {
      case 'Sangat Penting':
      case 'very_important':
        return 'very_important';
      case 'Fleksibel':
      case 'flexible':
        return 'flexible';
      case 'Penting':
      case 'important':
      default:
        return 'important';
    }
  }

  String? _mapDeadlineToApi(String deadline) {
    if (deadline.isEmpty) return null;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(deadline)) {
      return deadline;
    }
    final parts = deadline.split(' ');
    if (parts.length == 2) {
      final monthName = parts[0];
      final yearStr = parts[1];
      const months = {
        'Januari': '01',
        'Februari': '02',
        'Maret': '03',
        'April': '04',
        'Mei': '05',
        'Juni': '06',
        'Juli': '07',
        'Agustus': '08',
        'September': '09',
        'Oktober': '10',
        'November': '11',
        'Desember': '12',
      };
      final m = months[monthName] ?? '12';
      return '$yearStr-$m-01';
    }
    return null;
  }

  @override
  Future<FinancialGoal> createGoal(FinancialGoal goal) async {
    try {
      final scheme = _mapSchemeToApi(goal.contributionScheme);
      final prio = _mapPriorityToApi(goal.priority);
      final formattedDeadline = _mapDeadlineToApi(goal.deadline);

      final body = <String, dynamic>{
        'name': goal.name,
        'target_amount': goal.targetAmount,
        if (formattedDeadline != null) 'deadline': formattedDeadline,
        if (goal.themeIcon.isNotEmpty) 'theme': goal.themeIcon,
        'contribution_scheme': scheme,
        'priority': prio,
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
    final body = <String, dynamic>{
      'amount': amount,
      'source': (transactionId != null && transactionId.isNotEmpty)
          ? 'transaction'
          : 'manual',
      if (note != null && note.isNotEmpty) 'note': note,
      if (transactionId != null && transactionId.isNotEmpty)
        'transaction_id': transactionId,
    };

    try {
      debugPrint('[POST /goals/$id/contributions Request]: $body');
      final response = await _apiClient.dio.post(
        '/goals/$id/contributions',
        data: body,
      );
      debugPrint('[POST /goals/$id/contributions Response]: ${response.data}');
      final raw = _unwrap(response.data);
      GoalContribution result;
      if (raw is Map<String, dynamic>) {
        result = GoalContribution.fromJson(raw);
      } else {
        result = GoalContribution(
          id: 'contrib-${DateTime.now().millisecondsSinceEpoch}',
          sourceName: (note != null && note.isNotEmpty) ? note : 'Dari Saldo Bersama',
          date: DateTime.now(),
          amount: amount,
        );
      }
      _userAddedContributions.putIfAbsent(id, () => []).insert(0, result);
      return result;
    } on DioException catch (e) {
      debugPrint('[POST /goals/$id/contributions Error]: ${e.response?.statusCode} - ${e.response?.data}');
      final fallback = GoalContribution(
        id: 'contrib-${DateTime.now().millisecondsSinceEpoch}',
        sourceName: (note != null && note.isNotEmpty) ? note : 'Dari Saldo Bersama',
        date: DateTime.now(),
        amount: amount,
      );
      _userAddedContributions.putIfAbsent(id, () => []).insert(0, fallback);
      return fallback;
    } catch (e) {
      final fallback = GoalContribution(
        id: 'contrib-${DateTime.now().millisecondsSinceEpoch}',
        sourceName: (note != null && note.isNotEmpty) ? note : 'Dari Saldo Bersama',
        date: DateTime.now(),
        amount: amount,
      );
      _userAddedContributions.putIfAbsent(id, () => []).insert(0, fallback);
      return fallback;
    }
  }
}
