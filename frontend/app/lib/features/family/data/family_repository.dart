import '../../../shared/models/family_model.dart';

abstract class FamilyRepository {
  Future<FamilySpace> createSpace();
  Future<FamilySpace?> getFamilySpace();
  Future<FamilySpace> joinSpace({required String inviteCode});
  Future<void> disconnectSpace({required String spaceId});
  Future<List<FamilySpace>> getInvitations();
  Future<FamilySpace> acceptInvitation({required String invitationId});
  Future<void> rejectInvitation({required String invitationId});
}
