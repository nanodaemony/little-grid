// app/lib/tools/big_wheel/services/big_wheel_service.dart

import '../../../core/services/database_service.dart';
import '../models/wheel_collection.dart';
import '../models/wheel_option.dart';

class BigWheelService {
  // ========== Preset Colors ==========
  static const List<String> _presetColors = [
    '#FF6B6B',
    '#4ECDC4',
    '#FFE66D',
    '#95E1D3',
    '#F38181',
    '#AA96DA',
    '#FFD93D',
    '#6BCB77',
  ];

  // ========== Preset Collections Data ==========
  static final List<Map<String, dynamic>> _presetCollectionsData = [
    {
      'name': '今天吃什么',
      'icon': '🍽️',
      'options': ['火锅', '烧烤', '日料', '川菜', '粤菜', '西餐', '韩料', '小吃'],
    },
    {
      'name': 'YES or NO',
      'icon': '🤔',
      'options': ['YES', 'NO', '再想想'],
    },
    {
      'name': '周末活动',
      'icon': '🎉',
      'options': ['看电影', '逛街', '宅家', '运动', '爬山', '探店'],
    },
  ];

  /// Initialize preset collections (called once on first run)
  static Future<void> initPresetCollections() async {
    final db = await DatabaseService.database;
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM wheel_collections');
    final existingCount = (count.first['count'] as int);

    if (existingCount > 0) return;

    // Insert preset collections and their options
    int colorIndex = 0;
    int collectionSortOrder = 1;

    for (final presetData in _presetCollectionsData) {
      // Create collection
      final collection = WheelCollection(
        name: presetData['name'] as String,
        iconType: IconType.emoji,
        icon: presetData['icon'] as String,
        isPreset: true,
        sortOrder: collectionSortOrder++,
      );

      // Insert collection
      final collectionId = await db.insert('wheel_collections', collection.toMap());

      // Insert options for this collection
      final options = presetData['options'] as List<String>;
      int optionSortOrder = 1;

      for (final optionName in options) {
        final option = WheelOption(
          collectionId: collectionId,
          name: optionName,
          iconType: IconType.emoji,
          weight: 1.0,
          color: _presetColors[colorIndex % _presetColors.length],
          sortOrder: optionSortOrder++,
        );
        await db.insert('wheel_options', option.toMap());
        colorIndex++;
      }
    }
  }

  // ========== Collection Operations ==========

  /// Get all collections sorted by sort_order
  static Future<List<WheelCollection>> getCollections() async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wheel_collections',
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map((map) => WheelCollection.fromMap(map)).toList();
  }

  /// Get single collection by id
  static Future<WheelCollection?> getCollection(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'wheel_collections',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return WheelCollection.fromMap(maps.first);
  }

  /// Insert or update collection
  static Future<int> saveCollection(WheelCollection collection) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();

    if (collection.id == null) {
      // Insert new collection
      final data = collection.toMap();
      data['created_at'] = now.millisecondsSinceEpoch;
      data['updated_at'] = now.millisecondsSinceEpoch;
      return await db.insert('wheel_collections', data);
    } else {
      // Update existing collection
      final data = collection.copyWith(updatedAt: now).toMap();
      return await db.update(
        'wheel_collections',
        data,
        where: 'id = ?',
        whereArgs: [collection.id],
      );
    }
  }

  /// Delete collection by id
  static Future<int> deleteCollection(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'wheel_collections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update sort_order for list of collections (batch operation)
  static Future<void> updateSortOrder(List<WheelCollection> collections) async {
    final db = await DatabaseService.database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < collections.length; i++) {
      batch.update(
        'wheel_collections',
        {
          'sort_order': i + 1,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [collections[i].id],
      );
    }

    await batch.commit(noResult: true);
  }

  // ========== Option Operations ==========

  /// Get options for a collection
  static Future<List<WheelOption>> getOptions(int collectionId) async {
    final db = await DatabaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wheel_options',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
      orderBy: 'sort_order ASC, id ASC',
    );
    return maps.map((map) => WheelOption.fromMap(map)).toList();
  }

  /// Get single option by id
  static Future<WheelOption?> getOption(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'wheel_options',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return WheelOption.fromMap(maps.first);
  }

  /// Insert or update option (auto-assign color for new options)
  static Future<int> saveOption(WheelOption option) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();

    if (option.id == null) {
      // Insert new option
      // Auto-assign color based on existing options count
      final color = option.color ?? await _getNextColor(option.collectionId);

      final data = option.copyWith(color: color).toMap();
      data['created_at'] = now.millisecondsSinceEpoch;
      data['updated_at'] = now.millisecondsSinceEpoch;
      return await db.insert('wheel_options', data);
    } else {
      // Update existing option
      final data = option.copyWith(updatedAt: now).toMap();
      return await db.update(
        'wheel_options',
        data,
        where: 'id = ?',
        whereArgs: [option.id],
      );
    }
  }

  /// Get next available color based on existing options count
  static Future<String> _getNextColor(int collectionId) async {
    final db = await DatabaseService.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM wheel_options WHERE collection_id = ?',
      [collectionId],
    );
    final existingCount = (count.first['count'] as int);
    return _presetColors[existingCount % _presetColors.length];
  }

  /// Delete option by id
  static Future<int> deleteOption(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'wheel_options',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update sort_order for list of options (batch operation)
  static Future<void> updateOptionSortOrder(List<WheelOption> options) async {
    final db = await DatabaseService.database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < options.length; i++) {
      batch.update(
        'wheel_options',
        {
          'sort_order': i + 1,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [options[i].id],
      );
    }

    await batch.commit(noResult: true);
  }
}
