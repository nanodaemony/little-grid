import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

enum KeyType {
  number,
  operator,
  function,
  equals,
  clear,
}

class CalculatorKey extends StatelessWidget {
  final String label;
  final KeyType type;
  final VoidCallback onTap;
  final int flex;

  const CalculatorKey({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case KeyType.number:
        return AppColors.surface;
      case KeyType.operator:
        return AppColors.primary.withOpacity(0.1);
      case KeyType.function:
        return AppColors.categoryCalc.withOpacity(0.15);
      case KeyType.equals:
        return AppColors.primary;
      case KeyType.clear:
        return Colors.orange.withOpacity(0.2);
    }
  }

  Color _getTextColor() {
    if (type == KeyType.equals) {
      return Colors.white;
    }
    return AppColors.textPrimary;
  }
}
