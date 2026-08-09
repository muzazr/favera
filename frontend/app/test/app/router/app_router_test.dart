import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/app.dart';
import 'package:app/app/router/route_redirect.dart';
import 'package:app/core/widgets/app_bottom_nav_bar.dart';

void main() {
  group('AppRouter Widget & Shell Tests', () {
    testWidgets(
        'FaveraApp boots with router and shows Home Dashboard when setup',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeStateProvider.overrideWith(
              (ref) => RouteStateNotifier(
                const RouteState(
                  onboardingCompleted: true,
                  isAuthenticated: true,
                  profileCompleted: true,
                  familyPaired: true,
                ),
              ),
            ),
          ],
          child: const FaveraApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Halo,'), findsWidgets);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('navigates to Keuangan tab when icon is tapped',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeStateProvider.overrideWith(
              (ref) => RouteStateNotifier(
                const RouteState(
                  onboardingCompleted: true,
                  isAuthenticated: true,
                  profileCompleted: true,
                  familyPaired: true,
                ),
              ),
            ),
          ],
          child: const FaveraApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppBottomNavBar),
          matching: find.byIcon(Icons.account_balance_wallet_outlined),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Finance Dashboard'), findsWidgets);
    });
  });
}
