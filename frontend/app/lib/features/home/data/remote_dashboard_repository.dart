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
      // 1. Try single endpoint /dashboard if backend implements it
      try {
        final response = await apiClient.dio.get('/dashboard');
        final data = _extractData(response.data);

        final rawTransactions =
            data['recent_transactions'] as List<dynamic>? ?? [];
        final recentTx = rawTransactions
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();

        final rawGoal = data['active_goal'] as Map<String, dynamic>?;
        final activeGoal =
            rawGoal != null ? FinancialGoal.fromJson(rawGoal) : null;

        final familyStatusStr = data['family_status'] as String? ?? 'active';
        final familyStatus = _parseFamilyStatus(familyStatusStr);

        return DashboardSummary(
          totalBalance: (data['total_balance'] as num?)?.toInt() ?? 0,
          monthlyIncome: (data['monthly_income'] as num?)?.toInt() ?? 0,
          monthlyExpense: (data['monthly_expense'] as num?)?.toInt() ?? 0,
          userName: data['user_name'] as String? ?? '',
          partnerName: data['partner_name'] as String?,
          familyStatus: familyStatus,
          recentTransactions: recentTx,
          activeGoal: activeGoal,
          hasPendingCheckIn: data['has_pending_check_in'] as bool? ?? false,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        // If /dashboard returns 404 (not in OpenAPI spec), fall back to public endpoints aggregation
      }

      // 2. Fallback Aggregation from Standard OpenAPI Endpoints
      List<Transaction> recentTx = [];
      int totalBalance = 0;
      int monthlyIncome = 0;
      int monthlyExpense = 0;

      try {
        final txResponse = await apiClient.dio
            .get('/transactions', queryParameters: {'limit': 20});
        final rawTx = _extractList(txResponse.data);
        recentTx = rawTx
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();

        for (final tx in recentTx) {
          if (tx.direction == TransactionDirection.income) {
            monthlyIncome += tx.amount;
            totalBalance += tx.amount;
          } else {
            monthlyExpense += tx.amount;
            totalBalance -= tx.amount;
          }
        }
      } catch (_) {}

      String userName = 'Pengguna';
      String? partnerName;
      FamilyStatus familyStatus = FamilyStatus.active;

      try {
        final userResp = await apiClient.dio.get('/me');
        final userData = _extractData(userResp.data);
        userName = userData['display_name'] as String? ??
            userData['name'] as String? ??
            userData['email'] as String? ??
            'Pengguna';
      } catch (_) {}

      try {
        final famResp = await apiClient.dio.get('/families/current');
        final famData = _extractData(famResp.data);
        familyStatus = _parseFamilyStatus(famData['status'] as String?);
        partnerName = famData['partner_name'] as String? ??
            famData['partner_email'] as String?;
      } catch (_) {}

      FinancialGoal? activeGoal;
      try {
        final goalsResp =
            await apiClient.dio.get('/goals', queryParameters: {'limit': 1});
        final rawGoals = _extractList(goalsResp.data);
        if (rawGoals.isNotEmpty) {
          activeGoal =
              FinancialGoal.fromJson(rawGoals.first as Map<String, dynamic>);
        }
      } catch (_) {}

      bool hasPendingCheckIn = false;
      try {
        final chkResp = await apiClient.dio.get('/check-ins/current');
        final chkData = _extractData(chkResp.data);
        final status = chkData['status'] as String?;
        hasPendingCheckIn = status == 'open' || status == 'waiting_for_partner';
      } catch (_) {}

      return DashboardSummary(
        totalBalance: totalBalance,
        monthlyIncome: monthlyIncome,
        monthlyExpense: monthlyExpense,
        userName: userName,
        partnerName: partnerName,
        familyStatus: familyStatus,
        recentTransactions: recentTx,
        activeGoal: activeGoal,
        hasPendingCheckIn: hasPendingCheckIn,
      );
    } on DioException catch (e) {
      throw ApiErrorDecoder.decode(e);
    }
  }

  Map<String, dynamic> _extractData(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      return data['data'] as Map<String, dynamic>? ?? {};
    }
    return data is Map<String, dynamic> ? data : {};
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final inner = data['data'];
      if (inner is List) return inner;
      if (inner is Map<String, dynamic> && inner.containsKey('items')) {
        return inner['items'] as List<dynamic>? ?? [];
      }
    }
    if (data is List) return data;
    return [];
  }

  FamilyStatus _parseFamilyStatus(String? statusStr) {
    if (statusStr == null) return FamilyStatus.active;
    switch (statusStr.toLowerCase()) {
      case 'pending':
      case 'pendingpairing':
      case 'pending_pairing':
        return FamilyStatus.pendingPairing;
      case 'disconnected':
        return FamilyStatus.disconnected;
      case 'unpaired':
        return FamilyStatus.unpaired;
      case 'active':
      default:
        return FamilyStatus.active;
    }
  }
}
