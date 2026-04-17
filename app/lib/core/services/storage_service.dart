import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/tool_config.dart';
import '../models/card_background.dart';

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

  // 通用字符串存储方法
  static Future<void> setString(String key, String value) async {
    await setSetting(key, value, 'string');
  }

  static Future<String?> getString(String key) async {
    return getSetting(key);
  }

  static Future<void> remove(String key) async {
    final db = await DatabaseService.database;
    await db.delete(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  // 卡片背景主题管理
  static const String _cardBackgroundKey = 'card_background';

  static Future<void> saveCardBackground(CardBackground background) async {
    final map = background.toMap();
    // 将 map 序列化为 JSON 字符串存储
    final jsonStr = _encodeBackgroundMap(map);
    await setString(_cardBackgroundKey, jsonStr);
  }

  static Future<CardBackground?> getCardBackground() async {
    final jsonStr = await getString(_cardBackgroundKey);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = _decodeBackgroundMap(jsonStr);
      return CardBackground.fromMap(map);
    } catch (e) {
      return null;
    }
  }

  // 简单的 JSON 序列化（避免引入额外依赖）
  static String _encodeBackgroundMap(Map<String, dynamic> map) {
    final type = map['type'] as int;
    final colorKey = map['colorKey'] as String? ?? '';
    final assetPath = map['assetPath'] as String? ?? '';
    return '$type|$colorKey|$assetPath';
  }

  static Map<String, dynamic> _decodeBackgroundMap(String str) {
    final parts = str.split('|');
    return {
      'type': int.parse(parts[0]),
      'colorKey': parts.length > 1 && parts[1].isNotEmpty ? parts[1] : null,
      'assetPath': parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
    };
  }
}
