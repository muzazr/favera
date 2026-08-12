import 'dart:typed_data';
import '../../../shared/models/statement_model.dart';

abstract class StatementRepository {
  Future<List<StatementImport>> getStatementImports({
    String? cursor,
    int limit = 20,
  });

  Future<StatementImport?> getStatementImportById(String id);

  /// Upload PDF or CSV file as multipart/form-data.
  /// [fileBytes] and [fileName] are required for real upload.
  /// [documentPassword] is ephemeral — do NOT persist.
  Future<StatementImport> createStatementImport({
    required Uint8List fileBytes,
    required String fileName,
    required String providerHint,
    String? documentPassword,
  });

  /// Re-send document password to unlock a password-protected statement.
  /// [password] is ephemeral — do NOT persist or log.
  Future<StatementImport> unlockStatementImport(String id, String password);

  Future<List<ParsedTransactionDraft>> getDraftTransactions(
    String importId, {
    String? cursor,
    int limit = 100,
  });

  Future<ParsedTransactionDraft> updateDraftTransaction(
    String importId,
    String draftId,
    Map<String, dynamic> updates,
  );

  /// Confirm selected draft IDs. Returns 202 — processing may continue async.
  Future<StatementImport> confirmStatementImport(
    String importId, {
    required List<String> draftIds,
  });

  /// Cancel/delete an import.
  Future<bool> deleteStatementImport(String id);

  /// Poll current status of an import (single fetch, no loop).
  Future<StatementImport?> pollImportStatus(String id);
}
