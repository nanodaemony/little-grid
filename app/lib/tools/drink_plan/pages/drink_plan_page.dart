// lib/tools/drink_plan/pages/drink_plan_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../widgets/health_tip_banner.dart';
import '../widgets/month_view.dart';
import '../widgets/year_view.dart';
import 'day_detail_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';

/// 饮酒计划主页面
class DrinkPlanPage extends StatefulWidget {
  const DrinkPlanPage({super.key});

  @override
  State<DrinkPlanPage> createState() => _DrinkPlanPageState();
}

class _DrinkPlanPageState extends State<DrinkPlanPage> {
  // 视图类型：月份视图或年视图
  bool _isMonthView = true;

  // 当前显示的月份/年份
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;

  // PageView控制器，用于月份滑动
  late PageController _pageController;
  static const int _initialPage = 1200; // 足够大的中间值，支持前后100年

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 获取PageView索引对应的月份
  DateTime _getMonthFromPageIndex(int index) {
    final now = DateTime.now();
    final monthOffset = index - _initialPage;
    return DateTime(now.year, now.month + monthOffset, 1);
  }

  /// 页面切换回调
  void _onPageChanged(int page) {
    final newMonth = _getMonthFromPageIndex(page);
    setState(() {
      _currentDate = newMonth;
    });
  }

  /// 切换到上一个月份
  void _previousMonth() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 切换到下一个月份
  void _nextMonth() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 选择日期
  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _navigateToDayDetail(date);
  }

  /// 长按日期
  void _onDateLongPress(DateTime date) {
    _navigateToDayDetail(date);
  }

  /// 导航到日期详情页
  void _navigateToDayDetail(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayDetailPage(date: date),
      ),
    );
  }

  /// 导航到设置页
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DrinkPlanSettingsPage(),
      ),
    );
  }

  /// 导航到统计页面
  void _navigateToStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StatisticsPage(),
      ),
    );
  }

  /// 切换到指定年份的月份视图
  void _onMonthSelected(int year, int month) {
    final now = DateTime.now();
    final targetDate = DateTime(year, month, 1);
    final monthOffset = (year - now.year) * 12 + (month - now.month);
    final targetPage = _initialPage + monthOffset;

    setState(() {
      _isMonthView = true;
      _currentDate = targetDate;
    });

    _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// 构建月份头部（年月显示和切换按钮）
  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            '${_currentDate.year}年${_currentDate.month}月',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  /// 构建星期标题行
  Widget _buildWeekdayHeader() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
      ),
      child: Row(
        children: weekdays.map((day) {
          final isWeekend = day == '六' || day == '日';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isWeekend ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建月份视图（带PageView滑动）
  Widget _buildMonthCalendarView() {
    return Column(
      children: [
        // 月份切换头部
        _buildMonthHeader(),
        // 星期标题
        _buildWeekdayHeader(),
        // 日历网格（支持滑动）
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _initialPage * 2,
            itemBuilder: (context, index) {
              final month = _getMonthFromPageIndex(index);
              return MonthView(
                year: month.year,
                month: month.month,
                selectedDate: _selectedDate,
                onDateSelected: _selectDate,
                onDateLongPress: _onDateLongPress,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建年视图
  Widget _buildYearCalendarView() {
    return YearView(
      year: _currentDate.year,
      onMonthSelected: _onMonthSelected,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('饮酒计划'),
        actions: [
          // 统计按钮
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            onPressed: _navigateToStatistics,
            tooltip: '统计',
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _navigateToSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 健康提示横幅
          const HealthTipBanner(),

          // 视图切换按钮（月视图/年视图）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  label: Text('月视图'),
                  icon: Icon(Icons.calendar_view_month),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text('年视图'),
                  icon: Icon(Icons.calendar_view_week),
                ),
              ],
              selected: {_isMonthView},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isMonthView = newSelection.first;
                  if (_isMonthView) {
                    // 切换回月视图时，确保PageView显示当前月份
                    final now = DateTime.now();
                    final monthOffset = (_currentDate.year - now.year) * 12 +
                        (_currentDate.month - now.month);
                    final targetPage = _initialPage + monthOffset;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_pageController.hasClients) {
                        _pageController.jumpToPage(targetPage);
                      }
                    });
                  }
                });
              },
            ),
          ),

          // 日历视图区域
          Expanded(
            child: _isMonthView ? _buildMonthCalendarView() : _buildYearCalendarView(),
          ),
        ],
      ),
    );
  }
}
