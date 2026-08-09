import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/app.dart';
import 'package:app/app/router/route_redirect.dart';

void main() {
  testWidgets('FaveraApp boots with router and renders Onboarding by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FaveraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Satu Ruang untuk Uang dan Perasaan'), findsOneWidget);
  });

  testWidgets('FaveraApp renders Home Dashboard when fully authenticated',
      (WidgetTester tester) async {
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

    expect(find.text('Home Dashboard'), findsWidgets);
  });
}
