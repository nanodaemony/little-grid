// lib/tools/drink_plan/widgets/year_view.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../services/drink_plan_service.dart';

/// 年视图组件 - 显示12个月的3x4网格
class YearView extends StatefulWidget {
  final int year;
  final Function(int year, int month)? onMonthSelected;

  const YearView({
    super.key,
    required this.year,
    this.onMonthSelected,
  });

  @override
  State<YearView> createState() => _YearViewState();
}

class _YearViewState extends State<YearView> {
  Map<int, int> _monthlyMarkedCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadYearData();
  }

  @override
  void didUpdateWidget(YearView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year) {
      _loadYearData();
    }
  }

  Future<void> _loadYearData() async {
    setState(() => _isLoading = true);
    try {
      final counts = <int, int>{};
      for (int month = 1; month <= 12; month++) {
        final marked = await DrinkPlanService.getMarkedDates(widget.year, month);
        counts[month] = marked.length;
      }
      setState(() {
        _monthlyMarkedCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getMonthName(int month) {
    return '$month月';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final markedCount = _monthlyMarkedCounts[month] ?? 0;
        final now = DateTime.now();
        final isCurrentMonth = widget.year == now.year && month == now.month;

        return GestureDetector(
          onTap: () => widget.onMonthSelected?.call(widget.year, month),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: isCurrentMonth
                  ? Border.all(color: AppColors.primary, width: 2)
                  : Border.all(color: AppColors.divider, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getMonthName(month),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.w500,
                    color: isCurrentMonth ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (markedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$markedCount 天',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    '无记录',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
