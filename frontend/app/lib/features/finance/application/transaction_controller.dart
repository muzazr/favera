import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../home/application/dashboard_controller.dart';
import '../data/transaction_repository_provider.dart';

class TransactionListFilter {
  final String category;
  final TransactionDirection? direction;
  final String? attentionLevel;

  const TransactionListFilter({
    this.category = 'Semua',
    this.direction,
    this.attentionLevel,
  });

  TransactionListFilter copyWith({
    String? category,
    Object? direction = _sentinel,
    Object? attentionLevel = _sentinel,
  }) {
    return TransactionListFilter(
      category: category ?? this.category,
      direction: direction == _sentinel
          ? this.direction
          : direction as TransactionDirection?,
      attentionLevel: attentionLevel == _sentinel
          ? this.attentionLevel
          : attentionLevel as String?,
    );
  }

  // Sentinel to distinguish null-clear from "not provided".
  static const Object _sentinel = Object();
}

final transactionFilterProvider = StateProvider<TransactionListFilter>(
    (ref) => const TransactionListFilter());

final transactionListControllerProvider =
    AsyncNotifierProvider<TransactionListController, List<Transaction>>(
  TransactionListController.new,
);

class TransactionListController extends AsyncNotifier<List<Transaction>> {
  @override
  Future<List<Transaction>> build() async {
    final repository = ref.watch(transactionRepositoryProvider);
    final filter = ref.watch(transactionFilterProvider);

    return repository.getTransactions(
      category: filter.category,
      direction: filter.direction,
      attentionLevel: filter.attentionLevel,
    );
  }

  Future<void> refreshList() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);
      final filter = ref.read(transactionFilterProvider);
      return repository.getTransactions(
        category: filter.category,
        direction: filter.direction,
        attentionLevel: filter.attentionLevel,
      );
    });
  }

  Future<void> addTransaction({
    required TransactionDirection direction,
    required int amount,
    required String category,
    required String description,
  }) async {
    final repository = ref.read(transactionRepositoryProvider);
    final newTx = Transaction(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      direction: direction,
      amount: amount,
      category: category,
      description: description,
      date: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await repository.createTransaction(newTx);

    // Invalidate dashboard and transaction list to refresh UI
    ref.invalidate(dashboardControllerProvider);
    ref.invalidateSelf();
  }

  Future<bool> deleteTransaction(String id) async {
    final repository = ref.read(transactionRepositoryProvider);
    final success = await repository.deleteTransaction(id);
    if (success) {
      ref.invalidate(dashboardControllerProvider);
      ref.invalidateSelf();
    }
    return success;
  }
}

final transactionDetailControllerProvider =
    FutureProvider.family.autoDispose<Transaction?, String>((ref, id) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactionById(id);
});
