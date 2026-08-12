import '../../../../shared/models/transaction_model.dart';

abstract interface class TransactionRepository {
  Future<List<Transaction>> getTransactions({
    String? category,
    TransactionDirection? direction,
    String? attentionLevel,
    String? cursor,
    int limit = 20,
  });

  Future<Transaction?> getTransactionById(String id);

  Future<Transaction> createTransaction(Transaction transaction);

  Future<Transaction> updateTransaction(
    String id,
    Map<String, dynamic> updates,
  );

  Future<bool> deleteTransaction(String id);

  /// [action]: 'confirm' | 'clarify'
  Future<Transaction> confirmTransactionAnomaly(
    String id, {
    required String action,
    String? note,
  });

  /// [label]: 'genuine' | 'needs_review' | 'false_positive'
  Future<Transaction> sendTransactionFeedback(
    String id, {
    required String label,
  });
}
