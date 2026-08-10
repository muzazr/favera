import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/component_gallery_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/chat/presentation/pages/chat_detail_page.dart';
import '../../features/family/presentation/pages/family_condition_page.dart';
import '../../features/family/presentation/pages/family_connect_page.dart';
import '../../features/family/presentation/pages/family_invitation_page.dart';
import '../../features/family/presentation/pages/family_success_page.dart';
import '../../features/family/presentation/pages/weekly_check_in_page.dart';
import '../../features/finance/presentation/pages/finance_dashboard_page.dart';
import '../../features/finance/presentation/pages/transaction_detail_page.dart';
import '../../features/finance/presentation/pages/transaction_form_page.dart';
import '../../features/finance/presentation/pages/transaction_list_page.dart';
import '../../features/goals/presentation/pages/goal_detail_page.dart';
import '../../features/goals/presentation/pages/goal_form_page.dart';
import '../../features/goals/presentation/pages/goal_list_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/mediation/presentation/pages/mediation_hub_page.dart';
import '../../features/mediation/presentation/pages/professionals_page.dart';
import '../../features/mediation/presentation/pages/simulation_result_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_setup_page.dart';
import '../../features/recovery/presentation/pages/recovery_detail_page.dart';
import '../../features/recovery/presentation/pages/recovery_list_page.dart';
import 'package:app/features/statements/presentation/pages/statement_review_page.dart';
import '../../shared/widgets/placeholder_page.dart';
import '../shell/app_shell.dart';
import 'route_catalog_page.dart';
import 'route_names.dart';
import 'route_redirect.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<RouteState>(routeStateProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: AppRoutePaths.onboarding,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final routeState = ref.read(routeStateProvider);
      return RouteRedirect.handleRedirect(
        location: state.uri.path,
        state: routeState,
      );
    },
    errorBuilder: (context, state) {
      return PlaceholderPage(
        title: 'Halaman Tidak Ditemukan',
        routeName: 'notFound',
        routePath: state.uri.path,
        description:
            'Route yang anda tuju tidak terdaftar atau telah dipindahkan.',
      );
    },
    routes: [
      // 1. Onboarding
      GoRoute(
        path: AppRoutePaths.onboarding,
        name: AppRouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // 2. Auth Group
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const AuthPage(initialIsRegister: false),
      ),
      GoRoute(
        path: AppRoutePaths.register,
        name: AppRouteNames.register,
        builder: (context, state) => const AuthPage(initialIsRegister: true),
      ),
      GoRoute(
        path: AppRoutePaths.forgotPassword,
        name: AppRouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // 3. Profile Setup & Family Pairing
      GoRoute(
        path: AppRoutePaths.profileSetup,
        name: AppRouteNames.profileSetup,
        builder: (context, state) => const ProfileSetupPage(),
      ),
      GoRoute(
        path: AppRoutePaths.familyConnect,
        name: AppRouteNames.familyConnect,
        builder: (context, state) => const FamilyConnectPage(),
      ),
      GoRoute(
        path: AppRoutePaths.familyInvitation,
        name: AppRouteNames.familyInvitation,
        builder: (context, state) => const FamilyInvitationPage(),
      ),
      GoRoute(
        path: AppRoutePaths.familySuccess,
        name: AppRouteNames.familySuccess,
        builder: (context, state) => const FamilySuccessPage(),
      ),
      GoRoute(
        path: AppRoutePaths.weeklyCheckIn,
        name: AppRouteNames.weeklyCheckIn,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WeeklyCheckInPage(),
      ),
      GoRoute(
        path: AppRoutePaths.familyCondition,
        name: AppRouteNames.familyCondition,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FamilyConditionPage(),
      ),

      // 4. Debug Routes
      GoRoute(
        path: AppRoutePaths.debugRoutes,
        name: AppRouteNames.debugRoutes,
        builder: (context, state) => const RouteCatalogPage(),
      ),
      GoRoute(
        path: AppRoutePaths.debugGallery,
        name: AppRouteNames.debugGallery,
        builder: (context, state) => const ComponentGalleryPage(),
      ),

      // 5. Stateful Shell Route (4 Main Tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.home,
                name: AppRouteNames.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Tab 2: Finance
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.finance,
                name: AppRouteNames.finance,
                builder: (context, state) => const FinanceDashboardPage(),
                routes: [
                  GoRoute(
                    path: 'transactions',
                    name: AppRouteNames.transactions,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const TransactionListPage(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: AppRouteNames.transactionNew,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) =>
                            const TransactionFormPage(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.transactionDetail,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => TransactionDetailPage(
                          transactionId: state.pathParameters['id'] ?? '',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'statements/upload',
                    name: AppRouteNames.statementUpload,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Upload E-Statement',
                      routeName: AppRouteNames.statementUpload,
                      routePath: AppRoutePaths.statementUpload,
                    ),
                  ),
                  GoRoute(
                    path: 'statements/:id/review',
                    name: AppRouteNames.statementReview,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => StatementReviewPage(
                      importId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'goals',
                    name: AppRouteNames.goals,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const GoalListPage(),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: AppRouteNames.goalNew,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const GoalFormPage(),
                      ),
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.goalDetail,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => GoalDetailPage(
                          goalId: state.pathParameters['id']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            name: AppRouteNames.goalEdit,
                            parentNavigatorKey: rootNavigatorKey,
                            builder: (context, state) => GoalFormPage(
                              goalId: state.pathParameters['id'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 3: Mediation
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.mediation,
                name: AppRouteNames.mediation,
                builder: (context, state) => const MediationHubPage(),
                routes: [
                  GoRoute(
                    path: 'chat',
                    name: AppRouteNames.chatSessions,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ChatDetailPage(
                      sessionId: 'session-demo-001',
                    ),
                    routes: [
                      GoRoute(
                        path: ':sessionId',
                        name: AppRouteNames.chatDetail,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => ChatDetailPage(
                          sessionId: state.pathParameters['sessionId'] ??
                              'session-demo-001',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'recovery',
                    name: AppRouteNames.recoverySessions,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const RecoveryListPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.recoveryDetail,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => RecoveryDetailPage(
                          sessionId:
                              state.pathParameters['id'] ?? 'rec-demo-001',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'professionals',
                    name: AppRouteNames.professionals,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ProfessionalsPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.professionalDetail,
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) => const ProfessionalsPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'consultations',
                    name: AppRouteNames.consultations,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const ProfessionalsPage(),
                  ),
                  GoRoute(
                    path: 'simulations/new',
                    name: AppRouteNames.simulationNew,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SimulationResultPage(),
                  ),
                  GoRoute(
                    path: 'simulations/:id',
                    name: AppRouteNames.simulationDetail,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const SimulationResultPage(),
                  ),
                ],
              ),
            ],
          ),

          // Tab 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.profile,
                name: AppRouteNames.profile,
                builder: (context, state) => const PlaceholderPage(
                  title: 'Profil & Pengaturan',
                  routeName: AppRouteNames.profile,
                  routePath: AppRoutePaths.profile,
                  description: 'Kelola akun, koneksi keluarga, & privasi.',
                  targetSubRoutes: [
                    AppRoutePaths.settings,
                    AppRoutePaths.privacy,
                    AppRoutePaths.familySettings,
                    AppRoutePaths.debugRoutes,
                  ],
                ),
                routes: [
                  GoRoute(
                    path: 'settings',
                    name: AppRouteNames.settings,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Pengaturan Aplikasi',
                      routeName: AppRouteNames.settings,
                      routePath: AppRoutePaths.settings,
                    ),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: AppRouteNames.privacy,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Kebijakan Privasi & Data',
                      routeName: AppRouteNames.privacy,
                      routePath: AppRoutePaths.privacy,
                    ),
                  ),
                  GoRoute(
                    path: 'family-settings',
                    name: AppRouteNames.familySettings,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Pengaturan Ruang Keluarga',
                      routeName: AppRouteNames.familySettings,
                      routePath: AppRoutePaths.familySettings,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
