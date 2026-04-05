import 'database_service.dart';
import '../models/usage_stat.dart';
import '../utils/logger.dart';

class UsageService {
  static final Map<String, DateTime> _sessionStartTimes = {};

  static void recordEnter(String toolId) {
    _sessionStartTimes[toolId] = DateTime.now();
    AppLogger.d('Tool entered: $toolId');
  }

  static Future<void> recordExit(String toolId) async {
    final startTime = _sessionStartTimes[toolId];
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime).inSeconds;

    await recordUsage(UsageStat(
      toolId: toolId,
      usedAt: startTime,
      duration: duration,
    ));

    _sessionStartTimes.remove(toolId);
    AppLogger.d('Tool exited: $toolId, duration: ${duration}s');
  }

  static Future<void> recordUsage(UsageStat stat) async {
    final db = await DatabaseService.database;
    await db.insert('usage_stats', stat.toMap());
  }

  static Future<List<UsageStat>> getUsageStats({String? toolId}) async {
    final db = await DatabaseService.database;

    String? where;
    List<Object?>? whereArgs;

    if (toolId != null) {
      where = 'tool_id = ?';
      whereArgs = [toolId];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'usage_stats',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'used_at DESC',
    );

    return maps.map((map) => UsageStat.fromMap(map)).toList();
  }

  static Future<Map<String, int>> getUsageCounts() async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery('''
      SELECT tool_id, COUNT(*) as count
      FROM usage_stats
      GROUP BY tool_id
    ''');

    return {
      for (var row in result) row['tool_id'] as String: row['count'] as int,
    };
  }

  static Future<void> clearOldStats({int daysToKeep = 90}) async {
    final db = await DatabaseService.database;
    final cutoff = DateTime.now().subtract(Duration(days: daysToKeep));

    await db.delete(
      'usage_stats',
      where: 'used_at < ?',
      whereArgs: [cutoff.millisecondsSinceEpoch],
    );
  }
}
