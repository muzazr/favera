class MockLatency {
  final bool isFastMode;
  final Duration defaultDuration;

  const MockLatency({
    this.isFastMode = false,
    this.defaultDuration = const Duration(milliseconds: 300),
  });

  Future<void> delay([Duration? duration]) async {
    if (isFastMode) return;
    await Future.delayed(duration ?? defaultDuration);
  }
}
