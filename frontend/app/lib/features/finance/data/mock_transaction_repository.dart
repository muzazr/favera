import '../../../../mock/mock_store.dart';
import '../../../../shared/models/transaction_model.dart';
import 'transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  final MockStore _store;

  MockTransactionRepository({MockStore? store}) : _store = store ?? MockStore();

  @override
  Future<List<Transaction>> getTransactions({
    String? category,
    TransactionType? type,
    String? cursor,
    int limit = 20,
    bool? isAnomaly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _store.getTransactions();

    if (category != null && category.isNotEmpty && category != 'Semua') {
      list = list.where((tx) => tx.category == category).toList();
    }

    if (type != null) {
      list = list.where((tx) => tx.type == type).toList();
    }

    if (isAnomaly != null) {
      list = list.where((tx) => tx.isAnomaly == isAnomaly).toList();
    }

    // Sort by date descending
    list.sort((a, b) => b.date.compareTo(a.date));

    if (cursor != null && cursor.isNotEmpty) {
      final index = list.indexWhere((tx) => tx.id == cursor);
      if (index != -1 && index + 1 < list.length) {
        list = list.sublist(index + 1);
      }
    }

    return list.take(limit).toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = _store.getTransactions();
    try {
      return list.firstWhere((tx) => tx.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Transaction> createTransaction(
    Transaction transaction,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _store.addTransaction(transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(
    String id,
    Map<String, dynamic> updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existing = await getTransactionById(id);
    if (existing == null) {
      throw Exception('Transaksi tidak ditemukan');
    }

    final updated = existing.copyWith(
      amount: updates['amount'] as int? ?? existing.amount,
      category: updates['category'] as String? ?? existing.category,
      description: updates['description'] as String? ?? existing.description,
      type: updates['type'] as TransactionType? ?? existing.type,
    );

    _store.addTransaction(updated);
    return updated;
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _store.removeTransaction(id);
  }

  @override
  Future<Transaction> confirmTransactionAnomaly(
    String id, {
    required String note,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final existing = await getTransactionById(id);
    if (existing == null) {
      throw Exception('Transaksi tidak ditemukan');
    }

    final updated = existing.copyWith(
      confirmedByPartner: true,
      anomalyReason: note.isNotEmpty ? note : 'Telah dikonfirmasi keluarga',
    );
    _store.addTransaction(updated);
    return updated;
  }

  @override
  Future<Transaction> sendTransactionFeedback(
    String id, {
    required String feedbackText,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final existing = await getTransactionById(id);
    if (existing == null) {
      throw Exception('Transaksi tidak ditemukan');
    }
    return existing;
  }
}
