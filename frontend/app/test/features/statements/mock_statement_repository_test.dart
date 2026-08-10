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
        fileName: 'test_statement.pdf',
        fileSizeBytes: 1024000,
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
        fileName: 'protected.pdf',
        fileSizeBytes: 2048000,
        providerHint: 'bca',
        requiresPassword: true,
      );

      expect(created.status, equals(StatementImportStatus.passwordRequired));

      final wrongPassResult =
          await repository.unlockStatementImport(created.id, 'wrong');
      expect(wrongPassResult, isFalse);

      final rightPassResult =
          await repository.unlockStatementImport(created.id, '123456');
      expect(rightPassResult, isTrue);

      final drafts = await repository.getDraftTransactions(created.id);
      expect(drafts.length, equals(2));
    });

    test('updateDraftTransaction updates status and categories correctly',
        () async {
      final created = await repository.createStatementImport(
        fileName: 'test_statement.pdf',
        fileSizeBytes: 1024000,
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
        fileName: 'test_statement.pdf',
        fileSizeBytes: 1024000,
        providerHint: 'bca',
      );

      final confirmed = await repository.confirmStatementImport(created.id);
      expect(confirmed, isTrue);
    });
  });
}
