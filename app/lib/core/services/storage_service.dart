import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/tool_config.dart';

class StorageService {
  static Future<void> saveToolConfig(ToolConfig config) async {
    final db = await DatabaseService.database;
    await db.insert(
      'tool_configs',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> saveToolConfigs(List<ToolConfig> configs) async {
    final db = await DatabaseService.database;
    final batch = db.batch();

    for (final config in configs) {
      batch.insert(
        'tool_configs',
        config.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  static Future<List<ToolConfig>> getToolConfigs() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('tool_configs');
    return maps.map((map) => ToolConfig.fromMap(map)).toList();
  }

  static Future<ToolConfig?> getToolConfig(String id) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tool_configs',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ToolConfig.fromMap(maps.first);
  }

  static Future<void> updateToolUsage(String id) async {
    final config = await getToolConfig(id);

    if (config != null) {
      final updated = config.copyWith(
        useCount: config.useCount + 1,
        lastUsedAt: DateTime.now(),
      );
      await saveToolConfig(updated);
    }
  }

  static Future<void> togglePin(String id, bool isPinned) async {
    final db = await DatabaseService.database;
    await db.update(
      'tool_configs',
      {'is_pinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 用户设置
  static Future<void> setSetting(
    String key,
    dynamic value,
    String type,
  ) async {
    final db = await DatabaseService.database;
    await db.insert(
      'user_settings',
      {'key': key, 'value': value.toString(), 'type': type},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getSetting(String key) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  // 头像路径管理
  static const String _avatarPathKey = 'avatar_path';

  static Future<void> saveAvatarPath(String path) async {
    await setSetting(_avatarPathKey, path, 'string');
  }

  static Future<String?> getAvatarPath() async {
    return getSetting(_avatarPathKey);
  }
}
