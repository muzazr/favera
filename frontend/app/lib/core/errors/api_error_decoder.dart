import 'package:dio/dio.dart';
import 'app_failure.dart';

class ApiErrorDecoder {
  const ApiErrorDecoder._();

  static bool isNoContent(Response? response) {
    if (response == null) return false;
    if (response.statusCode == 204) return true;
    final data = response.data;
    if (data == null) return true;
    if (data is String && data.trim().isEmpty) return true;
    return false;
  }

  static AppFailure decode(DioException e) {
    final status = e.response?.statusCode;
    final responseData = e.response?.data;

    String? message;
    Map<String, String> fields = {};

    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] as String? ?? responseData['error'] as String?;
      if (responseData['errors'] is Map<String, dynamic>) {
        final errorsMap = responseData['errors'] as Map<String, dynamic>;
        fields = errorsMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      message = responseData;
    }

    message ??= e.message;

    final requestId = e.response?.headers.value('x-request-id') ??
        e.requestOptions.headers['X-Request-ID'] as String?;

    if (status == 401) {
      return UnauthorizedFailure(message: message ?? 'Sesi telah berakhir, silakan masuk kembali.');
    }
    if (status == 403) {
      return ForbiddenFailure(message: message ?? 'Anda tidak memiliki akses ke sumber daya ini.');
    }
    if (status == 404) {
      return NotFoundFailure(message: message ?? 'Data tidak ditemukan.');
    }
    if (status == 409) {
      return ConflictFailure(message: message ?? 'Terjadi konflik data.');
    }
    if (status == 400 || status == 422) {
      return ValidationFailure(
        message: message ?? 'Data yang dikirimkan tidak valid.',
        fields: fields,
      );
    }
    if (status != null && status >= 500) {
      return ServerFailure(
        requestId: requestId,
        message: message ?? 'Terjadi kesalahan pada server. Silakan coba lagi nanti.',
      );
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkFailure(message: message ?? 'Koneksi terganggu. Periksa jaringan Anda.');
    }

    return NetworkFailure(message: message ?? 'Terjadi kesalahan jaringan.');
  }
}
