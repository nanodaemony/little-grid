import 'package:flutter/material.dart';
import '../models/stroke.dart';

class BrushSelector extends StatelessWidget {
  final BrushType selectedType;
  final void Function(BrushType) onTypeSelected;

  const BrushSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const _types = [
    (BrushType.normal, '普通', Icons.edit),
    (BrushType.marker, '马克', Icons.brush),
    (BrushType.highlighter, '荧光', Icons.highlight),
    (BrushType.pressure, '压感', Icons.gesture),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _types.map((item) {
        final (type, label, icon) = item;
        final isSelected = type == selectedType;
        return GestureDetector(
          onTap: () => onTypeSelected(type),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                Text(label, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}