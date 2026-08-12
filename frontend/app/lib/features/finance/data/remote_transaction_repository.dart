import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/api_error_decoder.dart';
import '../../../../shared/models/transaction_model.dart';
import 'transaction_repository.dart';

class RemoteTransactionRepository implements TransactionRepository {
  final ApiClient _apiClient;

  RemoteTransactionRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Parse response body defensively: accepts `{"data": [...]}` or direct list/object.
  static dynamic _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  @override
  Future<List<Transaction>> getTransactions({
    String? category,
    TransactionDirection? direction,
    String? attentionLevel,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
      if (category != null && category.isNotEmpty && category != 'Semua') {
        query['category'] = category;
      }
      // Only send direction if it is query-filter-safe (income/expense/transfer).
      if (direction != null && direction.isQueryFilterSafe) {
        query['direction'] = direction.apiValue;
      }
      if (attentionLevel != null && attentionLevel.isNotEmpty) {
        query['attention_level'] = attentionLevel;
      }

      final response = await _apiClient.dio.get(
        '/transactions',
        queryParameters: query,
      );
      final raw = _unwrap(response.data);
      final list = raw as List<dynamic>;
      return list
          .map((j) => Transaction.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final response = await _apiClient.dio.get('/transactions/$id');
      final raw = _unwrap(response.data);
      return Transaction.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Transaction> createTransaction(Transaction transaction) async {
    try {
      final isoDate = transaction.date.toUtc().toIso8601String();
      final apiCategory = _mapCategoryToApi(transaction.category);
      final desc = transaction.description.trim().isNotEmpty
          ? transaction.description.trim()
          : 'Transaksi $apiCategory';

      final body = <String, dynamic>{
        'transaction_at': isoDate,
        'direction': transaction.direction.apiValue,
        'amount': transaction.amount,
        'description': desc,
        'category': apiCategory,
        'visibility': 'shared',
      };

      final response = await _apiClient.dio.post(
        '/transactions',
        data: body,
      );
      final raw = _unwrap(response.data);
      return Transaction.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  static String _mapCategoryToApi(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('makan') || lower.contains('food')) return 'food';
    if (lower.contains('tagihan') || lower.contains('listrik') || lower.contains('util')) return 'utilities';
    if (lower.contains('transport')) return 'transportation';
    if (lower.contains('belanja') || lower.contains('shop')) return 'shopping';
    if (lower.contains('rumah') || lower.contains('house') || lower.contains('hous')) return 'housing';
    if (lower.contains('sehat') || lower.contains('health')) return 'health';
    if (lower.contains('didik') || lower.contains('edu')) return 'education';
    if (lower.contains('hutang') || lower.contains('debt')) return 'debt';
    if (lower.contains('tabung') || lower.contains('saving')) return 'savings';
    if (lower.contains('gaji') || lower.contains('salary')) return 'salary';
    if (lower.contains('usaha') || lower.contains('bisnis') || lower.contains('business')) return 'business_income';
    if (lower.contains('invest')) return 'investment';
    if (lower.contains('tarik') || lower.contains('cash')) return 'cash_withdrawal';
    if (lower.contains('transf')) return 'transfer';
    if (lower.contains('topup') || lower.contains('wallet')) return 'e_wallet_topup';
    return 'other';
  }

  @override
  Future<Transaction> updateTransaction(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/transactions/$id',
        data: updates,
      );
      final raw = _unwrap(response.data);
      return Transaction.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    try {
      await _apiClient.dio.delete('/transactions/$id');
      return true;
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Transaction> confirmTransactionAnomaly(
    String id, {
    required String action,
    String? note,
  }) async {
    try {
      final body = <String, dynamic>{'action': action};
      if (note != null && note.isNotEmpty) body['note'] = note;
      final response = await _apiClient.dio.post(
        '/transactions/$id/confirmation',
        data: body,
      );
      final raw = _unwrap(response.data);
      return Transaction.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Transaction> sendTransactionFeedback(
    String id, {
    required String label,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/transactions/$id/feedback',
        data: {'label': label},
      );
      final raw = _unwrap(response.data);
      return Transaction.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
