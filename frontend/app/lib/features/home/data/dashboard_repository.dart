import 'dashboard_model.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> getDashboardSummary();
}
