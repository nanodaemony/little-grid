// app/lib/tools/drink_plan/widgets/statistics_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/drink_statistics.dart';

class StatisticsChart extends StatelessWidget {
  final ChartType chartType;
  final TimeRange timeRange;
  final DrinkStatistics statistics;

  const StatisticsChart({
    super.key,
    required this.chartType,
    required this.timeRange,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    if (statistics.totalDays == 0) {
      return const Center(
        child: Text(
          '暂无数据',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    switch (chartType) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  Widget _buildLineChart() {
    List<DailyStat> data;
    switch (timeRange) {
      case TimeRange.last7Days:
        data = statistics.dailyStats.take(7).toList();
        break;
      case TimeRange.last30Days:
        data = statistics.dailyStats.take(30).toList();
        break;
      default:
        data = statistics.dailyStats;
    }

    if (data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.isDrink ? 1 : 0);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('未喝');
                if (value == 1) return const Text('喝酒');
                return const SizedBox.shrink();
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
        minY: -0.1,
        maxY: 1.1,
      ),
    );
  }

  Widget _buildBarChart() {
    List<dynamic> data;
    switch (timeRange) {
      case TimeRange.byMonth:
        data = statistics.monthlyStats;
        break;
      case TimeRange.byYear:
        data = statistics.yearlyStats;
        break;
      default:
        data = statistics.monthlyStats.take(6).toList();
    }

    if (data.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return BarChart(
      BarChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final item = data[index];
                  String label;
                  if (item is MonthlyStat) {
                    label = '${item.month}月';
                  } else if (item is YearlyStat) {
                    label = '${item.year}';
                  } else {
                    label = '';
                  }
                  return Text(label, style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        barGroups: data.asMap().entries.map((e) {
          final index = e.key;
          final item = e.value;
          int noDrinkDays, drinkDays;
          if (item is MonthlyStat) {
            noDrinkDays = item.noDrinkDays;
            drinkDays = item.drinkDays;
          } else {
            noDrinkDays = (item as YearlyStat).noDrinkDays;
            drinkDays = item.drinkDays;
          }
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: noDrinkDays.toDouble(),
                color: Colors.green,
                width: 12,
              ),
              BarChartRodData(
                toY: drinkDays.toDouble(),
                color: Colors.orange,
                width: 12,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: statistics.noDrinkDays.toDouble(),
            title: '未喝\n${statistics.noDrinkDays}天',
            color: Colors.green,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: statistics.drinkDays.toDouble(),
            title: '喝酒\n${statistics.drinkDays}天',
            color: Colors.orange,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
        centerSpaceRadius: 40,
        centerSpaceColor: Colors.white.withOpacity(0.1),
      ),
    );
  }
}
