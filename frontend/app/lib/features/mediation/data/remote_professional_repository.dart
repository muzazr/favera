import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
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
      final dataMap = response.data as Map<String, dynamic>;
      final list = (dataMap['items'] ?? dataMap['data']) as List<dynamic>? ?? [];
      return list
          .map((e) => Professional.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Professional?> getProfessionalDetail(String id) async {
    try {
      final response = await apiClient.dio.get('/professionals/$id');
      final dataMap = response.data as Map<String, dynamic>;
      final data = (dataMap['data'] ?? dataMap) as Map<String, dynamic>?;
      if (data == null) return null;
      return Professional.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }
}
