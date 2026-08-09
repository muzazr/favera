import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/app.dart';

void main() {
  testWidgets('FaveraApp boots with router and renders Home Dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FaveraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home Dashboard'), findsWidgets);
  });
}
