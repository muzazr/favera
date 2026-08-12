import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/errors/api_error_decoder.dart';
import '../../../shared/models/family_model.dart';
import '../../../shared/models/goal_model.dart';
import '../../../shared/models/transaction_model.dart';
import 'dashboard_model.dart';
import 'dashboard_repository.dart';

class RemoteDashboardRepository implements DashboardRepository {
  final ApiClient apiClient;

  RemoteDashboardRepository({required this.apiClient});

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await apiClient.dio.get('/dashboard');
      final data = response.data['data'] as Map<String, dynamic>;

      final rawTransactions =
          data['recent_transactions'] as List<dynamic>? ?? [];
      final recentTx = rawTransactions
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();

      final rawGoal = data['active_goal'] as Map<String, dynamic>?;
      final activeGoal =
          rawGoal != null ? FinancialGoal.fromJson(rawGoal) : null;

      final familyStatusStr = data['family_status'] as String? ?? 'active';
      final familyStatus = FamilyStatus.values.firstWhere(
        (e) => e.name == familyStatusStr,
        orElse: () => FamilyStatus.active,
      );

      return DashboardSummary(
        totalBalance: data['total_balance'] as int? ?? 0,
        monthlyIncome: data['monthly_income'] as int? ?? 0,
        monthlyExpense: data['monthly_expense'] as int? ?? 0,
        userName: data['user_name'] as String? ?? '',
        partnerName: data['partner_name'] as String?,
        familyStatus: familyStatus,
        recentTransactions: recentTx,
        activeGoal: activeGoal,
        hasPendingCheckIn: data['has_pending_check_in'] as bool? ?? false,
      );
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }
}
