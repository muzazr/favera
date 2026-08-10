import '../../../mock/mock_store.dart';
import '../../../shared/models/statement_model.dart';
import 'statement_repository.dart';

class MockStatementRepository implements StatementRepository {
  final MockStore _store;

  MockStatementRepository({MockStore? store}) : _store = store ?? MockStore();

  @override
  Future<List<StatementImport>> getStatementImports() async {
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
    required String fileName,
    required int fileSizeBytes,
    required String providerHint,
    bool requiresPassword = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _store.createStatementImport(
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      providerHint: providerHint,
      requiresPassword: requiresPassword,
    );
  }

  @override
  Future<bool> unlockStatementImport(String id, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _store.unlockStatementImport(id, password);
  }

  @override
  Future<List<ParsedTransactionDraft>> getDraftTransactions(
      String importId) async {
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
  Future<bool> confirmStatementImport(String importId) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _store.confirmStatementImport(importId);
  }

  @override
  Future<bool> deleteStatementImport(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
