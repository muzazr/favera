import '../core/errors/app_failure.dart';

class MockErrorPolicy {
  bool shouldFailNextRequest;
  AppFailure? nextFailure;

  MockErrorPolicy({
    this.shouldFailNextRequest = false,
    this.nextFailure,
  });

  void triggerNextFailure(AppFailure failure) {
    shouldFailNextRequest = true;
    nextFailure = failure;
  }

  void checkAndThrow() {
    if (shouldFailNextRequest) {
      shouldFailNextRequest = false;
      final failure = nextFailure ??
          const NetworkFailure(message: 'Simulated network failure');
      nextFailure = null;
      throw failure;
    }
  }

  void reset() {
    shouldFailNextRequest = false;
    nextFailure = null;
  }
}
