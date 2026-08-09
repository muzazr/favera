import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/component_gallery_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/family/presentation/pages/family_connect_page.dart';
import '../../features/family/presentation/pages/family_invitation_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_setup_page.dart';
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
                builder: (context, state) => const PlaceholderPage(
                  title: 'Home Dashboard',
                  routeName: AppRouteNames.home,
                  routePath: AppRoutePaths.home,
                  description: 'Ringkasan keluarga, saldo, & aksi cepat.',
                ),
              ),
            ],
          ),

          // Tab 2: Finance
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutePaths.finance,
                name: AppRouteNames.finance,
                builder: (context, state) => const PlaceholderPage(
                  title: 'Finance Dashboard',
                  routeName: AppRouteNames.finance,
                  routePath: AppRoutePaths.finance,
                  description: 'Ringkasan keuangan, transaksi, & goals.',
                  targetSubRoutes: [
                    AppRoutePaths.transactions,
                    AppRoutePaths.transactionNew,
                    AppRoutePaths.statementUpload,
                    AppRoutePaths.goals,
                    AppRoutePaths.goalNew,
                  ],
                ),
                routes: [
                  GoRoute(
                    path: 'transactions',
                    name: AppRouteNames.transactions,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Riwayat Transaksi',
                      routeName: AppRouteNames.transactions,
                      routePath: AppRoutePaths.transactions,
                    ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: AppRouteNames.transactionNew,
                        builder: (context, state) => const PlaceholderPage(
                          title: 'Tambah Transaksi',
                          routeName: AppRouteNames.transactionNew,
                          routePath: AppRoutePaths.transactionNew,
                        ),
                      ),
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.transactionDetail,
                        builder: (context, state) => PlaceholderPage(
                          title: 'Detail Transaksi',
                          routeName: AppRouteNames.transactionDetail,
                          routePath:
                              '/app/finance/transactions/${state.pathParameters['id']}',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'statements/upload',
                    name: AppRouteNames.statementUpload,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Upload E-Statement',
                      routeName: AppRouteNames.statementUpload,
                      routePath: AppRoutePaths.statementUpload,
                    ),
                  ),
                  GoRoute(
                    path: 'statements/:id/review',
                    name: AppRouteNames.statementReview,
                    builder: (context, state) => PlaceholderPage(
                      title: 'Review E-Statement',
                      routeName: AppRouteNames.statementReview,
                      routePath:
                          '/app/finance/statements/${state.pathParameters['id']}/review',
                    ),
                  ),
                  GoRoute(
                    path: 'goals',
                    name: AppRouteNames.goals,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Target Keuangan Bersama',
                      routeName: AppRouteNames.goals,
                      routePath: AppRoutePaths.goals,
                    ),
                    routes: [
                      GoRoute(
                        path: 'new',
                        name: AppRouteNames.goalNew,
                        builder: (context, state) => const PlaceholderPage(
                          title: 'Buat Goal Baru',
                          routeName: AppRouteNames.goalNew,
                          routePath: AppRoutePaths.goalNew,
                        ),
                      ),
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.goalDetail,
                        builder: (context, state) => PlaceholderPage(
                          title: 'Detail Target Keuangan',
                          routeName: AppRouteNames.goalDetail,
                          routePath:
                              '/app/finance/goals/${state.pathParameters['id']}',
                        ),
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
                builder: (context, state) => const PlaceholderPage(
                  title: 'Mediasi & Pemulihan Hub',
                  routeName: AppRouteNames.mediation,
                  routePath: AppRoutePaths.mediation,
                  description: 'Akses Konselor AI, Profesional, & Simulasi.',
                  targetSubRoutes: [
                    AppRoutePaths.chatSessions,
                    AppRoutePaths.recoverySessions,
                    AppRoutePaths.professionals,
                    AppRoutePaths.consultations,
                    AppRoutePaths.simulationNew,
                  ],
                ),
                routes: [
                  GoRoute(
                    path: 'chat',
                    name: AppRouteNames.chatSessions,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Sesi Chat AI Empatik',
                      routeName: AppRouteNames.chatSessions,
                      routePath: AppRoutePaths.chatSessions,
                    ),
                    routes: [
                      GoRoute(
                        path: ':sessionId',
                        name: AppRouteNames.chatDetail,
                        builder: (context, state) => PlaceholderPage(
                          title: 'Detail Chat Sesi',
                          routeName: AppRouteNames.chatDetail,
                          routePath:
                              '/app/mediation/chat/${state.pathParameters['sessionId']}',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'recovery',
                    name: AppRouteNames.recoverySessions,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Ruang Pemulihan Bersama',
                      routeName: AppRouteNames.recoverySessions,
                      routePath: AppRoutePaths.recoverySessions,
                    ),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.recoveryDetail,
                        builder: (context, state) => PlaceholderPage(
                          title: 'Sesi Pemulihan',
                          routeName: AppRouteNames.recoveryDetail,
                          routePath:
                              '/app/mediation/recovery/${state.pathParameters['id']}',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'professionals',
                    name: AppRouteNames.professionals,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Direktori Tenaga Profesional',
                      routeName: AppRouteNames.professionals,
                      routePath: AppRoutePaths.professionals,
                    ),
                    routes: [
                      GoRoute(
                        path: ':id',
                        name: AppRouteNames.professionalDetail,
                        builder: (context, state) => PlaceholderPage(
                          title: 'Profil Konselor/Ahli',
                          routeName: AppRouteNames.professionalDetail,
                          routePath:
                              '/app/mediation/professionals/${state.pathParameters['id']}',
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'consultations',
                    name: AppRouteNames.consultations,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Jadwal Consultations',
                      routeName: AppRouteNames.consultations,
                      routePath: AppRoutePaths.consultations,
                    ),
                  ),
                  GoRoute(
                    path: 'simulations/new',
                    name: AppRouteNames.simulationNew,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Simulasi Dampak',
                      routeName: AppRouteNames.simulationNew,
                      routePath: AppRoutePaths.simulationNew,
                    ),
                  ),
                  GoRoute(
                    path: 'simulations/:id',
                    name: AppRouteNames.simulationDetail,
                    builder: (context, state) => PlaceholderPage(
                      title: 'Hasil Simulasi Dampak',
                      routeName: AppRouteNames.simulationDetail,
                      routePath:
                          '/app/mediation/simulations/${state.pathParameters['id']}',
                    ),
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
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Pengaturan Aplikasi',
                      routeName: AppRouteNames.settings,
                      routePath: AppRoutePaths.settings,
                    ),
                  ),
                  GoRoute(
                    path: 'privacy',
                    name: AppRouteNames.privacy,
                    builder: (context, state) => const PlaceholderPage(
                      title: 'Kebijakan Privasi & Data',
                      routeName: AppRouteNames.privacy,
                      routePath: AppRoutePaths.privacy,
                    ),
                  ),
                  GoRoute(
                    path: 'family-settings',
                    name: AppRouteNames.familySettings,
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
