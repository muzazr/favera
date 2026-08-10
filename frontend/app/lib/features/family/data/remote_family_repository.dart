import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../shared/models/check_in_model.dart';
import '../../../shared/models/family_model.dart';
import 'family_repository.dart';

class RemoteFamilyRepository implements FamilyRepository {
  final ApiClient apiClient;

  RemoteFamilyRepository({required this.apiClient});

  @override
  Future<FamilySpace> createSpace() async {
    try {
      final response = await apiClient.dio.post('/family/spaces');
      final data = response.data['data'] as Map<String, dynamic>;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FamilySpace?> getFamilySpace() async {
    try {
      final response = await apiClient.dio.get('/family/spaces/me');
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  @override
  Future<FamilySpace> joinSpace({required String inviteCode}) async {
    try {
      final response = await apiClient.dio.post('/family/spaces/join', data: {
        'invite_code': inviteCode,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> disconnectSpace({required String spaceId}) async {
    try {
      await apiClient.dio.post('/family/spaces/disconnect', data: {
        'space_id': spaceId,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<FamilySpace>> getInvitations() async {
    try {
      final response = await apiClient.dio.get('/family/invitations');
      final list = response.data['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => FamilySpace.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<FamilySpace> acceptInvitation({required String invitationId}) async {
    try {
      final response = await apiClient.dio.post(
        '/family/invitations/accept',
        data: {'invitation_id': invitationId},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> rejectInvitation({required String invitationId}) async {
    try {
      await apiClient.dio.post(
        '/family/invitations/reject',
        data: {'invitation_id': invitationId},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<WeeklyCheckIn?> getCurrentCheckIn() async {
    try {
      final response = await apiClient.dio.get('/check-ins/current');
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return WeeklyCheckIn.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  @override
  Future<WeeklyCheckIn> submitCheckInAnswers({
    required String checkInId,
    required String emotion,
    required String concern,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/check-ins/$checkInId/submit',
        data: {
          'my_emotion': emotion,
          'main_concern': concern,
        },
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return WeeklyCheckIn.fromJson(data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<WeeklyCheckIn?> simulatePartnerSubmit(String checkInId) async {
    try {
      final response = await apiClient.dio.post(
        '/check-ins/$checkInId/simulate-partner-submit',
      );
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return WeeklyCheckIn.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _handleDioError(e);
    }
  }

  @override
  Future<FamilyAssessment?> getCurrentFamilyAssessment() async {
    try {
      final response = await apiClient.dio.get('/family-assessments/current');
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      return FamilyAssessment.fromJson(data);
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
