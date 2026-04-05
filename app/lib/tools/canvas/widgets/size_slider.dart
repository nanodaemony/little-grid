import 'package:flutter/material.dart';

class SizeSlider extends StatelessWidget {
  final double value;
  final void Function(double) onChanged;

  const SizeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('粗细'),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Slider(
            value: value,
            min: 1,
            max: 20,
            onChanged: onChanged,
          ),
        ),
        Text(value.toStringAsFixed(1)),
      ],
    );
  }
}