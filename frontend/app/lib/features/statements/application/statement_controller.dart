import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../finance/application/transaction_controller.dart';
import '../../home/application/dashboard_controller.dart';
import '../../statements/data/statement_repository_provider.dart';
import '../../../shared/models/statement_model.dart';

final statementDraftsControllerProvider = FutureProvider.family
    .autoDispose<List<ParsedTransactionDraft>, String>(
        (ref, String importId) async {
  final repo = ref.watch(statementRepositoryProvider);
  return repo.getDraftTransactions(importId);
});

final statementUploadControllerProvider = StateNotifierProvider<
    StatementUploadController, AsyncValue<StatementImport?>>((ref) {
  return StatementUploadController(ref);
});

class StatementUploadController
    extends StateNotifier<AsyncValue<StatementImport?>> {
  final Ref ref;

  StatementUploadController(this.ref) : super(const AsyncValue.data(null));

  Future<StatementImport?> createImport({
    required String fileName,
    required int fileSizeBytes,
    required String providerHint,
    bool requiresPassword = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(statementRepositoryProvider);
      final created = await repo.createStatementImport(
        fileName: fileName,
        fileSizeBytes: fileSizeBytes,
        providerHint: providerHint,
        requiresPassword: requiresPassword,
      );
      state = AsyncValue.data(created);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> unlockImport(String importId, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(statementRepositoryProvider);
      final success = await repo.unlockStatementImport(importId, password);
      if (success) {
        ref.invalidate(statementDraftsControllerProvider(importId));
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> validateDraft(
    String importId,
    String draftId, {
    String? category,
  }) async {
    try {
      final repo = ref.read(statementRepositoryProvider);
      final updates = <String, dynamic>{
        'status': DraftStatus.validated,
      };
      if (category != null) {
        updates['category'] = category;
      }
      await repo.updateDraftTransaction(importId, draftId, updates);
      ref.invalidate(statementDraftsControllerProvider(importId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteDraft(String importId, String draftId) async {
    try {
      final repo = ref.read(statementRepositoryProvider);
      await repo.updateDraftTransaction(
        importId,
        draftId,
        {'status': DraftStatus.deleted},
      );
      ref.invalidate(statementDraftsControllerProvider(importId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> confirmImport(String importId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(statementRepositoryProvider);
      final success = await repo.confirmStatementImport(importId);
      if (success) {
        ref.invalidate(transactionListControllerProvider);
        ref.invalidate(dashboardControllerProvider);
      }
      state = const AsyncValue.data(null);
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
