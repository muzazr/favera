import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/consultation_model.dart';
import 'consultation_repository.dart';

class MockConsultationRepository implements ConsultationRepository {
  final MockStore mockStore;
  final Duration latency;
  final MockErrorPolicy? errorPolicy;

  final List<Consultation> _consultations = [];

  MockConsultationRepository({
    required this.mockStore,
    this.latency = const Duration(milliseconds: 300),
    this.errorPolicy,
  });

  Future<void> _simulateDelay() async {
    if (latency > Duration.zero) {
      await Future.delayed(latency);
    }
  }

  @override
  Future<List<Consultation>> getConsultations() async {
    await _simulateDelay();
    return List.from(_consultations);
  }

  @override
  Future<Consultation?> getConsultationDetail(String id) async {
    await _simulateDelay();
    try {
      return _consultations.firstWhere((element) => element.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Consultation> createConsultation({
    required String professionalId,
    required DateTime scheduledAt,
    String? topic,
  }) async {
    await _simulateDelay();
    final newConsultation = Consultation(
      id: 'cons-${DateTime.now().millisecondsSinceEpoch}',
      professionalId: professionalId,
      professionalName: 'Siti Rahma, M.Psi.',
      professionalTitle: 'Psikolog & Konsultan Pernikahan',
      scheduledAt: scheduledAt,
      status: ConsultationStatus.scheduled,
      topic: topic ?? 'Konseling Anggaran Keluarga',
      checklist: const [
        ConsultationCheckitem(id: 'chk-1', label: 'Catat riwayat pengeluaran 3 bulan terakhir'),
        ConsultationCheckitem(id: 'chk-2', label: 'Diskusikan prioritas dana darurat bersama'),
      ],
      createdAt: DateTime.now(),
    );
    _consultations.insert(0, newConsultation);
    return newConsultation;
  }

  @override
  Future<Consultation> updateChecklist(
    String consultationId,
    List<ConsultationCheckitem> checklist,
  ) async {
    await _simulateDelay();
    final idx = _consultations.indexWhere((element) => element.id == consultationId);
    if (idx != -1) {
      final updated = _consultations[idx].copyWith(checklist: checklist);
      _consultations[idx] = updated;
      return updated;
    }
    throw Exception('Consultation not found');
  }

  @override
  Future<ConsultationNote> addNote(
    String consultationId, {
    required String content,
    bool isSharedWithPartner = false,
  }) async {
    await _simulateDelay();
    final note = ConsultationNote(
      id: 'note-${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      authorName: 'Konsultan Favera',
      isSharedWithPartner: isSharedWithPartner,
      createdAt: DateTime.now(),
    );
    final idx = _consultations.indexWhere((element) => element.id == consultationId);
    if (idx != -1) {
      final existingNotes = List<ConsultationNote>.from(_consultations[idx].notes);
      existingNotes.add(note);
      _consultations[idx] = _consultations[idx].copyWith(notes: existingNotes);
    }
    return note;
  }

  @override
  Future<bool> convertToCommitment(String consultationId, String title) async {
    await _simulateDelay();
    return true;
  }
}
