import 'package:flutter/material.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';
import 'style_selector.dart';
import 'background_picker.dart';

class SettingsPanel extends StatelessWidget {
  final ClockConfig config;
  final ValueChanged<ClockConfig> onConfigChanged;
  final DateTime previewTime;
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.previewTime,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '时钟设置',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Settings content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Style selector
                    const Text('时钟样式', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    StyleSelector(
                      config: config,
                      onConfigChanged: onConfigChanged,
                      previewTime: previewTime,
                    ),
                    const SizedBox(height: 24),
                    // Theme
                    const Text('主题', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<ClockThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ClockThemeMode.light,
                          label: Text('浅色'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ClockThemeMode.dark,
                          label: Text('深色'),
                          icon: Icon(Icons.dark_mode),
                        ),
                        ButtonSegment(
                          value: ClockThemeMode.custom,
                          label: Text('自定义'),
                          icon: Icon(Icons.palette),
                        ),
                      ],
                      selected: {config.theme},
                      onSelectionChanged: (value) {
                        onConfigChanged(config.copyWith(theme: value.first));
                      },
                    ),
                    const SizedBox(height: 24),
                    // Time format
                    const Text('时间格式', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<TimeFormat>(
                      segments: const [
                        ButtonSegment(value: TimeFormat.auto, label: Text('自动')),
                        ButtonSegment(value: TimeFormat.format12, label: Text('12小时')),
                        ButtonSegment(value: TimeFormat.format24, label: Text('24小时')),
                      ],
                      selected: {config.timeFormat},
                      onSelectionChanged: (value) {
                        onConfigChanged(config.copyWith(timeFormat: value.first));
                      },
                    ),
                    const SizedBox(height: 24),
                    // Display options
                    const Text('显示选项', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('显示日期'),
                      value: config.showDate,
                      onChanged: (value) {
                        onConfigChanged(config.copyWith(showDate: value));
                      },
                    ),
                    SwitchListTile(
                      title: const Text('显示秒数'),
                      value: config.showSeconds,
                      onChanged: (value) {
                        onConfigChanged(config.copyWith(showSeconds: value));
                      },
                    ),
                    const SizedBox(height: 24),
                    // Font size
                    const Text('字体大小', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<FontSize>(
                      segments: const [
                        ButtonSegment(value: FontSize.small, label: Text('小')),
                        ButtonSegment(value: FontSize.medium, label: Text('中')),
                        ButtonSegment(value: FontSize.large, label: Text('大')),
                      ],
                      selected: {config.fontSize},
                      onSelectionChanged: (value) {
                        onConfigChanged(config.copyWith(fontSize: value.first));
                      },
                    ),
                    const SizedBox(height: 24),
                    // Background
                    BackgroundPicker(
                      config: config,
                      onConfigChanged: onConfigChanged,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
