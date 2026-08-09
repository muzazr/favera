import 'package:flutter/foundation.dart';
import 'route_names.dart';

class RouteState {
  final bool onboardingCompleted;
  final bool isAuthenticated;
  final bool profileCompleted;
  final bool familyPaired;

  const RouteState({
    required this.onboardingCompleted,
    required this.isAuthenticated,
    required this.profileCompleted,
    required this.familyPaired,
  });

  factory RouteState.initial() {
    return const RouteState(
      onboardingCompleted:
          true, // Set default true for dev preview unless forced
      isAuthenticated: true,
      profileCompleted: true,
      familyPaired: true,
    );
  }
}

abstract final class RouteRedirect {
  static String? handleRedirect({
    required String location,
    required RouteState state,
  }) {
    final isOnboardingRoute = location == AppRoutePaths.onboarding;
    final isAuthRoute = location.startsWith('/auth/');
    final isProfileSetupRoute = location == AppRoutePaths.profileSetup;
    final isFamilyConnectRoute = location.startsWith('/family/');
    final isDebugRoute = location.startsWith('/debug/');

    // Debug routes bypass standard redirect guards in dev mode
    if (isDebugRoute && kDebugMode) {
      return null;
    }

    // 1. Onboarding Guard
    if (!state.onboardingCompleted) {
      return isOnboardingRoute ? null : AppRoutePaths.onboarding;
    }

    // 2. Auth Guard
    if (!state.isAuthenticated) {
      return isAuthRoute ? null : AppRoutePaths.login;
    }

    // 3. Profile Completion Guard
    if (!state.profileCompleted) {
      return isProfileSetupRoute ? null : AppRoutePaths.profileSetup;
    }

    // 4. Family Pairing Guard
    if (!state.familyPaired) {
      return isFamilyConnectRoute ? null : AppRoutePaths.familyConnect;
    }

    // 5. If all onboarding/auth/profile/family requirements are met, prevent going back to auth screens
    if (isOnboardingRoute ||
        isAuthRoute ||
        isProfileSetupRoute ||
        isFamilyConnectRoute) {
      return AppRoutePaths.home;
    }

    return null;
  }
}
