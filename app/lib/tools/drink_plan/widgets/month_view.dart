// lib/tools/drink_plan/widgets/month_view.dart

import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import '../../../core/ui/app_colors.dart';
import '../services/drink_plan_service.dart';
import 'day_cell.dart';

/// 月份视图组件 - 显示7列月历网格
class MonthView extends StatefulWidget {
  final int year;
  final int month;
  final DateTime? selectedDate;
  final Function(DateTime date)? onDateSelected;
  final Function(DateTime date)? onDateLongPress;

  const MonthView({
    super.key,
    required this.year,
    required this.month,
    this.selectedDate,
    this.onDateSelected,
    this.onDateLongPress,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  Set<String> _markedDates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkedDates();
  }

  @override
  void didUpdateWidget(MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      _loadMarkedDates();
    }
  }

  Future<void> _loadMarkedDates() async {
    setState(() => _isLoading = true);
    try {
      final marked = await DrinkPlanService.getMarkedDates(widget.year, widget.month);
      setState(() {
        _markedDates = marked;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(int year, int month, int day) {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final firstDayOfMonth = DateTime(widget.year, widget.month, 1);
    final lastDayOfMonth = DateTime(widget.year, widget.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;

    // 计算第一天是周几（周一为1）
    int startWeekday = firstDayOfMonth.weekday;

    final days = <Widget>[];

    // 填充月初空白
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // 填充日期
    final today = DateTime.now();
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(widget.year, widget.month, day);
      final dateStr = _formatDate(widget.year, widget.month, day);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = widget.selectedDate != null &&
          date.year == widget.selectedDate!.year &&
          date.month == widget.selectedDate!.month &&
          date.day == widget.selectedDate!.day;
      final hasMark = _markedDates.contains(dateStr);

      days.add(
        GestureDetector(
          onTap: () => widget.onDateSelected?.call(date),
          onLongPress: () => widget.onDateLongPress?.call(date),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : null,
              border: isToday
                  ? Border.all(color: AppColors.primary, width: 2)
                  : isSelected
                      ? Border.all(color: AppColors.primary, width: 1)
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (hasMark)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // 填充月末空白，使网格完整
    final totalCells = days.length;
    final remainingCells = (7 - (totalCells % 7)) % 7;
    for (int i = 0; i < remainingCells; i++) {
      days.add(const SizedBox());
    }

    return GridView.count(
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: days,
    );
  }
}
