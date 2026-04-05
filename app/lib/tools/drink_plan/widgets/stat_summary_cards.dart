// app/lib/tools/drink_plan/widgets/stat_summary_cards.dart

import 'package:flutter/material.dart';
import '../models/drink_statistics.dart';

class StatSummaryCards extends StatelessWidget {
  final DrinkStatistics statistics;

  const StatSummaryCards({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 第一行：核心数据
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '总记录',
                statistics.totalDays.toString(),
                Colors.blue,
                Icons.calendar_today,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                '未喝',
                statistics.noDrinkDays.toString(),
                Colors.green,
                Icons.check_circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                '喝酒',
                statistics.drinkDays.toString(),
                Colors.orange,
                Icons.local_drink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 第二行：成功率和连续记录
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '成功率',
                '${statistics.successRate.toStringAsFixed(1)}%',
                Colors.purple,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                '当前连续',
                '${statistics.currentStreak}天',
                Colors.teal,
                Icons.whatshot,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                '最长连续',
                '${statistics.longestStreak}天',
                Colors.indigo,
                Icons.emoji_events,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
