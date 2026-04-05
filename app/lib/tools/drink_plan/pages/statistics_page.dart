// app/lib/tools/drink_plan/pages/statistics_page.dart

import 'package:flutter/material.dart';
import '../models/drink_statistics.dart';
import '../services/drink_plan_service.dart';
import '../widgets/statistics_chart.dart';
import '../widgets/stat_summary_cards.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  TimeRange _selectedTimeRange = TimeRange.last7Days;
  ChartType _selectedChartType = ChartType.line;
  DrinkStatistics _statistics = DrinkStatistics.empty();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await DrinkPlanService.getStatistics(_selectedTimeRange);
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载数据失败: $e';
        _isLoading = false;
      });
    }
  }

  void _onTimeRangeChanged(TimeRange range) {
    setState(() {
      _selectedTimeRange = range;
    });
    _loadStatistics();
  }

  void _onChartTypeChanged(ChartType type) {
    setState(() {
      _selectedChartType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('饮酒统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间维度切换
          _buildTimeRangeSelector(),
          const SizedBox(height: 16),

          // 数据摘要卡片
          StatSummaryCards(statistics: _statistics),
          const SizedBox(height: 16),

          // 图表类型切换
          _buildChartTypeSelector(),
          const SizedBox(height: 16),

          // 图表区域
          SizedBox(
            height: 300,
            child: StatisticsChart(
              chartType: _selectedChartType,
              timeRange: _selectedTimeRange,
              statistics: _statistics,
            ),
          ),
          const SizedBox(height: 16),

          // 图例
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return SegmentedButton<TimeRange>(
      segments: const [
        ButtonSegment(
          value: TimeRange.last7Days,
          label: Text('近7天'),
          icon: Icon(Icons.view_week),
        ),
        ButtonSegment(
          value: TimeRange.last30Days,
          label: Text('近30天'),
          icon: Icon(Icons.calendar_month),
        ),
        ButtonSegment(
          value: TimeRange.byMonth,
          label: Text('按月'),
          icon: Icon(Icons.date_range),
        ),
        ButtonSegment(
          value: TimeRange.byYear,
          label: Text('按年'),
          icon: Icon(Icons.calendar_today),
        ),
      ],
      selected: {_selectedTimeRange},
      onSelectionChanged: (Set<TimeRange> newSelection) {
        _onTimeRangeChanged(newSelection.first);
      },
    );
  }

  Widget _buildChartTypeSelector() {
    return SegmentedButton<ChartType>(
      segments: const [
        ButtonSegment(
          value: ChartType.line,
          label: Text('曲线'),
          icon: Icon(Icons.show_chart),
        ),
        ButtonSegment(
          value: ChartType.bar,
          label: Text('柱状'),
          icon: Icon(Icons.bar_chart),
        ),
        ButtonSegment(
          value: ChartType.pie,
          label: Text('饼图'),
          icon: Icon(Icons.pie_chart),
        ),
      ],
      selected: {_selectedChartType},
      onSelectionChanged: (Set<ChartType> newSelection) {
        _onChartTypeChanged(newSelection.first);
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.green, '未喝'),
        const SizedBox(width: 24),
        _buildLegendItem(Colors.orange, '喝酒'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
