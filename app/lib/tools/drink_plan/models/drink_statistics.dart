// lib/tools/drink_plan/models/drink_statistics.dart

import 'package:flutter/material.dart';

/// 时间范围枚举
enum TimeRange {
  last7Days,
  last30Days,
  byMonth,
  byYear,
}

/// 图表类型枚举
enum ChartType {
  line,
  bar,
  pie,
}

/// 每日统计数据
class DailyStat {
  final DateTime date;
  final bool isDrink;
  final int drinkDays;
  final int noDrinkDays;
  final int totalSugar;

  const DailyStat({
    required this.date,
    this.isDrink = false,
    this.drinkDays = 0,
    this.noDrinkDays = 0,
    this.totalSugar = 0,
  });
}

/// 每月统计数据
class MonthlyStat {
  final int year;
  final int month;
  final int drinkDays;
  final int noDrinkDays;
  final int totalSugar;

  const MonthlyStat({
    required this.year,
    required this.month,
    this.drinkDays = 0,
    this.noDrinkDays = 0,
    this.totalSugar = 0,
  });
}

/// 每年统计数据
class YearlyStat {
  final int year;
  final int drinkDays;
  final int noDrinkDays;
  final int totalSugar;

  const YearlyStat({
    required this.year,
    this.drinkDays = 0,
    this.noDrinkDays = 0,
    this.totalSugar = 0,
  });
}

/// 饮酒统计数据
class DrinkStatistics {
  final int totalDays;
  final int noDrinkDays;
  final int drinkDays;
  final double noDrinkRate;
  final double averageSugar;
  final int totalSugar;
  final double successRate;
  final int currentStreak;
  final int longestStreak;
  final List<DailyStat> dailyStats;
  final List<MonthlyStat> monthlyStats;
  final List<YearlyStat> yearlyStats;

  const DrinkStatistics({
    required this.totalDays,
    required this.noDrinkDays,
    required this.drinkDays,
    this.noDrinkRate = 0.0,
    this.averageSugar = 0.0,
    this.totalSugar = 0,
    required this.successRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyStats,
    required this.monthlyStats,
    required this.yearlyStats,
  });

  /// 空统计数据
  factory DrinkStatistics.empty() {
    return const DrinkStatistics(
      totalDays: 0,
      noDrinkDays: 0,
      drinkDays: 0,
      noDrinkRate: 0.0,
      averageSugar: 0.0,
      totalSugar: 0,
      successRate: 0.0,
      currentStreak: 0,
      longestStreak: 0,
      dailyStats: [],
      monthlyStats: [],
      yearlyStats: [],
    );
  }
}
