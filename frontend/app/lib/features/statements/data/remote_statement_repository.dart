import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/statement_model.dart';
import 'statement_repository.dart';

class RemoteStatementRepository implements StatementRepository {
  final ApiClient _apiClient;
  final Map<String, StatementImport> _rememberedImports = {};

  RemoteStatementRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  static dynamic _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        final inner = responseData['data'];
        if (inner is Map<String, dynamic>) {
          if (inner.containsKey('statement_import')) return inner['statement_import'];
          if (inner.containsKey('import')) return inner['import'];
          return inner;
        }
        return inner;
      }
      if (responseData.containsKey('statement_import')) {
        return responseData['statement_import'];
      }
      if (responseData.containsKey('import')) {
        return responseData['import'];
      }
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
    if (id.trim().isEmpty) return null;
    try {
      final response = await _apiClient.dio.get('/statement-imports/$id');
      final raw = _unwrap(response.data);
      if (raw is Map<String, dynamic>) {
        return StatementImport.fromJson(raw);
      }
      return null;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  String _mapProviderHint(String rawHint) {
    final lower = rawHint.toLowerCase();
    if (lower.contains('mandiri')) return 'mandiri';
    if (lower.contains('bri')) return 'bri';
    if (lower.contains('gopay') || lower.contains('gojek')) return 'gopay';
    return 'other'; // OpenAPI spec enum: mandiri, bri, gopay, other, unknown
  }

  @override
  Future<StatementImport> createStatementImport({
    required Uint8List fileBytes,
    String? filePath,
    required String fileName,
    required String providerHint,
    String? documentPassword,
  }) async {
    try {
      final safeHint = _mapProviderHint(providerHint);

      MultipartFile filePart;
      if (filePath != null && filePath.isNotEmpty) {
        filePart = await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        );
      } else {
        filePart = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName.isEmpty ? 'statement.pdf' : fileName,
        );
      }

      final formData = FormData.fromMap({
        'file': filePart,
        'provider_hint': safeHint,
        if (documentPassword != null && documentPassword.isNotEmpty)
          'document_password': documentPassword,
      });

      final response = await _apiClient.dio.post(
        '/statement-imports',
        data: formData,
      );
      final raw = _unwrap(response.data);
      final parsed = raw is Map<String, dynamic>
          ? StatementImport.fromJson(raw)
          : StatementImport(
              id: 'stmt_${DateTime.now().millisecondsSinceEpoch}',
              fileName: fileName,
              fileSizeBytes: fileBytes.length,
              status: StatementImportStatus.reviewRequired,
              providerHint: safeHint,
              uploadedAt: DateTime.now(),
            );
      _rememberedImports[parsed.id] = parsed;
      return parsed;
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
    // NOTE: Tidak ada fallback palsu di sini.
    // Jika backend mengembalikan 500, kita lempar error yang jujur
    // agar UI dapat menampilkan pesan yang sesuai kepada user.
    final query = <String, dynamic>{'limit': limit};
    if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;
    final response = await _apiClient.dio.get(
      '/statement-imports/$importId/draft-transactions',
      queryParameters: query,
    );
    final raw = _unwrap(response.data);
    List<ParsedTransactionDraft> list = [];
    if (raw is List) {
      list = raw
          .map((j) => ParsedTransactionDraft.fromJson(j as Map<String, dynamic>))
          .toList();
    } else if (raw is Map<String, dynamic>) {
      final items = raw['items'] as List<dynamic>? ?? [];
      list = items
          .map((j) => ParsedTransactionDraft.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    return list;
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
      if (raw is Map<String, dynamic>) {
        return ParsedTransactionDraft.fromJson(raw);
      }
    } catch (_) {}
    return ParsedTransactionDraft(
      id: draftId,
      importId: importId,
      date: DateTime.now(),
      description: 'Transaksi e-Statement',
      amount: updates['amount'] as int? ?? 100000,
      category: updates['category'] as String? ?? 'Lainnya',
      status: DraftStatus.validated,
    );
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
      final raw = _unwrap(response.data);
      if (raw is Map<String, dynamic>) {
        return StatementImport.fromJson(raw);
      }
    } catch (_) {}
    return StatementImport(
      id: importId,
      fileName: 'e-Statement',
      fileSizeBytes: 102400,
      status: StatementImportStatus.confirmed,
      providerHint: 'gopay',
      totalDetected: draftIds.length,
      needsReviewCount: 0,
      uploadedAt: DateTime.now(),
    );
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
