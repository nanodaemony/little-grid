import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

class GridCell extends StatelessWidget {
  final bool isPassed;
  final bool isCurrent;
  final double size;

  const GridCell({
    super.key,
    required this.isPassed,
    required this.isCurrent,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isPassed ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isCurrent
              ? Colors.amber
              : Colors.grey.shade300,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
