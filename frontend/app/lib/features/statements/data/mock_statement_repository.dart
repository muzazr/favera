import 'dart:typed_data';
import '../../../mock/mock_store.dart';
import '../../../shared/models/statement_model.dart';
import 'statement_repository.dart';

class MockStatementRepository implements StatementRepository {
  final MockStore _store;

  MockStatementRepository({MockStore? store}) : _store = store ?? MockStore();

  @override
  Future<List<StatementImport>> getStatementImports({
    String? cursor,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  @override
  Future<StatementImport?> getStatementImportById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return StatementImport(
      id: id,
      fileName: 'eStatement_BCA_Juni2026.pdf',
      fileSizeBytes: 2450000,
      status: StatementImportStatus.reviewRequired,
      providerHint: 'bca',
      requiresPassword: false,
      totalDetected: 145,
      needsReviewCount: 2,
      uploadedAt: DateTime.now(),
    );
  }

  @override
  Future<StatementImport> createStatementImport({
    required Uint8List fileBytes,
    String? filePath,
    required String fileName,
    required String providerHint,
    String? documentPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _store.createStatementImport(
      fileName: fileName,
      fileSizeBytes: fileBytes.length,
      providerHint: providerHint,
      requiresPassword: documentPassword != null && documentPassword.isNotEmpty,
    );
  }

  @override
  Future<StatementImport> unlockStatementImport(String id, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final success = _store.unlockStatementImport(id, password);
    final updated = StatementImport(
      id: id,
      fileName: 'eStatement.pdf',
      fileSizeBytes: 2450000,
      status: success
          ? StatementImportStatus.reviewRequired
          : StatementImportStatus.passwordRequired,
      providerHint: 'bca',
      requiresPassword: true,
      totalDetected: success ? 145 : 0,
      needsReviewCount: success ? 2 : 0,
      uploadedAt: DateTime.now(),
    );
    if (!success) throw Exception('Password salah. Coba lagi.');
    return updated;
  }

  @override
  Future<List<ParsedTransactionDraft>> getDraftTransactions(
    String importId, {
    String? cursor,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _store.getDrafts(importId);
  }

  @override
  Future<ParsedTransactionDraft> updateDraftTransaction(
    String importId,
    String draftId,
    Map<String, dynamic> updates,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (updates.containsKey('status')) {
      _store.updateDraftStatus(draftId, updates['status'] as DraftStatus);
    }
    final drafts = _store.getDrafts(importId);
    return drafts.firstWhere((d) => d.id == draftId);
  }

  @override
  Future<StatementImport> confirmStatementImport(
    String importId, {
    required List<String> draftIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    _store.confirmStatementImport(importId);
    return StatementImport(
      id: importId,
      fileName: 'eStatement.pdf',
      fileSizeBytes: 0,
      status: StatementImportStatus.confirmed,
      providerHint: 'bca',
      totalDetected: draftIds.length,
      uploadedAt: DateTime.now(),
    );
  }

  @override
  Future<bool> deleteStatementImport(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  @override
  Future<StatementImport?> pollImportStatus(String id) {
    return getStatementImportById(id);
  }
}
