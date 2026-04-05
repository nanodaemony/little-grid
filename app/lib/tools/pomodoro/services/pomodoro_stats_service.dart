import '../../../core/services/database_service.dart';
import '../models/pomodoro_record.dart';

class PomodoroStatsService {
  // 插入记录
  Future<void> insertRecord(PomodoroRecord record) async {
    final db = await DatabaseService.database;
    await db.insert('pomodoro_records', record.toMap());
  }

  // 获取今日记录
  Future<List<PomodoroRecord>> getTodayRecords() async {
    final db = await DatabaseService.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND type = ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, PomodoroType.work.name],
      orderBy: 'started_at DESC',
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }

  // 获取今日完成的番茄数
  Future<int> getTodayCount() async {
    final records = await getTodayRecords();
    return records.where((r) => r.completed).length;
  }

  // 获取今日总专注时长（分钟）
  Future<int> getTodayDuration() async {
    final records = await getTodayRecords();
    return records
        .where((r) => r.completed)
        .fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60;
  }

  // 获取本周记录
  Future<List<PomodoroRecord>> getWeekRecords() async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND type = ?',
      whereArgs: [start.millisecondsSinceEpoch, PomodoroType.work.name],
      orderBy: 'started_at DESC',
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }

  // 获取本月记录
  Future<List<PomodoroRecord>> getMonthRecords() async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND type = ?',
      whereArgs: [startOfMonth.millisecondsSinceEpoch, PomodoroType.work.name],
      orderBy: 'started_at DESC',
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }

  // 获取统计汇总
  Future<Map<String, dynamic>> getStatsSummary() async {
    final todayRecords = await getTodayRecords();
    final weekRecords = await getWeekRecords();
    final monthRecords = await getMonthRecords();

    final todayCompleted = todayRecords.where((r) => r.completed).toList();
    final weekCompleted = weekRecords.where((r) => r.completed).toList();
    final monthCompleted = monthRecords.where((r) => r.completed).toList();

    return {
      'todayCount': todayCompleted.length,
      'todayDuration': todayCompleted.fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60,
      'weekCount': weekCompleted.length,
      'weekDuration': weekCompleted.fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60,
      'monthCount': monthCompleted.length,
      'monthDuration': monthCompleted.fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60,
    };
  }

  // 获取每日趋势（最近7天）
  Future<List<Map<String, dynamic>>> getDailyTrend({int days = 7}) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));

      final maps = await db.query(
        'pomodoro_records',
        where: 'started_at >= ? AND started_at < ? AND type = ? AND completed = ?',
        whereArgs: [
          start.millisecondsSinceEpoch,
          end.millisecondsSinceEpoch,
          PomodoroType.work.name,
          1,
        ],
      );

      result.add({
        'date': start,
        'count': maps.length,
      });
    }

    return result;
  }

  // 获取最长连续天数
  Future<int> getMaxStreak() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'pomodoro_records',
      where: 'type = ? AND completed = ?',
      whereArgs: [PomodoroType.work.name, 1],
      orderBy: 'started_at DESC',
    );

    if (maps.isEmpty) return 0;

    final records = maps.map((m) => PomodoroRecord.fromMap(m)).toList();
    final dates = <DateTime>{};

    for (final r in records) {
      final d = DateTime(r.startedAt.year, r.startedAt.month, r.startedAt.day);
      dates.add(d);
    }

    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final date in sortedDates) {
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final diff = lastDate.difference(date).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          if (currentStreak > maxStreak) maxStreak = currentStreak;
          currentStreak = 1;
        }
      }
      lastDate = date;
    }

    if (currentStreak > maxStreak) maxStreak = currentStreak;
    return maxStreak;
  }

  // 获取平均每日番茄数（最近30天）
  Future<double> getAverageDailyCount() async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count, DATE(started_at / 1000, 'unixepoch') as date
      FROM pomodoro_records
      WHERE started_at >= ? AND type = ? AND completed = 1
      GROUP BY date
    ''', [start.millisecondsSinceEpoch, PomodoroType.work.name]);

    if (result.isEmpty) return 0;

    final total = result.fold<int>(0, (sum, r) => sum + (r['count'] as int));
    final days = result.length;

    return total / days;
  }

  // 获取历史记录（分页）
  Future<List<PomodoroRecord>> getHistoryRecords({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'pomodoro_records',
      orderBy: 'started_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }
}