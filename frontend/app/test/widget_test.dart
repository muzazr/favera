import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/app/app.dart';

void main() {
  testWidgets('FaveraApp boots and renders app title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FaveraApp(),
      ),
    );

    expect(find.text('Favera'), findsOneWidget);
    expect(
      find.text('Satu ruang untuk uang dan perasaan keluarga.'),
      findsOneWidget,
    );
  });
}
