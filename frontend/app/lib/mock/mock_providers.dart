import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mock_clock.dart';
import 'mock_error_policy.dart';
import 'mock_latency.dart';
import 'mock_scenario.dart';
import 'mock_store.dart';

final mockClockProvider = Provider<AppClock>((ref) {
  return SystemClock();
});

final mockLatencyProvider = Provider<MockLatency>((ref) {
  return const MockLatency();
});

final mockScenarioProvider = StateProvider<MockScenario>((ref) {
  return MockScenario.happyPath;
});

final mockErrorPolicyProvider = Provider<MockErrorPolicy>((ref) {
  return MockErrorPolicy();
});

final mockStoreProvider = Provider<MockStore>((ref) {
  final clock = ref.watch(mockClockProvider);
  return MockStore(clock: clock);
});
