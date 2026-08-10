import 'package:app/features/goals/data/mock_goal_repository.dart';
import 'package:app/mock/mock_clock.dart';
import 'package:app/mock/mock_store.dart';
import 'package:app/shared/models/goal_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockStore store;
  late MockGoalRepository repository;

  setUp(() {
    final clock = MockClock(DateTime.utc(2026, 8, 10));
    store = MockStore(clock: clock)..resetToSeed(preAuthenticate: true);
    repository = MockGoalRepository(store: store);
  });

  group('MockGoalRepository Tests', () {
    test('getGoals returns initial seed goals', () async {
      final goals = await repository.getGoals();
      expect(goals, isNotEmpty);
      expect(goals.first.name, equals('Dana Darurat'));
    });

    test('getGoalById returns correct goal', () async {
      final goal = await repository.getGoalById('goal-001');
      expect(goal, isNotNull);
      expect(goal!.targetAmount, equals(10000000));
      expect(goal.currentAmount, equals(6000000));
    });

    test('createGoal adds new goal to store', () async {
      final newGoal = FinancialGoal(
        id: 'goal-new-test',
        name: 'DP Rumah',
        targetAmount: 50000000,
        currentAmount: 0,
        deadline: 'Desember 2028',
        themeIcon: 'house',
        createdAt: DateTime.utc(2026, 8, 10),
      );

      final created = await repository.createGoal(newGoal);
      expect(created.name, equals('DP Rumah'));

      final allGoals = await repository.getGoals();
      expect(allGoals.length, greaterThan(1));
    });

    test('addContribution updates goal currentAmount and contribution history',
        () async {
      final updated = await repository.addContribution(
        'goal-001',
        sourceName: 'Tabungan Tambahan',
        amount: 1000000,
      );

      expect(updated.currentAmount, equals(7000000));
      expect(
          updated.contributions.first.sourceName, equals('Tabungan Tambahan'));
      expect(updated.contributions.first.amount, equals(1000000));
    });
  });
}
