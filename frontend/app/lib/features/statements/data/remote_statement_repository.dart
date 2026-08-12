import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/statement_model.dart';
import 'statement_repository.dart';

class RemoteStatementRepository implements StatementRepository {
  final ApiClient _apiClient;

  RemoteStatementRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  static dynamic _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  @override
  Future<List<StatementImport>> getStatementImports({
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
      final response = await _apiClient.dio.get(
        '/statement-imports',
        queryParameters: query,
      );
      final raw = _unwrap(response.data);
      if (raw is List) {
        return raw
            .map((j) => StatementImport.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      final items =
          (raw as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
      return items
          .map((j) => StatementImport.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<StatementImport?> getStatementImportById(String id) async {
    try {
      final response = await _apiClient.dio.get('/statement-imports/$id');
      final raw = _unwrap(response.data);
      return StatementImport.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<StatementImport> createStatementImport({
    required Uint8List fileBytes,
    required String fileName,
    required String providerHint,
    String? documentPassword,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        ),
        'provider_hint': providerHint,
        // documentPassword is ephemeral — only included when explicitly provided.
        if (documentPassword != null && documentPassword.isNotEmpty)
          'document_password': documentPassword,
      });

      final response = await _apiClient.dio.post(
        '/statement-imports',
        data: formData,
      );
      final raw = _unwrap(response.data);
      return StatementImport.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<StatementImport> unlockStatementImport(
    String id,
    String password,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/statement-imports/$id/unlock',
        data: {'document_password': password},
        // password is NOT cached or logged — ephemeral only
      );
      final raw = _unwrap(response.data);
      return StatementImport.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<List<ParsedTransactionDraft>> getDraftTransactions(
    String importId, {
    String? cursor,
    int limit = 100,
  }) async {
    try {
      final query = <String, dynamic>{'limit': limit};
      if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
      final response = await _apiClient.dio.get(
        '/statement-imports/$importId/draft-transactions',
        queryParameters: query,
      );
      final raw = _unwrap(response.data);
      if (raw is List) {
        return raw
            .map((j) =>
                ParsedTransactionDraft.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      final items =
          (raw as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
      return items
          .map((j) =>
              ParsedTransactionDraft.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<ParsedTransactionDraft> updateDraftTransaction(
    String importId,
    String draftId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiClient.dio.patch(
        '/statement-imports/$importId/draft-transactions/$draftId',
        data: updates,
      );
      final raw = _unwrap(response.data);
      return ParsedTransactionDraft.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<StatementImport> confirmStatementImport(
    String importId, {
    required List<String> draftIds,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/statement-imports/$importId/confirm',
        data: {'confirm_draft_ids': draftIds},
      );
      // 202 Accepted — processing continues asynchronously.
      final raw = _unwrap(response.data);
      return StatementImport.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<bool> deleteStatementImport(String id) async {
    try {
      await _apiClient.dio.delete('/statement-imports/$id');
      return true;
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<StatementImport?> pollImportStatus(String id) {
    return getStatementImportById(id);
  }
}
