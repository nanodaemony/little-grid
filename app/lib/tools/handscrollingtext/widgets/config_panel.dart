import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';
import 'color_picker_button.dart';
import 'mode_switcher.dart';

class ConfigPanel extends StatelessWidget {
  final DanmakuConfig config;
  final Function(DanmakuConfig) onConfigChanged;

  const ConfigPanel({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModeSwitcher(
          mode: config.mode,
          onModeChanged: (mode) => onConfigChanged(config.copyWith(mode: mode)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: config.fontFamily,
          decoration: const InputDecoration(
            labelText: '字体',
            border: OutlineInputBorder(),
          ),
          items: fontOptions.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onConfigChanged(config.copyWith(fontFamily: value));
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ColorPickerButton(
              color: config.textColor,
              label: '文字颜色',
              onColorChanged: (color) => onConfigChanged(config.copyWith(textColor: color)),
            ),
            const SizedBox(width: 16),
            ColorPickerButton(
              color: config.backgroundColor,
              label: '背景颜色',
              onColorChanged: (color) => onConfigChanged(config.copyWith(backgroundColor: color)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('字体大小'),
            Expanded(
              child: Slider(
                value: config.fontSize,
                min: 50,
                max: 300,
                divisions: 25,
                label: config.fontSize.toInt().toString(),
                onChanged: (value) => onConfigChanged(config.copyWith(fontSize: value)),
              ),
            ),
            Text('${config.fontSize.toInt()}'),
          ],
        ),
        if (config.mode == DanmakuMode.scroll)
          Row(
            children: [
              const Text('滚动速度'),
              Expanded(
                child: Slider(
                  value: config.speed,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: config.speed.toInt().toString(),
                  onChanged: (value) => onConfigChanged(config.copyWith(speed: value)),
                ),
              ),
              Text('${config.speed.toInt()}'),
            ],
          ),
      ],
    );
  }
}
