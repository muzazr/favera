abstract final class AppRouteNames {
  // Root & Onboarding
  static const String onboarding = 'onboarding';

  // Auth & Account
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String profileSetup = 'profileSetup';

  // Family Pairing & Assessment
  static const String familyConnect = 'familyConnect';
  static const String familyInvitation = 'familyInvitation';
  static const String familySuccess = 'familySuccess';
  static const String weeklyCheckIn = 'weeklyCheckIn';
  static const String familyCondition = 'familyCondition';

  // App Shell Root
  static const String appShell = 'appShell';
  static const String home = 'home';

  // Finance Domain
  static const String finance = 'finance';
  static const String transactions = 'transactions';
  static const String transactionNew = 'transactionNew';
  static const String transactionDetail = 'transactionDetail';
  static const String statementUpload = 'statementUpload';
  static const String statementReview = 'statementReview';
  static const String goals = 'goals';
  static const String goalNew = 'goalNew';
  static const String goalDetail = 'goalDetail';
  static const String goalEdit = 'goalEdit';

  // Mediation & Recovery Domain
  static const String mediation = 'mediation';
  static const String chatSessions = 'chatSessions';
  static const String chatDetail = 'chatDetail';
  static const String recoverySessions = 'recoverySessions';
  static const String recoveryDetail = 'recoveryDetail';
  static const String professionals = 'professionals';
  static const String professionalDetail = 'professionalDetail';
  static const String consultations = 'consultations';
  static const String simulationNew = 'simulationNew';
  static const String simulationDetail = 'simulationDetail';

  // Profile & Settings Domain
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String privacy = 'privacy';
  static const String familySettings = 'familySettings';

  // Debug Routes
  static const String debugRoutes = 'debugRoutes';
  static const String debugGallery = 'debugGallery';
}

abstract final class AppRoutePaths {
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String profileSetup = '/profile/setup';

  static const String familyConnect = '/family/connect';
  static const String familyInvitation = '/family/invitation';
  static const String familySuccess = '/family/success';
  static const String weeklyCheckIn = '/app/family/check-in';
  static const String familyCondition = '/app/family/condition';

  // Shell Tabs
  static const String home = '/app/home';
  static const String finance = '/app/finance';
  static const String mediation = '/app/mediation';
  static const String profile = '/app/profile';

  // Finance Sub-routes
  static const String transactions = '/app/finance/transactions';
  static const String transactionNew = '/app/finance/transactions/new';
  static const String transactionDetail = '/app/finance/transactions/:id';
  static String transactionDetailWithId(String id) =>
      '/app/finance/transactions/$id';
  static const String statementUpload = '/app/finance/statements/upload';
  static const String statementReview = '/app/finance/statements/:id/review';
  static const String goals = '/app/finance/goals';
  static const String goalNew = '/app/finance/goals/new';
  static const String goalDetail = '/app/finance/goals/:id';
  static const String goalEdit = '/app/finance/goals/:id/edit';

  // Mediation Sub-routes
  static const String chatSessions = '/app/mediation/chat';
  static const String chatDetail = '/app/mediation/chat/:sessionId';
  static const String recoverySessions = '/app/mediation/recovery';
  static const String recoveryDetail = '/app/mediation/recovery/:id';
  static const String professionals = '/app/mediation/professionals';
  static const String professionalDetail = '/app/mediation/professionals/:id';
  static const String consultations = '/app/mediation/consultations';
  static const String simulationNew = '/app/mediation/simulations/new';
  static const String simulationDetail = '/app/mediation/simulations/:id';

  // Profile Sub-routes
  static const String settings = '/app/profile/settings';
  static const String privacy = '/app/profile/privacy';
  static const String familySettings = '/app/profile/family-settings';

  // Debug Routes
  static const String debugRoutes = '/debug/routes';
  static const String debugGallery = '/debug/gallery';
}
