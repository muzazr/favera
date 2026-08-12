import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/router/route_names.dart';
import 'package:app/app/router/route_redirect.dart';

void main() {
  group('RouteRedirect Guard Matrix Tests', () {
    test('redirects to onboarding if onboardingCompleted is false and not authenticated', () {
      const state = RouteState(
        onboardingCompleted: false,
        isAuthenticated: false,
        profileCompleted: false,
        familyPaired: false,
      );

      final redirect = RouteRedirect.handleRedirect(
        location: AppRoutePaths.home,
        state: state,
      );

      expect(redirect, equals(AppRoutePaths.onboarding));
    });

    test('redirects to login if isAuthenticated is false', () {
      const state = RouteState(
        onboardingCompleted: true,
        isAuthenticated: false,
        profileCompleted: false,
        familyPaired: false,
      );

      final redirect = RouteRedirect.handleRedirect(
        location: AppRoutePaths.home,
        state: state,
      );

      expect(redirect, equals(AppRoutePaths.login));
    });

    test('redirects to profileSetup if profileCompleted is false', () {
      const state = RouteState(
        onboardingCompleted: true,
        isAuthenticated: true,
        profileCompleted: false,
        familyPaired: false,
      );

      final redirect = RouteRedirect.handleRedirect(
        location: AppRoutePaths.home,
        state: state,
      );

      expect(redirect, equals(AppRoutePaths.profileSetup));
    });

    test('allows home route when authenticated and profile completed even if familyPaired is false', () {
      const state = RouteState(
        onboardingCompleted: true,
        isAuthenticated: true,
        profileCompleted: true,
        familyPaired: false,
      );

      final redirect = RouteRedirect.handleRedirect(
        location: AppRoutePaths.home,
        state: state,
      );

      expect(redirect, isNull);
    });

    test('allows target route when all conditions are satisfied', () {
      const state = RouteState(
        onboardingCompleted: true,
        isAuthenticated: true,
        profileCompleted: true,
        familyPaired: true,
      );

      final redirect = RouteRedirect.handleRedirect(
        location: AppRoutePaths.home,
        state: state,
      );

      expect(redirect, isNull);
    });

    test('redirects to home if fully setup user tries to open login page', () {
      const state = RouteState(
        onboardingCompleted: true,
        isAuthenticated: true,
        profileCompleted: true,
        familyPaired: true,
      );

      final redirect = RouteRedirect.handleRedirect(
        location: AppRoutePaths.login,
        state: state,
      );

      expect(redirect, equals(AppRoutePaths.home));
    });
  });
}
