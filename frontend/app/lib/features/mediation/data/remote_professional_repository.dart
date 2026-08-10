import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/models/professional_model.dart';
import 'professional_repository.dart';

class RemoteProfessionalRepository implements ProfessionalRepository {
  final ApiClient apiClient;

  RemoteProfessionalRepository({required this.apiClient});

  @override
  Future<List<Professional>> getProfessionals({String? category}) async {
    try {
      final response = await apiClient.dio.get(
        '/professionals',
        queryParameters: {
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => Professional.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Professional?> getProfessionalDetail(String id) async {
    try {
      final response = await apiClient.dio.get('/professionals/$id');
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return Professional.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  AppFailure _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data?['message'] as String? ??
        e.message ??
        'Terjadi kesalahan server';
    if (status == 401) return AuthFailure(message: msg);
    if (status == 404) return NotFoundFailure(message: msg);
    if (status == 400 || status == 422) return ValidationFailure(message: msg);
    return NetworkFailure(message: msg);
  }
}
