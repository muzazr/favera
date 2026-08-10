import '../../../../shared/models/transaction_model.dart';

abstract interface class TransactionRepository {
  Future<List<Transaction>> getTransactions({
    String? category,
    TransactionType? type,
    String? cursor,
    int limit = 20,
    bool? isAnomaly,
  });

  Future<Transaction?> getTransactionById(String id);

  Future<Transaction> createTransaction(Transaction transaction);

  Future<Transaction> updateTransaction(
    String id,
    Map<String, dynamic> updates,
  );

  Future<bool> deleteTransaction(String id);

  Future<Transaction> confirmTransactionAnomaly(
    String id, {
    required String note,
  });

  Future<Transaction> sendTransactionFeedback(
    String id, {
    required String feedbackText,
  });
}
