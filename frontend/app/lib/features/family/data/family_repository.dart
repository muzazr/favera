import '../../../shared/models/check_in_model.dart';
import '../../../shared/models/family_model.dart';

abstract class FamilyRepository {
  Future<FamilySpace?> getFamilySpace();
  Future<List<FamilyInvitation>> getInvitations();
  Future<FamilyInvitation> createInvitation({String? inviteeEmail});
  Future<FamilySpace> acceptInvitation({
    required String inviteCode,
    bool grantFinancialConsent = true,
    bool grantCheckInConsent = true,
  });
  Future<FamilyInvitation> rejectInvitation({required String inviteCode});
  Future<void> deleteInvitation({required String invitationId});
  Future<FamilySpace> updateSettings(Map<String, dynamic> settings);
  Future<FamilySpace> updateConsents({
    required bool shareFinancialSummary,
    required bool shareCheckInSummary,
  });
  Future<void> disconnectFamily({String? password, String? reason});

  // Check-In & Assessment
  Future<WeeklyCheckIn?> getCurrentCheckIn();
  Future<WeeklyCheckIn> submitCheckInAnswers({
    required String checkInId,
    required String emotion,
    required String concern,
  });
  Future<WeeklyCheckIn?> simulatePartnerSubmit(String checkInId);
  Future<FamilyAssessment?> getCurrentFamilyAssessment();
}
