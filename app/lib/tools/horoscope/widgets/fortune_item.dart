import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/horoscope_data.dart';
import '../horoscope_service.dart';

/// 分项运势项
class FortuneItem extends StatelessWidget {
  final String category;
  final int score;
  final String desc;
  final int index;

  const FortuneItem({
    super.key,
    required this.category,
    required this.score,
    required this.desc,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final color = HoroscopeData.getScoreColor(score);
    final shortDesc = HoroscopeService.getShortDesc(score, category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HoroscopeService.getCategoryIcon(category),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 名称 + 进度条
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HoroscopeService.getCategoryName(category),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 分数
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                shortDesc,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms);
  }
}
