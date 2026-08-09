import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  RouteState copyWith({
    bool? onboardingCompleted,
    bool? isAuthenticated,
    bool? profileCompleted,
    bool? familyPaired,
  }) {
    return RouteState(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      familyPaired: familyPaired ?? this.familyPaired,
    );
  }

  factory RouteState.initial() {
    return const RouteState(
      onboardingCompleted: false,
      isAuthenticated: false,
      profileCompleted: false,
      familyPaired: false,
    );
  }
}

class RouteStateNotifier extends StateNotifier<RouteState> {
  RouteStateNotifier([RouteState? initial])
      : super(initial ?? RouteState.initial());

  void setOnboardingCompleted(bool val) {
    state = state.copyWith(onboardingCompleted: val);
  }

  void setAuthenticated(bool val) {
    state = state.copyWith(isAuthenticated: val);
  }

  void setProfileCompleted(bool val) {
    state = state.copyWith(profileCompleted: val);
  }

  void setFamilyPaired(bool val) {
    state = state.copyWith(familyPaired: val);
  }
}

final routeStateProvider =
    StateNotifierProvider<RouteStateNotifier, RouteState>((ref) {
  return RouteStateNotifier();
});

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
