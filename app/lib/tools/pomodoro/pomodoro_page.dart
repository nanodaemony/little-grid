import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui/app_colors.dart';
import 'models/pomodoro_state.dart';
import 'services/pomodoro_service.dart';
import 'widgets/timer_display.dart';
import 'widgets/stats_summary_card.dart';
import 'pages/settings_page.dart';
import 'pages/stats_page.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroService>(
      builder: (context, service, child) {
        final state = service.state;
        final settings = service.settings;

        return Scaffold(
          appBar: AppBar(
            title: const Text('番茄钟'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PomodoroSettingsPage(
                        initialSettings: settings,
                        onSaved: (s) => service.saveSettings(s),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      TimerDisplay(state: state, settings: settings),
                      const SizedBox(height: 48),
                      _buildControlButtons(context, service),
                    ],
                  ),
                ),
              ),
              StatsSummaryCard(todayCount: state.completedCount),
              _buildStatsEntry(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(BuildContext context, PomodoroService service) {
    final state = service.state;

    if (state.status == PomodoroStatus.waiting) {
      return ElevatedButton(
        onPressed: service.proceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(state.isBreak ? '开始下一个番茄' : '开始休息'),
      );
    }

    if (state.status == PomodoroStatus.idle) {
      return ElevatedButton(
        onPressed: service.startWork,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text('开始'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.breakRunning)
          ElevatedButton(
            onPressed: service.pause,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.divider),
              ),
            ),
            child: const Text('暂停'),
          ),
        if (state.status == PomodoroStatus.paused)
          ElevatedButton(
            onPressed: service.resume,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('继续'),
          ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: service.reset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.divider),
            ),
          ),
          child: const Text('重置'),
        ),
      ],
    );
  }

  Widget _buildStatsEntry(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PomodoroStatsPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              '查看统计记录',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}