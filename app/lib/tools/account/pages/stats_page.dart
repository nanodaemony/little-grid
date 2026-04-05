import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/ui/app_colors.dart';
import '../models/record.dart';
import '../models/category.dart';
import '../models/stats_models.dart';
import '../services/account_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime _currentMonth = DateTime.now();
  MonthlySummary _summary = MonthlySummary(income: 0, expense: 0);
  List<CategoryStats> _expenseStats = [];
  List<CategoryStats> _incomeStats = [];
  List<TrendData> _trendData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final monthStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';

    final summary = await AccountService.getMonthlySummary(monthStr);
    final expenseStats = await AccountService.getCategoryStats(monthStr, RecordType.expense);
    final incomeStats = await AccountService.getCategoryStats(monthStr, RecordType.income);
    final trendData = await AccountService.getTrendData(6);

    setState(() {
      _summary = summary;
      _expenseStats = expenseStats;
      _incomeStats = incomeStats;
      _trendData = trendData;
      _isLoading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    if (_currentMonth.year == DateTime.now().year &&
        _currentMonth.month == DateTime.now().month) {
      return;
    }
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  if (_expenseStats.isNotEmpty) ...[
                    _buildSectionTitle('支出分类'),
                    const SizedBox(height: 12),
                    _buildPieChart(_expenseStats, AppColors.error),
                    const SizedBox(height: 8),
                    _buildLegend(_expenseStats),
                    const SizedBox(height: 24),
                  ],
                  if (_incomeStats.isNotEmpty) ...[
                    _buildSectionTitle('收入分类'),
                    const SizedBox(height: 12),
                    _buildPieChart(_incomeStats, AppColors.success),
                    const SizedBox(height: 8),
                    _buildLegend(_incomeStats),
                    const SizedBox(height: 24),
                  ],
                  if (_trendData.isNotEmpty) ...[
                    _buildSectionTitle('近6个月趋势'),
                    const SizedBox(height: 12),
                    _buildTrendChart(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        Text(
          '${_currentMonth.year}年${_currentMonth.month}月',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('收入', _summary.income, AppColors.success),
          _buildSummaryItem('支出', _summary.expense, AppColors.error),
          _buildSummaryItem('结余', _summary.balance, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPieChart(List<CategoryStats> stats, Color baseColor) {
    final total = stats.fold<double>(0, (sum, s) => sum + s.amount);
    if (total == 0) return const SizedBox();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: stats.map((s) {
            final percentage = (s.amount / total * 100).toStringAsFixed(1);
            return PieChartSectionData(
              value: s.amount,
              title: '$percentage%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              color: _getCategoryColor(stats.indexOf(s)),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildLegend(List<CategoryStats> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCategoryColor(index),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text('${stat.category.icon} ${stat.category.name}'),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTrendChart() {
    final maxAmount = _trendData
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '¥${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _trendData.length) {
                    final month = _trendData[value.toInt()].month;
                    return Text(
                      month.substring(5),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxAmount * 1.2,
          lineBarsData: [
            // Income line
            LineChartBarData(
              spots: _trendData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.income);
              }).toList(),
              isCurved: true,
              color: AppColors.success,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
            // Expense line
            LineChartBarData(
              spots: _trendData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.expense);
              }).toList(),
              isCurved: true,
              color: AppColors.error,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.error,
      AppColors.success,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}
