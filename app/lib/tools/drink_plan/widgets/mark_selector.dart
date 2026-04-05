import 'package:flutter/material.dart';
import '../models/drink_plan_models.dart';

class MarkSelector extends StatelessWidget {
  final MarkType selectedMark;
  final Function(MarkType) onMarkSelected;

  const MarkSelector({
    super.key,
    required this.selectedMark,
    required this.onMarkSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: MarkType.values.map((mark) {
          final isSelected = mark == selectedMark;
          return GestureDetector(
            onTap: () => onMarkSelected(mark),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? _getMarkColor(mark).withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? _getMarkColor(mark)
                      : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mark.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mark.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? _getMarkColor(mark)
                          : Colors.grey,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getMarkColor(MarkType mark) {
    switch (mark) {
      case MarkType.none:
        return Colors.grey;
      case MarkType.noDrink:
        return Colors.green;
      case MarkType.light:
        return Colors.yellow.shade700;
      case MarkType.medium:
        return Colors.orange;
      case MarkType.heavy:
        return Colors.red;
    }
  }
}
