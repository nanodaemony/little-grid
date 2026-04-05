import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/pages/grid_page.dart';
import 'package:littlegrid/providers/app_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('GridPage', () {
    testWidgets('opens drawer when menu button is tapped', (tester) async {
      // Create and initialize provider before building widget
      final appProvider = AppProvider();
      await appProvider.initTools();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: appProvider),
          ],
          child: const MaterialApp(
            home: GridPage(),
          ),
        ),
      );

      // Wait for init
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is open (contains drawer content)
      expect(find.text('用户'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });
  });
}
