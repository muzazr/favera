import 'package:dio/dio.dart';
import '../../../shared/models/statement_model.dart';
import 'statement_repository.dart';

class RemoteStatementRepository implements StatementRepository {
  final Dio dio;

  RemoteStatementRepository({required this.dio});

  @override
  Future<List<StatementImport>> getStatementImports() async {
    final response = await dio.get('/statement-imports');
    final data = response.data as List<dynamic>;
    return data
        .map((j) => StatementImport.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StatementImport?> getStatementImportById(String id) async {
    final response = await dio.get('/statement-imports/$id');
    return StatementImport.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<StatementImport> createStatementImport({
    required String fileName,
    required int fileSizeBytes,
    required String providerHint,
    bool requiresPassword = false,
  }) async {
    final response = await dio.post(
      '/statement-imports',
      data: {
        'file_name': fileName,
        'file_size_bytes': fileSizeBytes,
        'provider_hint': providerHint,
        'requires_password': requiresPassword,
      },
    );
    return StatementImport.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> unlockStatementImport(String id, String password) async {
    final response = await dio.post(
      '/statement-imports/$id/unlock',
      data: {'password': password},
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<ParsedTransactionDraft>> getDraftTransactions(
      String importId) async {
    final response =
        await dio.get('/statement-imports/$importId/draft-transactions');
    final data = response.data as List<dynamic>;
    return data
        .map((j) => ParsedTransactionDraft.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ParsedTransactionDraft> updateDraftTransaction(
    String importId,
    String draftId,
    Map<String, dynamic> updates,
  ) async {
    final response = await dio.patch(
      '/statement-imports/$importId/draft-transactions/$draftId',
      data: updates,
    );
    return ParsedTransactionDraft.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<bool> confirmStatementImport(String importId) async {
    final response = await dio.post('/statement-imports/$importId/confirm');
    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteStatementImport(String id) async {
    final response = await dio.delete('/statement-imports/$id');
    return response.statusCode == 200;
  }
}
