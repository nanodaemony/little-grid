import '../../core/services/database_service.dart';
import 'calendar_models.dart';

class CalendarService {
  /// 添加记事
  static Future<int> addNote(CalendarNote note) async {
    final db = await DatabaseService.database;
    return await db.insert('calendar_notes', note.toMap());
  }

  /// 获取指定日期的记事
  static Future<List<CalendarNote>> getNotesByDate(String date) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar_notes',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => CalendarNote.fromMap(map)).toList();
  }

  /// 获取指定月份所有有记事的日期
  static Future<Set<String>> getDatesWithNotes(int year, int month) async {
    final db = await DatabaseService.database;
    final prefix = '$year-${month.toString().padLeft(2, '0')}';
    final List<Map<String, dynamic>> maps = await db.query(
      'calendar_notes',
      columns: ['date'],
      where: 'date LIKE ?',
      whereArgs: ['$prefix%'],
      groupBy: 'date',
    );
    return maps.map((map) => map['date'] as String).toSet();
  }

  /// 更新记事
  static Future<void> updateNote(CalendarNote note) async {
    final db = await DatabaseService.database;
    await db.update(
      'calendar_notes',
      note.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// 删除记事
  static Future<void> deleteNote(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'calendar_notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}