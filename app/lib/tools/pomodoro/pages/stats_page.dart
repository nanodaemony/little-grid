import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/ui/app_colors.dart';
import '../models/pomodoro_record.dart';
import '../services/pomodoro_stats_service.dart';

class PomodoroStatsPage extends StatefulWidget {
  const PomodoroStatsPage({super.key});

  @override
  State<PomodoroStatsPage> createState() => _PomodoroStatsPageState();
}

class _PomodoroStatsPageState extends State<PomodoroStatsPage> {
  final PomodoroStatsService _statsService = PomodoroStatsService();
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>>? _trend;
  int? _maxStreak;
  double? _avgDaily;
  List<PomodoroRecord>? _history;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await _statsService.getStatsSummary();
    final trend = await _statsService.getDailyTrend();
    final maxStreak = await _statsService.getMaxStreak();
    final avgDaily = await _statsService.getAverageDailyCount();
    final history = await _statsService.getHistoryRecords();

    setState(() {
      _summary = summary;
      _trend = trend;
      _maxStreak = maxStreak;
      _avgDaily = avgDaily;
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
      ),
      body: _summary == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildTrendChart(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildStatCard(
          '今日',
          '${_summary!['todayCount']}个',
          _formatDuration(_summary!['todayDuration'] as int),
        ),
        _buildStatCard(
          '本周',
          '${_summary!['weekCount']}个',
          _formatDuration(_summary!['weekDuration'] as int),
        ),
        _buildStatCard(
          '本月',
          '${_summary!['monthCount']}个',
          _formatDuration(_summary!['monthDuration'] as int),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, String duration) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              duration,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) {
      return '${h}h${m}m';
    }
    return '${m}m';
  }

  Widget _buildTrendChart() {
    if (_trend == null || _trend!.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = _trend!.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b);
    final barGroups = _trend!.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (e.value['count'] as int).toDouble(),
            color: AppColors.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '每日趋势',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 2).toDouble(),
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
                        if (value.toInt() < weekdays.length) {
                          return Text(
                            weekdays[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  '最长连续',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_maxStreak ?? 0} 天',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  '平均每日',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_avgDaily ?? 0).toStringAsFixed(1)} 个',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history == null || _history!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '历史记录',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          ...(_history!.take(20).map((r) => _buildHistoryItem(r))),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PomodoroRecord record) {
    final time = '${record.startedAt.hour.toString().padLeft(2, '0')}:${record.startedAt.minute.toString().padLeft(2, '0')}';
    final date = _formatDate(record.startedAt);
    final duration = record.durationSeconds ~/ 60;

    String typeLabel;
    Color typeColor;
    switch (record.type) {
      case PomodoroType.work:
        typeLabel = '专注';
        typeColor = const Color(0xFFFF8A80);
        break;
      case PomodoroType.shortBreak:
        typeLabel = '短休息';
        typeColor = AppColors.success;
        break;
      case PomodoroType.longBreak:
        typeLabel = '长休息';
        typeColor = AppColors.info;
        break;
    }

    return ListTile(
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: typeColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text('$date $time'),
      subtitle: Text('$duration分钟 · $typeLabel'),
      trailing: record.completed
          ? const Icon(Icons.check, color: AppColors.success, size: 20)
          : const Icon(Icons.close, color: AppColors.error, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return '今天';
    if (d == yesterday) return '昨天';
    return '${date.month}/${date.day}';
  }
}