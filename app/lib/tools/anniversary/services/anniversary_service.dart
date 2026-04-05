import '../../../core/services/database_service.dart';
import '../models/anniversary_models.dart';

class AnniversaryService {
  static Future<int> add(AnniversaryBase item) async {
    final db = await DatabaseService.database;
    return await db.insert('anniversary_items', item.toMap());
  }

  static Future<List<AnniversaryBase>> getAll() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'anniversary_items',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => anniversaryFromMap(map)).toList();
  }

  static Future<void> update(AnniversaryBase item) async {
    final db = await DatabaseService.database;
    await db.update(
      'anniversary_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'anniversary_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static List<AnniversaryBase> sortByUrgency(List<AnniversaryBase> items) {
    return [...items]..sort((a, b) {
      final daysA = _getUrgencyDays(a);
      final daysB = _getUrgencyDays(b);
      return daysA.compareTo(daysB);
    });
  }

  static int _getUrgencyDays(AnniversaryBase item) {
    final display = item.calculateDisplay();
    if (item is AnniversaryItem && item.repeatType == RepeatType.none) {
      return 9999;
    }
    return display.primaryNumber;
  }
}
