import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/core/ui/app_colors.dart';
import 'package:littlegrid/tools/life_grid/widgets/grid_cell.dart';
import 'package:littlegrid/tools/life_grid/widgets/grid_display.dart';

void main() {
  group('GridCell', () {
    testWidgets('should display passed cell in blue', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GridCell(
              isPassed: true,
              isCurrent: false,
              size: 20,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary);
    });

    testWidgets('should display current cell with highlight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GridCell(
              isPassed: true,
              isCurrent: true,
              size: 20,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('should display future cell in white', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GridCell(
              isPassed: false,
              isCurrent: false,
              size: 20,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.white);
    });
  });

  group('GridDisplay', () {
    testWidgets('should display correct number of cells', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridDisplay(
              totalCount: 7,
              passedCount: 3,
              currentIndex: 3,
              crossAxisCount: 7,
              cellSize: 20,
            ),
          ),
        ),
      );

      expect(find.byType(GridCell), findsNWidgets(7));
    });
  });
}
