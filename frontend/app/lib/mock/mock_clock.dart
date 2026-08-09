abstract interface class AppClock {
  DateTime now();
}

class SystemClock implements AppClock {
  @override
  DateTime now() => DateTime.now().toUtc();
}

class MockClock implements AppClock {
  DateTime fixedTime;

  MockClock([DateTime? initial])
      : fixedTime = initial ?? DateTime.utc(2026, 8, 9, 10, 0, 0);

  @override
  DateTime now() => fixedTime;

  void advance(Duration duration) {
    fixedTime = fixedTime.add(duration);
  }

  void setTime(DateTime dateTime) {
    fixedTime = dateTime.toUtc();
  }
}
