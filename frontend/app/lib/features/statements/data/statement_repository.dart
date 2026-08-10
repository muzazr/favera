import '../../../shared/models/statement_model.dart';

abstract class StatementRepository {
  Future<List<StatementImport>> getStatementImports();
  Future<StatementImport?> getStatementImportById(String id);
  Future<StatementImport> createStatementImport({
    required String fileName,
    required int fileSizeBytes,
    required String providerHint,
    bool requiresPassword = false,
  });
  Future<bool> unlockStatementImport(String id, String password);
  Future<List<ParsedTransactionDraft>> getDraftTransactions(String importId);
  Future<ParsedTransactionDraft> updateDraftTransaction(
    String importId,
    String draftId,
    Map<String, dynamic> updates,
  );
  Future<bool> confirmStatementImport(String importId);
  Future<bool> deleteStatementImport(String id);
}
