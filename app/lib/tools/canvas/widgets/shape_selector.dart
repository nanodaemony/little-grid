import 'package:flutter/material.dart';
import '../models/shape.dart';

class ShapeSelector extends StatelessWidget {
  final ShapeType selectedType;
  final bool filled;
  final void Function(ShapeType) onTypeSelected;
  final void Function(bool) onFilledChanged;

  const ShapeSelector({
    super.key,
    required this.selectedType,
    required this.filled,
    required this.onTypeSelected,
    required this.onFilledChanged,
  });

  static const _types = [
    (ShapeType.line, '直线', Icons.show_chart),
    (ShapeType.rectangle, '矩形', Icons.rectangle_outlined),
    (ShapeType.circle, '圆形', Icons.circle_outlined),
    (ShapeType.triangle, '三角', Icons.change_history),
    (ShapeType.arrow, '箭头', Icons.arrow_forward),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._types.map((item) {
          final (type, _, icon) = item;
          final isSelected = type == selectedType;
          return IconButton(
            icon: Icon(icon),
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            onPressed: () => onTypeSelected(type),
          );
        }),
        const SizedBox(width: 8),
        Row(
          children: [
            Checkbox(
              value: filled,
              onChanged: (v) => onFilledChanged(v ?? false),
            ),
            const Text('填充'),
          ],
        ),
      ],
    );
  }
}