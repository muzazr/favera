import 'package:flutter_test/flutter_test.dart';
import 'package:app/mock/mock_clock.dart';

void main() {
  group('MockClock Tests', () {
    test('initializes with fixed UTC time', () {
      final clock = MockClock(DateTime.utc(2026, 8, 9, 10, 0, 0));
      expect(clock.now(), equals(DateTime.utc(2026, 8, 9, 10, 0, 0)));
    });

    test('advance adds duration accurately', () {
      final clock = MockClock(DateTime.utc(2026, 8, 9, 10, 0, 0));
      clock.advance(const Duration(hours: 2));
      expect(clock.now(), equals(DateTime.utc(2026, 8, 9, 12, 0, 0)));
    });
  });
}
