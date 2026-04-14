import 'package:flutter/material.dart';

/// 运势数据
class HoroscopeData {
  final String type;            // 'today', 'week'
  final int overallScore;       // 综合指数 0-100
  final String overallDesc;     // 综合描述

  final int loveScore;          // 爱情指数
  final String loveDesc;        // 爱情描述

  final int careerScore;        // 事业指数
  final String careerDesc;      // 事业描述

  final int wealthScore;        // 财运指数
  final String wealthDesc;      // 财运描述

  final int healthScore;        // 健康指数
  final String healthDesc;      // 健康描述

  HoroscopeData({
    required this.type,
    required this.overallScore,
    required this.overallDesc,
    required this.loveScore,
    required this.loveDesc,
    required this.careerScore,
    required this.careerDesc,
    required this.wealthScore,
    required this.wealthDesc,
    required this.healthScore,
    required this.healthDesc,
  });

  /// 根据分数获取颜色
  static Color getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.amber;
    return Colors.red;
  }

  /// 获取渐变颜色
  static List<Color> getGradientColors(int score) {
    if (score >= 80) {
      return [Colors.green.shade400, Colors.green.shade700];
    }
    if (score >= 60) {
      return [Colors.orange.shade400, Colors.orange.shade700];
    }
    if (score >= 40) {
      return [Colors.amber.shade400, Colors.amber.shade700];
    }
    return [Colors.red.shade400, Colors.red.shade700];
  }
}
