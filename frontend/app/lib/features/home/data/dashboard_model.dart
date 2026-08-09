import '../../../shared/models/family_model.dart';
import '../../../shared/models/goal_model.dart';
import '../../../shared/models/transaction_model.dart';

class DashboardSummary {
  final int totalBalance;
  final int monthlyIncome;
  final int monthlyExpense;
  final String userName;
  final String? partnerName;
  final FamilyStatus familyStatus;
  final List<Transaction> recentTransactions;
  final FinancialGoal? activeGoal;
  final bool hasPendingCheckIn;

  const DashboardSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.userName,
    this.partnerName,
    required this.familyStatus,
    required this.recentTransactions,
    this.activeGoal,
    this.hasPendingCheckIn = true,
  });
}
