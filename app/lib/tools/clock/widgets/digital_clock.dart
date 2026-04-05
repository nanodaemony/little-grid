import 'package:flutter/material.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';

class DigitalClock extends StatelessWidget {
  final DateTime time;
  final ClockConfig config;

  const DigitalClock({
    super.key,
    required this.time,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = config.effectiveTextColor;
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final baseFontSize = (isPortrait ? 80.0 : 120.0) * config.fontSize.scale;

    String timeText;
    if (config.use24HourFormat) {
      timeText = '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}${_showSeconds()}';
    } else {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      timeText = '${_twoDigits(hour)}:${_twoDigits(time.minute)}${_showSeconds()} $period';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeText,
          style: TextStyle(
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'monospace',
            letterSpacing: 8,
          ),
        ),
        if (config.showDate) ...[
          const SizedBox(height: 16),
          Text(
            '${time.year}年${_twoDigits(time.month)}月${_twoDigits(time.day)}日 星期${_weekdayName(time.weekday)}',
            style: TextStyle(
              fontSize: baseFontSize * 0.25,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  String _showSeconds() {
    return config.showSeconds ? ':${_twoDigits(time.second)}' : '';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _weekdayName(int weekday) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return names[weekday - 1];
  }
}
