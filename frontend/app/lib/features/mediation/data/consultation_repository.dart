import '../../../shared/models/consultation_model.dart';

abstract class ConsultationRepository {
  Future<List<Consultation>> getConsultations();
  Future<Consultation?> getConsultationDetail(String id);
  Future<Consultation> createConsultation({
    required String professionalId,
    required DateTime scheduledAt,
    String? topic,
  });
  Future<Consultation> updateChecklist(
    String consultationId,
    List<ConsultationCheckitem> checklist,
  );
  Future<ConsultationNote> addNote(
    String consultationId, {
    required String content,
    bool isSharedWithPartner = false,
  });
  Future<bool> convertToCommitment(String consultationId, String title);
}
