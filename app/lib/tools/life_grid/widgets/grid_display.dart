import 'package:flutter/material.dart';
import 'grid_cell.dart';

class GridDisplay extends StatelessWidget {
  final int totalCount;
  final int passedCount;
  final int? currentIndex;
  final int crossAxisCount;
  final double cellSize;
  final double spacing;

  const GridDisplay({
    super.key,
    required this.totalCount,
    required this.passedCount,
    this.currentIndex,
    required this.crossAxisCount,
    required this.cellSize,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final isPassed = index < passedCount;
        final isCurrent = currentIndex != null && index == currentIndex;

        return GridCell(
          isPassed: isPassed,
          isCurrent: isCurrent,
          size: cellSize,
        );
      },
    );
  }
}
