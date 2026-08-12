import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _onboardingKey = 'favera_onboarding_completed_flag';

  RouteStateNotifier([RouteState? initial])
      : super(initial ?? RouteState.initial()) {
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_onboardingKey) ?? false;
      if (completed) {
        state = state.copyWith(onboardingCompleted: true);
      }
    } catch (_) {}
  }

  Future<void> setOnboardingCompleted(bool val) async {
    state = state.copyWith(onboardingCompleted: val);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, val);
    } catch (_) {}
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

  Future<void> resetState() async {
    state = RouteState.initial();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
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
    final isDebugRoute = location.startsWith('/debug/');
    final isPreview = location.contains('preview=true');

    // Debug routes and explicit preview requests bypass guards in dev mode
    if ((isDebugRoute || isPreview) && kDebugMode) {
      return null;
    }

    // 1. Unauthenticated Users Guard
    if (!state.isAuthenticated) {
      // First-time app open: show onboarding intro slider if not completed yet
      if (!state.onboardingCompleted) {
        return isOnboardingRoute ? null : AppRoutePaths.onboarding;
      }
      // Otherwise show login/auth screens
      return isAuthRoute ? null : AppRoutePaths.login;
    }

    // 2. Authenticated Users Guard
    // 2a. Profile Completion Guard
    if (!state.profileCompleted) {
      return isProfileSetupRoute ? null : AppRoutePaths.profileSetup;
    }

    // 2b. If authenticated and profile is completed, prevent stuck on onboarding/auth/profile screens
    if (isOnboardingRoute || isAuthRoute || isProfileSetupRoute) {
      return AppRoutePaths.home;
    }

    return null;
  }
}
