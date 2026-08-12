import '../../core/utils/uuid_utils.dart';

enum StatementImportStatus {
  uploaded,
  passwordRequired,
  parsing,
  reviewRequired,
  confirmed,
  failed,
  cancelled,
}

enum DraftStatus {
  pending,
  validated,
  deleted,
}

class StatementImport {
  final String id;
  final String fileName;
  final int fileSizeBytes;
  final StatementImportStatus status;
  final String providerHint;
  final bool requiresPassword;
  final int totalDetected;
  final int needsReviewCount;
  final DateTime uploadedAt;
  final String? errorMessage;

  const StatementImport({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
    required this.status,
    required this.providerHint,
    this.requiresPassword = false,
    this.totalDetected = 0,
    this.needsReviewCount = 0,
    required this.uploadedAt,
    this.errorMessage,
  });

  factory StatementImport.fromJson(Map<String, dynamic> json) {
    String rawId = json['id']?.toString() ??
        json['import_id']?.toString() ??
        json['statement_import_id']?.toString() ??
        json['statementImportId']?.toString() ??
        json['importId']?.toString() ??
        json['_id']?.toString() ??
        json['statement_id']?.toString() ??
        json['id_statement']?.toString() ??
        '';

    if (rawId.isEmpty) {
      // Check nested map if any (import_session, statement_import, import, data, result)
      final nested = json['import_session'] ??
          json['statement_import'] ??
          json['import'] ??
          json['data'] ??
          json['result'];
      if (nested is Map<String, dynamic>) {
        rawId = nested['id']?.toString() ??
            nested['import_id']?.toString() ??
            nested['statement_import_id']?.toString() ??
            nested['statementImportId']?.toString() ??
            nested['importId']?.toString() ??
            '';
      }
    }

    if (rawId.isEmpty) {
      rawId = UuidUtils.generateV4();
    }

    final rawFileName = json['file_name'] ??
        json['filename'] ??
        json['name'] ??
        'e-statement.pdf';
    final rawFileSize =
        json['file_size_bytes'] ?? json['file_size'] ?? json['size'] ?? 0;
    final rawStatus = json['status'] as String? ?? 'review_required';
    final rawProvider =
        json['provider_hint'] ?? json['provider'] ?? json['bank'] ?? 'other';
    final rawUploadedAt = json['uploaded_at'] ??
        json['created_at'] ??
        json['uploaded'] ??
        DateTime.now().toIso8601String();

    return StatementImport(
      id: rawId,
      fileName: rawFileName as String,
      fileSizeBytes: (rawFileSize as num).toInt(),
      status: _parseStatus(rawStatus),
      providerHint: rawProvider as String,
      requiresPassword: json['requires_password'] as bool? ?? false,
      totalDetected: (json['total_detected'] as num? ?? 0).toInt(),
      needsReviewCount: (json['needs_review_count'] as num? ?? 0).toInt(),
      uploadedAt: rawUploadedAt is String
          ? DateTime.tryParse(rawUploadedAt) ?? DateTime.now()
          : DateTime.now(),
      errorMessage: json['error_message'] as String?,
    );
  }

  static StatementImportStatus _parseStatus(String statusStr) {
    switch (statusStr) {
      case 'password_required':
        return StatementImportStatus.passwordRequired;
      case 'parsing':
        return StatementImportStatus.parsing;
      case 'review_required':
        return StatementImportStatus.reviewRequired;
      case 'confirmed':
        return StatementImportStatus.confirmed;
      case 'failed':
        return StatementImportStatus.failed;
      case 'cancelled':
        return StatementImportStatus.cancelled;
      default:
        return StatementImportStatus.uploaded;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_size_bytes': fileSizeBytes,
      'status': _statusToString(status),
      'provider_hint': providerHint,
      'requires_password': requiresPassword,
      'total_detected': totalDetected,
      'needs_review_count': needsReviewCount,
      'uploaded_at': uploadedAt.toUtc().toIso8601String(),
      'error_message': errorMessage,
    };
  }

  static String _statusToString(StatementImportStatus status) {
    switch (status) {
      case StatementImportStatus.passwordRequired:
        return 'password_required';
      case StatementImportStatus.parsing:
        return 'parsing';
      case StatementImportStatus.reviewRequired:
        return 'review_required';
      case StatementImportStatus.confirmed:
        return 'confirmed';
      case StatementImportStatus.failed:
        return 'failed';
      case StatementImportStatus.cancelled:
        return 'cancelled';
      case StatementImportStatus.uploaded:
        return 'uploaded';
    }
  }

  StatementImport copyWith({
    String? id,
    String? fileName,
    int? fileSizeBytes,
    StatementImportStatus? status,
    String? providerHint,
    bool? requiresPassword,
    int? totalDetected,
    int? needsReviewCount,
    DateTime? uploadedAt,
    String? errorMessage,
  }) {
    return StatementImport(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      status: status ?? this.status,
      providerHint: providerHint ?? this.providerHint,
      requiresPassword: requiresPassword ?? this.requiresPassword,
      totalDetected: totalDetected ?? this.totalDetected,
      needsReviewCount: needsReviewCount ?? this.needsReviewCount,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ParsedTransactionDraft {
  final String id;
  final String importId;
  final DateTime date;
  final String description;
  final int amount;
  final String category;
  final DraftStatus status;
  final String? anomalyReason;

  const ParsedTransactionDraft({
    required this.id,
    required this.importId,
    required this.date,
    required this.description,
    required this.amount,
    required this.category,
    this.status = DraftStatus.pending,
    this.anomalyReason,
  });

  factory ParsedTransactionDraft.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ??
        json['draft_id']?.toString() ??
        json['_id']?.toString() ??
        UuidUtils.generateV4();
    final rawImportId = json['import_id']?.toString() ??
        json['statement_import_id']?.toString() ??
        json['importId']?.toString() ??
        '';

    DateTime parsedDate;
    try {
      final dateVal = json['transaction_at'] ??
          json['date'] ??
          json['transaction_date'] ??
          json['created_at'];
      if (dateVal is String) {
        parsedDate = DateTime.parse(dateVal);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return ParsedTransactionDraft(
      id: rawId,
      importId: rawImportId,
      date: parsedDate,
      description: (json['description'] ?? json['narrative'] ?? json['title'] ?? 'Transaksi')
          .toString(),
      amount: ((json['amount'] ?? json['nominal'] ?? 0) as num).toInt(),
      category: (json['category'] ?? json['pos'] ?? 'Lainnya').toString(),
      status: DraftStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DraftStatus.pending,
      ),
      anomalyReason: json['anomaly_reason']?.toString() ?? json['flag_reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'import_id': importId,
      'date': date.toUtc().toIso8601String(),
      'description': description,
      'amount': amount,
      'category': category,
      'status': status.name,
      'anomaly_reason': anomalyReason,
    };
  }

  ParsedTransactionDraft copyWith({
    String? id,
    String? importId,
    DateTime? date,
    String? description,
    int? amount,
    String? category,
    DraftStatus? status,
    String? anomalyReason,
  }) {
    return ParsedTransactionDraft(
      id: id ?? this.id,
      importId: importId ?? this.importId,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      status: status ?? this.status,
      anomalyReason: anomalyReason ?? this.anomalyReason,
    );
  }
}
