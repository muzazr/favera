import 'package:flutter_test/flutter_test.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_store.dart';
import 'package:app/shared/models/statement_model.dart';
import 'package:app/shared/models/transaction_model.dart';

void main() {
  group('MockStore Tests', () {
    late MockClock mockClock;
    late MockStore store;

    setUp(() {
      mockClock = MockClock(DateTime.utc(2026, 8, 9, 10, 0, 0));
      store = MockStore(clock: mockClock)..resetToSeed(preAuthenticate: true);
    });

    test('initializes with seed user, family, and transactions', () {
      expect(store.currentUser?.name, equals('Joselin'));
      expect(store.family?.inviteCode, equals('FAV-88219'));
      expect(store.getTransactions().length, equals(3));
      expect(store.getTotalBalance(), equals(12500000));
    });

    test('addTransaction mutates state and updates totals', () {
      final newTx = Transaction(
        id: 'tx-new-1',
        direction: TransactionDirection.income,
        amount: 2000000,
        category: 'Bonus',
        description: 'Bonus Kinerja',
        date: mockClock.now(),
        createdAt: mockClock.now(),
      );

      store.addTransaction(newTx);

      expect(store.getTransactions().length, equals(4));
      expect(store.getTotalBalance(), equals(14500000));
    });

    test('createStatementImport and unlock with correct password', () {
      final import = store.createStatementImport(
        fileName: 'mandiri_august.pdf',
        fileSizeBytes: 204800,
        providerHint: 'mandiri',
        requiresPassword: true,
      );

      expect(import.status, equals(StatementImportStatus.passwordRequired));

      final unlocked = store.unlockStatementImport(import.id, '123456');
      expect(unlocked, isTrue);

      final drafts = store.getDrafts(import.id);
      expect(drafts.length, equals(2));
      expect(drafts.first.description, equals('APPLE.COM/BILL'));
    });

    test('confirmStatementImport converts validated draft to transaction', () {
      final import = store.createStatementImport(
        fileName: 'mandiri_august.pdf',
        fileSizeBytes: 204800,
        providerHint: 'mandiri',
        requiresPassword: false,
      );

      final drafts = store.getDrafts(import.id);
      expect(drafts.isNotEmpty, isTrue);

      // Validate first draft
      store.updateDraftStatus(drafts.first.id, DraftStatus.validated);

      final confirmed = store.confirmStatementImport(import.id);
      expect(confirmed, isTrue);

      // Verify new canonical transaction created
      final txs = store.getTransactions();
      expect(txs.any((t) => t.description == 'APPLE.COM/BILL'), isTrue);
    });

    test('resetToSeed clears mutations back to seed', () {
      store.addTransaction(Transaction(
        id: 'tx-temp',
        direction: TransactionDirection.income,
        amount: 5000000,
        category: 'Lainnya',
        description: 'Temporary',
        date: mockClock.now(),
        createdAt: mockClock.now(),
      ));

      expect(store.getTransactions().length, equals(4));

      store.resetToSeed();

      expect(store.getTransactions().length, equals(3));
    });
  });
}
