// lib/tools/drink_plan/services/drink_plan_service.dart

import 'package:sqflite/sqflite.dart';
import '../../../core/services/database_service.dart';
import '../models/drink_record.dart';
import '../models/drink_statistics.dart';

class DrinkPlanService {
  static const String _tableRecords = 'drink_records';
  static const String _tableSettings = 'drink_plan_settings';

  /// 获取指定月份的所有记录
  static Future<List<DrinkRecord>> getRecordsByMonth(int year, int month) async {
    final db = await DatabaseService.database;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = '$year-${month.toString().padLeft(2, '0')}-31';

    final maps = await db.query(
      _tableRecords,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );

    return maps.map((map) => DrinkRecord.fromMap(map)).toList();
  }

  /// 获取单条记录
  static Future<DrinkRecord?> getRecordByDate(String date) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableRecords,
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DrinkRecord.fromMap(maps.first);
  }

  /// 添加记录（同一日期会覆盖）
  static Future<void> addRecord(DrinkRecord record) async {
    final db = await DatabaseService.database;
    await db.insert(
      _tableRecords,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除记录
  static Future<void> deleteRecord(String date) async {
    final db = await DatabaseService.database;
    await db.delete(
      _tableRecords,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  /// 获取指定年月已标记的日期列表
  static Future<Set<String>> getMarkedDates(int year, int month) async {
    final records = await getRecordsByMonth(year, month);
    return records.map((r) => r.date).toSet();
  }

  /// 获取背景透明度设置（默认 0.3）
  static Future<double> getBackgroundOpacity() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableSettings,
      where: 'key = ?',
      whereArgs: ['background_opacity'],
      limit: 1,
    );

    if (maps.isEmpty) return 0.3;
    return double.tryParse(maps.first['value'] as String? ?? '0.3') ?? 0.3;
  }

  /// 保存背景透明度设置
  static Future<void> saveSettings(double opacity) async {
    final db = await DatabaseService.database;
    await db.insert(
      _tableSettings,
      {'key': 'background_opacity', 'value': opacity.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取指定年份的所有记录
  static Future<List<DrinkRecord>> getRecordsByYear(int year) async {
    final db = await DatabaseService.database;
    final startDate = '$year-01-01';
    final endDate = '$year-12-31';

    final maps = await db.query(
      _tableRecords,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );

    return maps.map((map) => DrinkRecord.fromMap(map)).toList();
  }

  /// 获取所有记录（用于统计）
  static Future<List<DrinkRecord>> getAllRecords() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableRecords,
      orderBy: 'date ASC',
    );
    return maps.map((map) => DrinkRecord.fromMap(map)).toList();
  }

  /// 获取最近N天的记录
  static Future<List<DrinkRecord>> getRecentRecords(int days) async {
    final db = await DatabaseService.database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final maps = await db.query(
      _tableRecords,
      where: 'date >= ?',
      whereArgs: [startDate.toIso8601String().split('T')[0]],
      orderBy: 'date ASC',
    );

    return maps.map((map) => DrinkRecord.fromMap(map)).toList();
  }

  /// 获取统计数据（按时间维度）
  static Future<DrinkStatistics> getStatistics(TimeRange range) async {
    final records = await getAllRecords();

    if (records.isEmpty) {
      return DrinkStatistics.empty();
    }

    // 按日期排序
    records.sort((a, b) => a.date.compareTo(b.date));

    final dailyStats = await getDailyTrend(365); // 获取足够多的数据
    final monthlyStats = await getMonthlyStats();
    final yearlyStats = await getYearlyStats();

    // 根据范围计算核心数据
    List<DrinkRecord> filteredRecords;
    switch (range) {
      case TimeRange.last7Days:
        filteredRecords = await getRecentRecords(7);
        break;
      case TimeRange.last30Days:
        filteredRecords = await getRecentRecords(30);
        break;
      case TimeRange.byMonth:
      case TimeRange.byYear:
      default:
        filteredRecords = records;
    }

    final totalDays = filteredRecords.length;
    final noDrinkDays = filteredRecords.where((r) => r.mark == 'noDrink').length;
    final drinkDays = totalDays - noDrinkDays;
    final successRate = totalDays > 0 ? (noDrinkDays / totalDays) * 100 : 0.0;

    final currentStreak = await calculateStreak(true);
    final longestStreak = await calculateStreak(false);

    return DrinkStatistics(
      totalDays: totalDays,
      noDrinkDays: noDrinkDays,
      drinkDays: drinkDays,
      successRate: successRate,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      dailyStats: dailyStats,
      monthlyStats: monthlyStats,
      yearlyStats: yearlyStats,
    );
  }

  /// 获取每日趋势数据（最近N天）
  static Future<List<DailyStat>> getDailyTrend(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableRecords,
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'date ASC',
    );

    return maps.map((map) {
      final record = DrinkRecord.fromMap(map);
      return DailyStat(
        date: DateTime.parse(record.date),
        isDrink: record.mark != 'noDrink' && record.mark.isNotEmpty,
      );
    }).toList();
  }

  /// 获取月度汇总数据
  static Future<List<MonthlyStat>> getMonthlyStats() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableRecords,
      orderBy: 'date ASC',
    );

    final records = maps.map((m) => DrinkRecord.fromMap(m)).toList();
    final monthlyMap = <String, MonthlyStat>{};

    for (final record in records) {
      final date = DateTime.parse(record.date);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      final existing = monthlyMap[key];
      if (existing == null) {
        monthlyMap[key] = MonthlyStat(
          year: date.year,
          month: date.month,
          noDrinkDays: record.mark == 'noDrink' ? 1 : 0,
          drinkDays: record.mark != 'noDrink' && record.mark.isNotEmpty ? 1 : 0,
        );
      } else {
        monthlyMap[key] = MonthlyStat(
          year: existing.year,
          month: existing.month,
          noDrinkDays: existing.noDrinkDays + (record.mark == 'noDrink' ? 1 : 0),
          drinkDays: existing.drinkDays + (record.mark != 'noDrink' && record.mark.isNotEmpty ? 1 : 0),
        );
      }
    }

    return monthlyMap.values.toList();
  }

  /// 获取年度汇总数据
  static Future<List<YearlyStat>> getYearlyStats() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableRecords,
      orderBy: 'date ASC',
    );

    final records = maps.map((m) => DrinkRecord.fromMap(m)).toList();
    final yearlyMap = <int, YearlyStat>{};

    for (final record in records) {
      final date = DateTime.parse(record.date);
      final year = date.year;

      final existing = yearlyMap[year];
      if (existing == null) {
        yearlyMap[year] = YearlyStat(
          year: year,
          noDrinkDays: record.mark == 'noDrink' ? 1 : 0,
          drinkDays: record.mark != 'noDrink' && record.mark.isNotEmpty ? 1 : 0,
        );
      } else {
        yearlyMap[year] = YearlyStat(
          year: year,
          noDrinkDays: existing.noDrinkDays + (record.mark == 'noDrink' ? 1 : 0),
          drinkDays: existing.drinkDays + (record.mark != 'noDrink' && record.mark.isNotEmpty ? 1 : 0),
        );
      }
    }

    return yearlyMap.values.toList();
  }

  /// 计算连续未喝天数
  /// isCurrent: true=当前连续（从昨天往前算）, false=历史最长
  static Future<int> calculateStreak(bool isCurrent) async {
    final records = await getAllRecords();
    if (records.isEmpty) return 0;

    // 按日期降序排序
    records.sort((a, b) => b.date.compareTo(a.date));

    if (isCurrent) {
      // 当前连续：从昨天开始往前数连续 noDrink 的天数
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

      int streak = 0;
      DateTime checkDate = yesterday;

      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        final checkDateStr = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

        if (record.date == checkDateStr && record.mark == 'noDrink') {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (record.date.compareTo(checkDateStr) < 0) {
          // 记录日期早于检查日期，说明中间有断档
          break;
        }
      }

      return streak;
    } else {
      // 历史最长连续
      int maxStreak = 0;
      int currentStreak = 0;
      DateTime? lastDate;

      // 按日期升序处理
      records.sort((a, b) => a.date.compareTo(b.date));

      for (final record in records) {
        final date = DateTime.parse(record.date);

        if (record.mark == 'noDrink') {
          if (lastDate == null || date.difference(lastDate).inDays == 1) {
            currentStreak++;
            maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
          } else {
            currentStreak = 1;
          }
          lastDate = date;
        } else {
          currentStreak = 0;
          lastDate = date;
        }
      }

      return maxStreak;
    }
  }
}
