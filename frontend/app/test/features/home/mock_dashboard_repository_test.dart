import 'package:flutter_test/flutter_test.dart';
import 'package:app/features/home/data/mock_dashboard_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_error_policy.dart';
import 'package:app/mock/mock_latency.dart';
import 'package:app/mock/mock_store.dart';

void main() {
  group('MockDashboardRepository Tests', () {
    late MockStore store;
    late MockDashboardRepository repository;

    setUp(() {
      store = MockStore(clock: MockClock())..resetToSeed(preAuthenticate: true);
      repository = MockDashboardRepository(
        mockStore: store,
        latency: const MockLatency(isFastMode: true),
        errorPolicy: MockErrorPolicy(),
      );
    });

    test(
        'getDashboardSummary returns accurate totals and transactions from store',
        () async {
      final summary = await repository.getDashboardSummary();

      expect(summary.totalBalance, equals(12500000));
      expect(summary.monthlyIncome, equals(5500000));
      expect(summary.monthlyExpense, equals(600000));
      expect(summary.userName, equals('Joselin'));
      expect(summary.partnerName, equals('Budi'));
      expect(summary.recentTransactions.length, equals(3));
    });
  });
}
