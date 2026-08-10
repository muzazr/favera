import 'package:app/features/finance/data/mock_transaction_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_store.dart';
import 'package:app/shared/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockStore store;
  late MockTransactionRepository repository;

  setUp(() {
    final clock = MockClock(DateTime.utc(2026, 8, 10));
    store = MockStore(clock: clock)..resetToSeed(preAuthenticate: true);
    repository = MockTransactionRepository(store: store);
  });

  group('MockTransactionRepository Tests', () {
    test('getTransactions returns initial seed transactions', () async {
      final transactions = await repository.getTransactions();
      expect(transactions, isNotEmpty);
      expect(transactions.length, greaterThanOrEqualTo(3));
    });

    test('getTransactions filters by category correctly', () async {
      final transactions =
          await repository.getTransactions(category: 'Belanja');
      expect(transactions.every((tx) => tx.category == 'Belanja'), isTrue);
    });

    test('createTransaction adds new transaction to store', () async {
      final newTx = Transaction(
        id: 'tx-test-100',
        type: TransactionType.expense,
        amount: 85000,
        category: 'Makanan',
        description: 'Makan Siang',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final created = await repository.createTransaction(newTx);
      expect(created.amount, equals(85000));

      final all = await repository.getTransactions();
      expect(all.any((tx) => tx.amount == 85000), isTrue);
    });

    test('deleteTransaction removes transaction from store', () async {
      final transactions = await repository.getTransactions();
      final targetId = transactions.first.id;

      final success = await repository.deleteTransaction(targetId);
      expect(success, isTrue);

      final afterDelete = await repository.getTransactions();
      expect(afterDelete.any((tx) => tx.id == targetId), isFalse);
    });

    test('confirmTransactionAnomaly marks anomaly as confirmed', () async {
      final transactions = await repository.getTransactions();
      final targetId = transactions.first.id;

      final updated = await repository.confirmTransactionAnomaly(
        targetId,
        note: 'Dikonfirmasi aman oleh Joselin',
      );

      expect(updated.confirmedByPartner, isTrue);
    });
  });
}
