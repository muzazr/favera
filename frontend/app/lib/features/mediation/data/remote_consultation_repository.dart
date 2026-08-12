import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/consultation_model.dart';
import 'consultation_repository.dart';

class RemoteConsultationRepository implements ConsultationRepository {
  final ApiClient apiClient;

  RemoteConsultationRepository({required this.apiClient});

  static dynamic _unwrap(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }

  @override
  Future<List<Consultation>> getConsultations() async {
    try {
      final response = await apiClient.dio.get('/consultations');
      final raw = _unwrap(response.data);
      if (raw is List) {
        return raw
            .map((e) => Consultation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final items = ((raw as Map<String, dynamic>?)?['items'] as List<dynamic>?) ?? [];
      return items
          .map((e) => Consultation.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Consultation?> getConsultationDetail(String id) async {
    try {
      final response = await apiClient.dio.get('/consultations/$id');
      final raw = _unwrap(response.data);
      if (raw == null) return null;
      return Consultation.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Consultation> createConsultation({
    required String professionalId,
    required DateTime scheduledAt,
    String? topic,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/consultations',
        data: {
          'professional_id': professionalId,
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
          if (topic != null && topic.isNotEmpty) 'topic': topic,
        },
      );
      final raw = _unwrap(response.data);
      return Consultation.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<Consultation> updateChecklist(
    String consultationId,
    List<ConsultationCheckitem> checklist,
  ) async {
    try {
      final response = await apiClient.dio.put(
        '/consultations/$consultationId/checklist',
        data: {
          'checklist': checklist.map((e) => e.toJson()).toList(),
        },
      );
      final raw = _unwrap(response.data);
      return Consultation.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<ConsultationNote> addNote(
    String consultationId, {
    required String content,
    bool isSharedWithPartner = false,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/consultations/$consultationId/notes',
        data: {
          'content': content,
          'is_shared_with_partner': isSharedWithPartner,
        },
      );
      final raw = _unwrap(response.data);
      return ConsultationNote.fromJson(raw as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<bool> convertToCommitment(String consultationId, String title) async {
    try {
      await apiClient.dio.post(
        '/consultations/$consultationId/convert-to-commitment',
        data: {'title': title},
      );
      return true;
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
