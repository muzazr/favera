import 'dart:typed_data';
import 'package:app/features/statements/data/mock_statement_repository.dart';
import 'package:app/mock/mock_store.dart';
import 'package:app/shared/models/statement_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockStatementRepository Tests', () {
    late MockStore store;
    late MockStatementRepository repository;

    setUp(() {
      store = MockStore();
      repository = MockStatementRepository(store: store);
    });

    test(
        'createStatementImport adds new statement import and draft transactions',
        () async {
      final created = await repository.createStatementImport(
        fileBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'test_statement.pdf',
        providerHint: 'bca',
      );

      expect(created.fileName, equals('test_statement.pdf'));
      expect(created.status, equals(StatementImportStatus.parsing));

      final drafts = await repository.getDraftTransactions(created.id);
      expect(drafts.length, equals(2));
      expect(drafts.first.description, equals('APPLE.COM/BILL'));
    });

    test(
        'unlockStatementImport unlocks protected statement with correct password',
        () async {
      final created = await repository.createStatementImport(
        fileBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'protected.pdf',
        providerHint: 'bca',
        documentPassword: 'secretpassword',
      );

      expect(created.status, equals(StatementImportStatus.passwordRequired));

      expect(
        () async => await repository.unlockStatementImport(created.id, 'wrong'),
        throwsA(isA<Exception>()),
      );

      final unlocked =
          await repository.unlockStatementImport(created.id, '123456');
      expect(unlocked.status, equals(StatementImportStatus.reviewRequired));

      final drafts = await repository.getDraftTransactions(created.id);
      expect(drafts.length, equals(2));
    });

    test('updateDraftTransaction updates status and categories correctly',
        () async {
      final created = await repository.createStatementImport(
        fileBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'test_statement.pdf',
        providerHint: 'bca',
      );

      final drafts = await repository.getDraftTransactions(created.id);
      final draft1 = drafts.first;

      final updated = await repository.updateDraftTransaction(
        created.id,
        draft1.id,
        {'status': DraftStatus.validated, 'category': 'Hiburan'},
      );

      expect(updated.status, equals(DraftStatus.validated));
    });

    test('confirmStatementImport converts drafts and clears import review',
        () async {
      final created = await repository.createStatementImport(
        fileBytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'test_statement.pdf',
        providerHint: 'bca',
      );

      final drafts = await repository.getDraftTransactions(created.id);
      final confirmed = await repository.confirmStatementImport(
        created.id,
        draftIds: drafts.map((d) => d.id).toList(),
      );
      expect(confirmed.status, equals(StatementImportStatus.confirmed));
    });
  });
}
