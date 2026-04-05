import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../services/life_grid_service.dart';
import '../widgets/grid_display.dart';

class WeekMonthPage extends StatefulWidget {
  const WeekMonthPage({super.key});

  @override
  State<WeekMonthPage> createState() => _WeekMonthPageState();
}

class _WeekMonthPageState extends State<WeekMonthPage> {
  bool _isWeekView = true;
  final _service = LifeGridService();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Column(
      children: [
        // View switcher
        Padding(
          padding: const EdgeInsets.all(16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('本周'),
              ),
              ButtonSegment(
                value: false,
                label: Text('本月'),
              ),
            ],
            selected: {_isWeekView},
            onSelectionChanged: (selected) {
              setState(() {
                _isWeekView = selected.first;
              });
            },
          ),
        ),

        // Progress info
        _buildProgressInfo(now),

        // Grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _isWeekView
                ? _buildWeekGrid(now)
                : _buildMonthGrid(now),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(DateTime now) {
    final progress = _isWeekView
        ? _service.getWeekProgress(now)
        : _service.getMonthProgress(now);

    final percentage = (progress['percentage'] as double) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _isWeekView
                ? '${now.year}年 第${_getWeekNumber(now)}周'
                : '${now.year}年${now.month}月',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '已过 ${progress['currentDay']}/${progress['totalDays']} 天',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekGrid(DateTime now) {
    final progress = _service.getWeekProgress(now);
    final passedCount = progress['currentDay'] as int;
    final currentIndex = passedCount - 1;

    return Column(
      children: [
        // Day labels
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: ['一', '二', '三', '四', '五', '六', '日']
              .map((day) => Container(
                    width: 44,
                    alignment: Alignment.center,
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Grid
        GridDisplay(
          totalCount: 7,
          passedCount: passedCount,
          currentIndex: currentIndex,
          crossAxisCount: 7,
          cellSize: 40,
          spacing: 4,
        ),
      ],
    );
  }

  Widget _buildMonthGrid(DateTime now) {
    final progress = _service.getMonthProgress(now);
    final totalDays = progress['totalDays'] as int;
    final passedCount = progress['currentDay'] as int;
    final currentIndex = passedCount - 1;

    return GridDisplay(
      totalCount: totalDays,
      passedCount: passedCount,
      currentIndex: currentIndex,
      crossAxisCount: 7,
      cellSize: 40,
      spacing: 4,
    );
  }

  int _getWeekNumber(DateTime now) {
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final daysSinceFirstDay = now.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }
}
