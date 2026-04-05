import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../services/life_grid_service.dart';
import '../widgets/grid_cell.dart';

class YearPage extends StatelessWidget {
  const YearPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final service = LifeGridService();
    final progress = service.getYearProgress(now);

    final currentDay = progress['currentDay'] as int;
    final totalDays = progress['totalDays'] as int;
    final percentage = (progress['percentage'] as double) * 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Progress info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${now.year}年',
                  style: const TextStyle(
                    fontSize: 20,
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
                      '已过 $currentDay/$totalDays 天',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Month grids
          ...List.generate(12, (monthIndex) {
            return _buildMonthSection(
              monthIndex + 1,
              currentDay,
              now.year,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthSection(int month, int currentDayOfYear, int year) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final startDayOfWeek = firstDayOfMonth.weekday - 1; // 0 = Monday

    // Calculate how many days have passed in this month
    final startOfYear = DateTime(year, 1, 1);
    final dayOfYearForMonthStart = firstDayOfMonth.difference(startOfYear).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month label
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$month月',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Weekday labels
          Row(
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 4),

          // Days grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: 42, // 6 weeks max
            itemBuilder: (context, index) {
              final dayIndex = index - startDayOfWeek;

              if (dayIndex < 0 || dayIndex >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final dayNumber = dayIndex + 1;
              final dayOfYear = dayOfYearForMonthStart + dayNumber;
              final isPassed = dayOfYear <= currentDayOfYear;
              final isCurrent = dayOfYear == currentDayOfYear;

              return GridCell(
                isPassed: isPassed,
                isCurrent: isCurrent,
                size: 20,
              );
            },
          ),
        ],
      ),
    );
  }
}
