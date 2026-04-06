import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../constants/app_constants.dart';

/// 日志存储服务
/// 将日志持久化到 SQLite，支持历史查询
class LogStorageService {
  static final LogStorageService _instance = LogStorageService._internal();
  factory LogStorageService() => _instance;
  LogStorageService._internal();

  /// 保存日志
  Future<void> save({
    required String level,
    required String message,
    String? module,
    String? traceId,
    String? error,
  }) async {
    final db = await DatabaseService.database;

    await db.insert('logs', {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'level': level,
      'module': module,
      'trace_id': traceId,
      'message': message,
      'error': error,
    });

    // 清理旧日志
    await _cleanupOldLogs(db);
  }

  /// 获取日志列表
  Future<List<Map<String, dynamic>>> getLogs({
    int limit = 100,
    String? level,
    String? module,
    String? traceId,
    String? search,
  }) async {
    final db = await DatabaseService.database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (level != null) {
      whereClause += 'level = ?';
      whereArgs.add(level);
    }
    if (module != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'module = ?';
      whereArgs.add(module);
    }
    if (traceId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'trace_id = ?';
      whereArgs.add(traceId);
    }
    if (search != null && search.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'message LIKE ?';
      whereArgs.add('%$search%');
    }

    final results = await db.query(
      'logs',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return results;
  }

  /// 按 TraceId 获取关联日志
  Future<List<Map<String, dynamic>>> getLogsByTraceId(String traceId) async {
    return getLogs(traceId: traceId, limit: 500);
  }

  /// 清空所有日志
  Future<void> clearAll() async {
    final db = await DatabaseService.database;
    await db.delete('logs');
  }

  /// 清理超过最大数量的旧日志
  Future<void> _cleanupOldLogs(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM logs')
    ) ?? 0;

    if (count > AppConstants.logMaxCount) {
      final deleteCount = count - AppConstants.logMaxCount;
      await db.rawDelete(
        'DELETE FROM logs WHERE id IN (SELECT id FROM logs ORDER BY timestamp ASC LIMIT ?)',
        [deleteCount]
      );
    }
  }

  /// 导出日志为文本
  Future<String> exportLogs({int limit = 1000}) async {
    final logs = await getLogs(limit: limit);
    final buffer = StringBuffer();

    for (final log in logs) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(log['timestamp'] as int);
      final timeStr = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
          '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';

      buffer.writeln('$timeStr ${log['level']} [${log['module'] ?? 'App'}] [${log['trace_id'] ?? 'no-trace'}] ${log['message']}');
      if (log['error'] != null) {
        buffer.writeln('  Error: ${log['error']}');
      }
    }

    return buffer.toString();
  }
}