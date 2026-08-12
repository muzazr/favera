import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/check_in_model.dart';
import '../../../shared/models/family_model.dart';
import 'family_repository.dart';

class RemoteFamilyRepository implements FamilyRepository {
  final ApiClient apiClient;

  RemoteFamilyRepository({required this.apiClient});

  dynamic _extractData(dynamic body) {
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  @override
  Future<FamilySpace?> getFamilySpace() async {
    try {
      final response = await apiClient.dio.get('/family');
      final data = _extractData(response.data);
      if (data == null || data is! Map<String, dynamic>) return null;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<List<FamilyInvitation>> getInvitations() async {
    try {
      final response = await apiClient.dio.get('/family/invitations');
      final data = _extractData(response.data);
      if (data is List) {
        return data
            .map((e) => FamilyInvitation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FamilyInvitation> createInvitation({String? inviteeEmail}) async {
    try {
      final response = await apiClient.dio.post(
        '/family/invitations',
        data: {
          if (inviteeEmail != null && inviteeEmail.isNotEmpty)
            'invitee_email': inviteeEmail,
        },
      );
      final data = _extractData(response.data) as Map<String, dynamic>;
      return FamilyInvitation.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FamilySpace> acceptInvitation({
    required String inviteCode,
    bool grantFinancialConsent = true,
    bool grantCheckInConsent = true,
  }) async {
    try {
      final categories = <String>[];
      if (grantFinancialConsent) categories.add('financial_summary');
      if (grantCheckInConsent) categories.add('check_in_summary');

      final response = await apiClient.dio.post(
        '/family/invitations/$inviteCode/accept',
        data: {
          'consent_version': '1.0',
          'shared_data_categories': categories,
        },
      );
      final data = _extractData(response.data) as Map<String, dynamic>;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FamilyInvitation> rejectInvitation({required String inviteCode}) async {
    try {
      final response = await apiClient.dio.post(
        '/family/invitations/$inviteCode/reject',
      );
      final data = _extractData(response.data) as Map<String, dynamic>;
      return FamilyInvitation.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<void> deleteInvitation({required String invitationId}) async {
    try {
      await apiClient.dio.delete('/family/invitations/$invitationId');
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FamilySpace> updateSettings(Map<String, dynamic> settings) async {
    try {
      final response = await apiClient.dio.patch(
        '/family/settings',
        data: settings,
      );
      final data = _extractData(response.data) as Map<String, dynamic>;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FamilySpace> updateConsents({
    required bool shareFinancialSummary,
    required bool shareCheckInSummary,
  }) async {
    try {
      final categories = <String>[];
      if (shareFinancialSummary) categories.add('financial_summary');
      if (shareCheckInSummary) categories.add('check_in_summary');

      final response = await apiClient.dio.post(
        '/family/consents',
        data: {
          'consent_version': '1.0',
          'shared_data_categories': categories,
        },
      );
      final data = _extractData(response.data) as Map<String, dynamic>;
      return FamilySpace.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<void> disconnectFamily({String? password, String? reason}) async {
    try {
      await apiClient.dio.post(
        '/family/disconnect',
        data: {
          if (password != null) 'password': password,
          if (reason != null) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<WeeklyCheckIn?> getCurrentCheckIn() async {
    try {
      final response = await apiClient.dio.get('/check-ins/current');
      final data = _extractData(response.data) as Map<String, dynamic>?;
      if (data == null) return null;
      return WeeklyCheckIn.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiErrorDecoder.decode(e);
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
      final data = _extractData(response.data) as Map<String, dynamic>;
      return WeeklyCheckIn.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<WeeklyCheckIn?> simulatePartnerSubmit(String checkInId) async {
    try {
      final response = await apiClient.dio.post(
        '/check-ins/$checkInId/submit',
      );
      final data = _extractData(response.data) as Map<String, dynamic>?;
      if (data == null) return null;
      return WeeklyCheckIn.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }

  @override
  Future<FamilyAssessment?> getCurrentFamilyAssessment() async {
    try {
      final response = await apiClient.dio.get('/family-assessments/current');
      final data = _extractData(response.data) as Map<String, dynamic>?;
      if (data == null) return null;
      return FamilyAssessment.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiErrorDecoder.decode(e);
    }
  }
}
