import '../../../mock/mock_error_policy.dart';
import '../../../mock/mock_latency.dart';
import '../../../mock/mock_store.dart';
import '../../../shared/models/family_model.dart';
import '../../../shared/models/transaction_model.dart';
import 'dashboard_model.dart';
import 'dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  final MockStore mockStore;
  final MockLatency latency;
  final MockErrorPolicy errorPolicy;

  MockDashboardRepository({
    required this.mockStore,
    required this.latency,
    required this.errorPolicy,
  });

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    errorPolicy.checkAndThrow();
    await latency.delay();

    final user = mockStore.currentUser;
    final family = mockStore.family;
    final transactions = mockStore.getTransactions();
    final goals = mockStore.getGoals();

    int income = 0;
    int expense = 0;
    for (final tx in transactions) {
      if (tx.direction == TransactionDirection.income) {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }

    final recentTx = transactions.take(5).toList();
    final activeGoal = goals.isNotEmpty ? goals.first : null;

    return DashboardSummary(
      totalBalance: mockStore.getTotalBalance(),
      monthlyIncome: income,
      monthlyExpense: expense,
      userName: user?.name ?? 'Joselin',
      partnerName: family?.partnerName ?? 'Budi',
      familyStatus: family?.status ?? FamilyStatus.active,
      recentTransactions: recentTx,
      activeGoal: activeGoal,
      hasPendingCheckIn: true,
    );
  }
}
