import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../finance/application/transaction_controller.dart';
import '../../home/application/dashboard_controller.dart';
import '../../statements/data/statement_repository_provider.dart';
import '../../../shared/models/statement_model.dart';

// --- Statement import list ---

final statementImportListControllerProvider =
    AsyncNotifierProvider<StatementImportListController, List<StatementImport>>(
  StatementImportListController.new,
);

class StatementImportListController
    extends AsyncNotifier<List<StatementImport>> {
  @override
  Future<List<StatementImport>> build() async {
    final repo = ref.watch(statementRepositoryProvider);
    return repo.getStatementImports();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(statementRepositoryProvider);
      return repo.getStatementImports();
    });
  }
}

// --- Draft transactions for a given import ---

final statementDraftsControllerProvider = FutureProvider.family
    .autoDispose<List<ParsedTransactionDraft>, String>(
        (ref, String importId) async {
  final repo = ref.watch(statementRepositoryProvider);
  return repo.getDraftTransactions(importId);
});

// --- Upload + polling controller ---

final statementUploadControllerProvider = StateNotifierProvider<
    StatementUploadController, AsyncValue<StatementImport?>>(
  (ref) => StatementUploadController(ref),
);

class StatementUploadController
    extends StateNotifier<AsyncValue<StatementImport?>> {
  final Ref ref;
  Timer? _pollTimer;

  static const _terminalStates = {
    StatementImportStatus.reviewRequired,
    StatementImportStatus.confirmed,
    StatementImportStatus.failed,
    StatementImportStatus.cancelled,
  };

  static const _pollInterval = Duration(seconds: 4);

  StatementUploadController(this.ref) : super(const AsyncValue.data(null));

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _startPolling(String importId) {
    _stopPolling();
    if (importId.trim().isEmpty) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) async {
      if (!mounted) {
        _stopPolling();
        return;
      }
      try {
        final repo = ref.read(statementRepositoryProvider);
        final updated = await repo.pollImportStatus(importId);
        if (!mounted) return;
        if (updated != null) {
          state = AsyncValue.data(updated);
          if (_terminalStates.contains(updated.status)) {
            _stopPolling();
            // If now reviewRequired or confirmed, invalidate drafts provider
            if (updated.status == StatementImportStatus.reviewRequired) {
              ref.invalidate(statementDraftsControllerProvider(importId));
            }
          }
        }
      } catch (_) {
        // Don't break polling on transient errors
      }
    });
  }

  Future<StatementImport?> uploadImport({
    required Uint8List fileBytes,
    String? filePath,
    required String fileName,
    required String providerHint,
    String? documentPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(statementRepositoryProvider);
      final created = await repo.createStatementImport(
        fileBytes: fileBytes,
        filePath: filePath,
        fileName: fileName,
        providerHint: providerHint,
        documentPassword: documentPassword,
        // documentPassword NOT persisted after this call
      );
      state = AsyncValue.data(created);

      // If not already terminal, start polling
      if (!_terminalStates.contains(created.status)) {
        _startPolling(created.id);
      }

      ref.invalidate(statementImportListControllerProvider);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<StatementImport?> unlockImport(
    String importId,
    String password,
  ) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(statementRepositoryProvider);
      final updated = await repo.unlockStatementImport(importId, password);
      state = AsyncValue.data(updated);

      if (!_terminalStates.contains(updated.status)) {
        _startPolling(importId);
      } else if (updated.status == StatementImportStatus.reviewRequired) {
        ref.invalidate(statementDraftsControllerProvider(importId));
      }
      return updated;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> validateDraft(
    String importId,
    String draftId, {
    String? category,
  }) async {
    try {
      final repo = ref.read(statementRepositoryProvider);
      final updates = <String, dynamic>{'status': DraftStatus.validated};
      if (category != null) updates['category'] = category;
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

  Future<bool> confirmImport(
    String importId, {
    required List<String> draftIds,
  }) async {
    _stopPolling();
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(statementRepositoryProvider);
      // 202 Accepted — processing continues asynchronously on backend.
      final updated = await repo.confirmStatementImport(
        importId,
        draftIds: draftIds,
      );
      state = AsyncValue.data(updated);
      ref.invalidate(statementImportListControllerProvider);
      // Refresh transactions and dashboard after confirm — backend may still be processing.
      // We do it optimistically here and it will re-sync when user returns to those screens.
      ref.invalidate(transactionListControllerProvider);
      ref.invalidate(dashboardControllerProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
