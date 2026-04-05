import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/drink_plan/drink_plan_tool.dart';
import 'package:app/core/services/tool_registry.dart';

void main() {
  group('DrinkPlan Integration', () {
    testWidgets('should display tool page', (WidgetTester tester) async {
      final tool = DrinkPlanTool();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => tool.buildPage(context),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('奶茶计划'), findsOneWidget);
    });

    test('should have correct tool metadata', () {
      final tool = DrinkPlanTool();

      expect(tool.id, 'drink_plan');
      expect(tool.name, '奶茶计划');
      expect(tool.category, ToolCategory.life);
      expect(tool.gridSize, 2);
    });
  });
}
