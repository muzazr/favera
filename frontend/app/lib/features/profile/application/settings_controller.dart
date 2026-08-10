import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings {
  final bool weeklyCheckInReminder;
  final bool eStatementNotification;
  final bool darkMode;
  final bool biometricLogin;
  final bool hideBalance;

  const AppSettings({
    this.weeklyCheckInReminder = true,
    this.eStatementNotification = true,
    this.darkMode = false,
    this.biometricLogin = true,
    this.hideBalance = false,
  });

  AppSettings copyWith({
    bool? weeklyCheckInReminder,
    bool? eStatementNotification,
    bool? darkMode,
    bool? biometricLogin,
    bool? hideBalance,
  }) {
    return AppSettings(
      weeklyCheckInReminder:
          weeklyCheckInReminder ?? this.weeklyCheckInReminder,
      eStatementNotification:
          eStatementNotification ?? this.eStatementNotification,
      darkMode: darkMode ?? this.darkMode,
      biometricLogin: biometricLogin ?? this.biometricLogin,
      hideBalance: hideBalance ?? this.hideBalance,
    );
  }
}

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController() : super(const AppSettings());

  void toggleWeeklyCheckInReminder(bool value) {
    state = state.copyWith(weeklyCheckInReminder: value);
  }

  void toggleEStatementNotification(bool value) {
    state = state.copyWith(eStatementNotification: value);
  }

  void toggleDarkMode(bool value) {
    state = state.copyWith(darkMode: value);
  }

  void toggleBiometricLogin(bool value) {
    state = state.copyWith(biometricLogin: value);
  }

  void toggleHideBalance(bool value) {
    state = state.copyWith(hideBalance: value);
  }
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(),
);
