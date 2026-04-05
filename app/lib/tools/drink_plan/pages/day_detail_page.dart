// lib/tools/drink_plan/pages/day_detail_page.dart

import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import '../../../core/ui/app_colors.dart';
import '../models/drink_plan_models.dart';
import '../models/drink_record.dart';
import '../services/drink_plan_service.dart';
import '../widgets/mark_selector.dart';

/// 日期详情页面 - 显示日期详情、月统计和标记选择
class DayDetailPage extends StatefulWidget {
  final DateTime date;

  const DayDetailPage({
    super.key,
    required this.date,
  });

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  DrinkRecord? _record;
  bool _isLoading = true;
  int _monthlyTotal = 0;
  int _monthlyMarked = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = _formatDate(widget.date);
      final record = await DrinkPlanService.getRecordByDate(dateStr);

      // 加载月度统计
      final records = await DrinkPlanService.getRecordsByMonth(widget.date.year, widget.date.month);

      setState(() {
        _record = record;
        _monthlyTotal = records.length;
        _monthlyMarked = records.where((r) => r.mark.isNotEmpty).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[weekday - 1];
  }

  String _getLunarDate(DateTime date) {
    final lunar = Lunar.fromDate(date);
    final lunarMonth = lunar.getMonthInChinese();
    final lunarDay = lunar.getDayInChinese();
    final solarTerm = lunar.getJieQi();

    if (solarTerm != null && solarTerm.isNotEmpty) {
      return solarTerm;
    }
    return '$lunarMonth$lunarDay';
  }

  MarkType _getCurrentMarkType() {
    if (_record == null || _record!.mark.isEmpty) {
      return MarkType.none;
    }
    switch (_record!.mark) {
      case 'noDrink':
        return MarkType.noDrink;
      case 'light':
        return MarkType.light;
      case 'medium':
        return MarkType.medium;
      case 'heavy':
        return MarkType.heavy;
      default:
        return MarkType.none;
    }
  }

  Future<void> _saveMark(MarkType markType) async {
    if (markType == MarkType.none) {
      await _deleteRecord();
      return;
    }

    final dateStr = _formatDate(widget.date);
    final record = DrinkRecord(
      date: dateStr,
      mark: markType.name,
      createdAt: _record?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await DrinkPlanService.addRecord(record);
    await _loadData();
  }

  Future<void> _deleteRecord() async {
    final dateStr = _formatDate(widget.date);
    await DrinkPlanService.deleteRecord(dateStr);
    await _loadData();
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定要删除这一天的记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecord();
            },
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日期详情'),
        actions: [
          if (_record != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期信息卡片
                  _buildDateCard(),
                  const SizedBox(height: 24),

                  // 月度统计
                  _buildMonthlyStats(),
                  const SizedBox(height: 24),

                  // 标记选择器
                  _buildMarkSelector(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${widget.date.year}年${widget.date.month}月${widget.date.day}日',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getWeekdayName(widget.date.weekday),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '农历 ${_getLunarDate(widget.date)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final progress = _monthlyTotal > 0 ? _monthlyMarked / _monthlyTotal : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本月统计',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('已记录', '$_monthlyMarked', AppColors.success),
              _buildStatItem('总天数', '$_monthlyTotal', AppColors.textSecondary),
              _buildStatItem('完成率', '${(progress * 100).toInt()}%', AppColors.primary),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          MarkSelector(
            selectedMark: _getCurrentMarkType(),
            onMarkSelected: _saveMark,
          ),
        ],
      ),
    );
  }
}
