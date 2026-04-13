# Service 层模板

```dart
import '../../core/services/database_service.dart';
import 'xxx_models.dart';

class XxxService {
  /// 添加
  static Future<int> add(XxxItem item) async {
    final db = await DatabaseService.database;
    return await db.insert('xxx_items', item.toMap());
  }

  /// 查询列表
  static Future<List<XxxItem>> getAll() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'xxx_items',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => XxxItem.fromMap(m)).toList();
  }

  /// 更新
  static Future<void> update(XxxItem item) async {
    final db = await DatabaseService.database;
    await db.update(
      'xxx_items',
      item.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 删除
  static Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'xxx_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```
