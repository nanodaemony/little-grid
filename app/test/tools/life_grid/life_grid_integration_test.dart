import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/life_grid/life_grid_main_page.dart';
import 'package:littlegrid/tools/life_grid/life_grid_tool.dart';
import 'package:littlegrid/core/services/tool_registry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ToolRegistry.register(LifeGridTool());
  });

  tearDown(() async {
    await ToolRegistry.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  });

  group('LifeGrid Integration', () {
    testWidgets('should display main page with tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LifeGridMainPage(),
        ),
      );

      // Wait for settings to load
      await tester.pumpAndSettle();

      // Should show title
      expect(find.text('人生进度'), findsOneWidget);

      // Should show settings button
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Should show tabs
      expect(find.text('周/月'), findsOneWidget);
      expect(find.text('年'), findsOneWidget);
      expect(find.text('人生'), findsOneWidget);
      expect(find.text('自定义'), findsOneWidget);

      // Should show encouragement text
      expect(find.text('一寸光阴一寸金'), findsOneWidget);
    });

    testWidgets('should open settings dialog', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LifeGridMainPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should show settings dialog
      expect(find.text('设置'), findsOneWidget);
      expect(find.text('周/月视图'), findsOneWidget);
      expect(find.text('年视图'), findsOneWidget);
    });
  });
}
