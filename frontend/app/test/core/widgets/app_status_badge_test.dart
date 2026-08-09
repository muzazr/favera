import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/widgets/app_status_badge.dart';

void main() {
  group('AppStatusBadge Tests', () {
    testWidgets('renders status label and icon correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppStatusBadge(
              label: 'Status Keluarga · Aman Terkendali',
              level: AppStatusLevel.stable,
            ),
          ),
        ),
      );

      expect(find.text('Status Keluarga · Aman Terkendali'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
