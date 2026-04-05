import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';

class ModeSwitcher extends StatelessWidget {
  final DanmakuMode mode;
  final Function(DanmakuMode) onModeChanged;

  const ModeSwitcher({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DanmakuMode>(
      segments: const [
        ButtonSegment(
          value: DanmakuMode.scroll,
          label: Text('滚动'),
          icon: Icon(Icons.arrow_back),
        ),
        ButtonSegment(
          value: DanmakuMode.static,
          label: Text('常驻'),
          icon: Icon(Icons.pause),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (newSelection) {
        if (newSelection.isNotEmpty) {
          onModeChanged(newSelection.first);
        }
      },
    );
  }
}
