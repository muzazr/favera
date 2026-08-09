import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/app.dart';

void main() {
  group('AppRouter Widget & Shell Tests', () {
    testWidgets('FaveraApp boots with router and shows Home Dashboard',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: FaveraApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Dashboard'), findsWidgets);
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('navigates to Keuangan tab when icon is tapped',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: FaveraApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Finance Dashboard'), findsWidgets);
    });
  });
}
