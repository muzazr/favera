import '../../../../core/api/api_client.dart';
import '../../../../shared/models/transaction_model.dart';
import 'transaction_repository.dart';

class RemoteTransactionRepository implements TransactionRepository {
  final ApiClient _apiClient;

  RemoteTransactionRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<Transaction>> getTransactions({
    String? category,
    TransactionType? type,
    String? cursor,
    int limit = 20,
    bool? isAnomaly,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
    };
    if (category != null && category.isNotEmpty && category != 'Semua') {
      query['category'] = category;
    }
    if (type != null) {
      query['type'] = type == TransactionType.income ? 'INCOME' : 'EXPENSE';
    }
    if (cursor != null && cursor.isNotEmpty) {
      query['cursor'] = cursor;
    }
    if (isAnomaly != null) {
      query['is_anomaly'] = isAnomaly;
    }

    final response =
        await _apiClient.dio.get('/transactions', queryParameters: query);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((json) => Transaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final response = await _apiClient.dio.get('/transactions/$id');
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }

  @override
  Future<Transaction> createTransaction(
    Transaction transaction,
  ) async {
    final response = await _apiClient.dio.post(
      '/transactions',
      data: transaction.toJson(),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }

  @override
  Future<Transaction> updateTransaction(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiClient.dio.patch(
      '/transactions/$id',
      data: updates,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    await _apiClient.dio.delete('/transactions/$id');
    return true;
  }

  @override
  Future<Transaction> confirmTransactionAnomaly(
    String id, {
    required String note,
  }) async {
    final response = await _apiClient.dio.post(
      '/transactions/$id/confirmation',
      data: {'note': note},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }

  @override
  Future<Transaction> sendTransactionFeedback(
    String id, {
    required String feedbackText,
  }) async {
    final response = await _apiClient.dio.post(
      '/transactions/$id/feedback',
      data: {'feedback_text': feedbackText},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }
}
