import '../../../shared/models/check_in_model.dart';
import '../../../shared/models/family_model.dart';

abstract class FamilyRepository {
  Future<FamilySpace> createSpace();
  Future<FamilySpace?> getFamilySpace();
  Future<FamilySpace> joinSpace({required String inviteCode});
  Future<void> disconnectSpace({required String spaceId});
  Future<List<FamilySpace>> getInvitations();
  Future<FamilySpace> acceptInvitation({required String invitationId});
  Future<void> rejectInvitation({required String invitationId});

  // Check-In & Family Assessment (Part 10)
  Future<WeeklyCheckIn?> getCurrentCheckIn();
  Future<WeeklyCheckIn> submitCheckInAnswers({
    required String checkInId,
    required String emotion,
    required String concern,
  });
  Future<WeeklyCheckIn?> simulatePartnerSubmit(String checkInId);
  Future<FamilyAssessment?> getCurrentFamilyAssessment();
}
