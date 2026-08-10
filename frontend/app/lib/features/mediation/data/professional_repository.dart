import '../../../shared/models/professional_model.dart';

abstract class ProfessionalRepository {
  Future<List<Professional>> getProfessionals({String? category});
  Future<Professional?> getProfessionalDetail(String id);
}
