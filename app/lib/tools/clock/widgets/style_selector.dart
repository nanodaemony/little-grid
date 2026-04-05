import 'package:flutter/material.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';
import 'digital_clock.dart';
import 'analog_clock.dart';

class StyleSelector extends StatelessWidget {
  final ClockConfig config;
  final ValueChanged<ClockConfig> onConfigChanged;
  final DateTime previewTime;

  const StyleSelector({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.previewTime,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView(
        controller: PageController(initialPage: config.type == ClockType.digital ? 0 : 1),
        onPageChanged: (index) {
          onConfigChanged(config.copyWith(
            type: index == 0 ? ClockType.digital : ClockType.analog,
          ));
        },
        children: [
          _buildPreviewCard(
            title: '数字时钟',
            child: DigitalClock(
              time: previewTime,
              config: config.copyWith(showDate: false),
            ),
          ),
          _buildPreviewCard(
            title: '圆盘时钟',
            child: AnalogClock(
              time: previewTime,
              config: config.copyWith(showDate: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Expanded(child: Center(child: child)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: config.effectiveTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
