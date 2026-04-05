import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/pomodoro_state.dart';
import '../models/pomodoro_settings.dart';
import 'progress_ring.dart';

class TimerDisplay extends StatelessWidget {
  final PomodoroState state;
  final PomodoroSettings settings;

  const TimerDisplay({
    super.key,
    required this.state,
    required this.settings,
  });

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _backgroundColor {
    if (state.isBreak) {
      return AppColors.success.withAlpha((0.2 * 255).round());
    }
    return const Color(0xFFFF8A80).withAlpha((0.3 * 255).round());
  }

  Color get _ringColor {
    if (state.isBreak) {
      return AppColors.success;
    }
    return const Color(0xFFFF8A80);
  }

  @override
  Widget build(BuildContext context) {
    switch (settings.displayStyle) {
      case DisplayStyle.timer:
        return _buildTimerStyle();
      case DisplayStyle.independent:
        return _buildIndependentStyle();
      case DisplayStyle.mixed:
        return _buildMixedStyle();
    }
  }

  // Timer style: ring progress + time inside
  Widget _buildTimerStyle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ProgressRing(
          progress: state.progress,
          size: 220,
          strokeWidth: 10,
          color: _ringColor,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(state.remainingSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (state.isBreak)
              Text(
                state.isLongBreak ? '长休息' : '短休息',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Independent style: circle + time beside it
  Widget _buildIndependentStyle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            state.isBreak ? Icons.coffee : Icons.circle,
            size: 48,
            color: _ringColor,
          ),
        ),
        const SizedBox(width: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(state.remainingSeconds),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              state.isBreak
                  ? (state.isLongBreak ? '长休息中' : '短休息中')
                  : '专注中',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Mixed style: circle with time inside + outer progress ring
  Widget _buildMixedStyle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ProgressRing(
          progress: state.progress,
          size: 220,
          strokeWidth: 6,
          color: _ringColor,
        ),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.isBreak ? Icons.coffee : Icons.circle,
                size: 32,
                color: _ringColor,
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(state.remainingSeconds),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (state.isBreak)
                Text(
                  state.isLongBreak ? '长休息' : '短休息',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}