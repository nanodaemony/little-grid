# Big Wheel (大转盘) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a spinning wheel feature where users can create multiple wheel collections, each containing options with customizable weights. The wheel spins with physics-based animation and randomly selects an option.

**Architecture:** Follow the existing tool pattern in the codebase - implement `ToolModule` interface, use SQLite for data storage via `DatabaseService`, and organize files into models/services/widgets/pages subdirectories. Use CustomPainter for wheel rendering and Flutter's animation system for physics-based spinning.

**Tech Stack:** Flutter, Dart, SQLite (sqflite), CustomPainter, AnimationController

**Reference Spec:** `docs/superpowers/specs/2026-03-25-big-wheel-design.md`

---

## File Structure Overview

**New Files to Create:**
- `app/lib/tools/big_wheel/big_wheel_tool.dart` - ToolModule implementation
- `app/lib/tools/big_wheel/big_wheel_page.dart` - Main page with PageView
- `app/lib/tools/big_wheel/big_wheel_view.dart` - Single wheel view
- `app/lib/tools/big_wheel/models/wheel_collection.dart` - Collection model
- `app/lib/tools/big_wheel/models/wheel_option.dart` - Option model
- `app/lib/tools/big_wheel/services/big_wheel_service.dart` - Database operations
- `app/lib/tools/big_wheel/widgets/wheel_painter.dart` - CustomPainter for wheel
- `app/lib/tools/big_wheel/widgets/wheel_pointer.dart` - Fixed pointer widget
- `app/lib/tools/big_wheel/widgets/result_dialog.dart` - Result display dialog
- `app/lib/tools/big_wheel/pages/collection_list_page.dart` - Collection management
- `app/lib/tools/big_wheel/pages/collection_edit_page.dart` - Collection edit
- `app/lib/tools/big_wheel/pages/option_list_page.dart` - Option management
- `app/lib/tools/big_wheel/pages/option_edit_page.dart` - Option edit

**Files to Modify:**
- `app/lib/core/constants/app_constants.dart` - Update dbVersion from 6 to 7
- `app/lib/core/services/database_service.dart` - Add wheel tables in _onUpgrade
- `app/lib/main.dart` - Register BigWheelTool

---

## Task 1: Database Schema & Constants

**Files:**
- Modify: `app/lib/core/constants/app_constants.dart`
- Modify: `app/lib/core/services/database_service.dart`

- [ ] **Step 1: Update database version constant**

```dart
// In app/lib/core/constants/app_constants.dart
// Change line 12:
static const int dbVersion = 7;  // Was 6
```

- [ ] **Step 2: Add wheel tables in database upgrade**

In `app/lib/core/services/database_service.dart`, add to `_onUpgrade` method after version 6 block:

```dart
if (oldVersion < 7) {
  // Delete old wheel_options table if exists (conflict with new schema)
  await db.execute('DROP TABLE IF EXISTS wheel_options');
  AppLogger.i('Dropped old wheel_options table');

  // Create wheel collections table
  await db.execute('''
    CREATE TABLE wheel_collections (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon_type INTEGER DEFAULT 0,
      icon TEXT NOT NULL,
      is_preset INTEGER DEFAULT 0,
      sort_order INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');

  // Create wheel options table
  await db.execute('''
    CREATE TABLE wheel_options (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      collection_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      icon_type INTEGER DEFAULT 0,
      icon TEXT,
      weight REAL DEFAULT 1.0,
      color TEXT,
      sort_order INTEGER DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (collection_id) REFERENCES wheel_collections(id) ON DELETE CASCADE
    )
  ''');

  await db.execute('CREATE INDEX idx_wheel_options_collection ON wheel_options(collection_id)');
  AppLogger.i('Added big wheel tables');
}
```

- [ ] **Step 3: Commit database changes**

```bash
git add app/lib/core/constants/app_constants.dart app/lib/core/services/database_service.dart
git commit -m "feat(big_wheel): add database schema for wheel collections and options (v7)"
```

---

## Task 2: Data Models

**Files:**
- Create: `app/lib/tools/big_wheel/models/wheel_collection.dart`
- Create: `app/lib/tools/big_wheel/models/wheel_option.dart`

- [ ] **Step 1: Create WheelCollection model**

```dart
// app/lib/tools/big_wheel/models/wheel_collection.dart

enum IconType { emoji, material }

class WheelCollection {
  final int? id;
  final String name;
  final IconType iconType;
  final String icon;
  final bool isPreset;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  WheelCollection({
    this.id,
    required this.name,
    this.iconType = IconType.emoji,
    required this.icon,
    this.isPreset = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_type': iconType == IconType.emoji ? 0 : 1,
      'icon': icon,
      'is_preset': isPreset ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WheelCollection.fromMap(Map<String, dynamic> map) {
    return WheelCollection(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconType: map['icon_type'] == 0 ? IconType.emoji : IconType.material,
      icon: map['icon'] as String,
      isPreset: map['is_preset'] == 1,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  WheelCollection copyWith({
    int? id,
    String? name,
    IconType? iconType,
    String? icon,
    bool? isPreset,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WheelCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      iconType: iconType ?? this.iconType,
      icon: icon ?? this.icon,
      isPreset: isPreset ?? this.isPreset,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

- [ ] **Step 2: Create WheelOption model**

```dart
// app/lib/tools/big_wheel/models/wheel_option.dart

import 'wheel_collection.dart';

class WheelOption {
  final int? id;
  final int collectionId;
  final String name;
  final IconType iconType;
  final String? icon;
  final double weight;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  WheelOption({
    this.id,
    required this.collectionId,
    required this.name,
    this.iconType = IconType.emoji,
    this.icon,
    this.weight = 1.0,
    this.color,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection_id': collectionId,
      'name': name,
      'icon_type': iconType == IconType.emoji ? 0 : 1,
      'icon': icon,
      'weight': weight,
      'color': color,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WheelOption.fromMap(Map<String, dynamic> map) {
    return WheelOption(
      id: map['id'] as int?,
      collectionId: map['collection_id'] as int,
      name: map['name'] as String,
      iconType: map['icon_type'] == 0 ? IconType.emoji : IconType.material,
      icon: map['icon'] as String?,
      weight: map['weight'] as double,
      color: map['color'] as String?,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  WheelOption copyWith({
    int? id,
    int? collectionId,
    String? name,
    IconType? iconType,
    String? icon,
    double? weight,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WheelOption(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      iconType: iconType ?? this.iconType,
      icon: icon ?? this.icon,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

- [ ] **Step 3: Commit models**

```bash
git add app/lib/tools/big_wheel/models/
git commit -m "feat(big_wheel): add WheelCollection and WheelOption data models"
```

---

## Task 3: Database Service

**Files:**
- Create: `app/lib/tools/big_wheel/services/big_wheel_service.dart`

- [ ] **Step 1: Create BigWheelService with CRUD operations**

```dart
// app/lib/tools/big_wheel/services/big_wheel_service.dart

import '../../../core/services/database_service.dart';
import '../models/wheel_collection.dart';
import '../models/wheel_option.dart';

class BigWheelService {
  // Preset wheel data
  static final List<Map<String, dynamic>> _presetCollections = [
    {
      'name': '今天吃什么',
      'icon': '🍽️',
      'icon_type': 0,
      'options': ['火锅', '烧烤', '日料', '川菜', '粤菜', '西餐', '韩料', '小吃'],
    },
    {
      'name': 'YES or NO',
      'icon': '❓',
      'icon_type': 0,
      'options': ['YES', 'NO', '再想想'],
    },
    {
      'name': '周末活动',
      'icon': '🎉',
      'icon_type': 0,
      'options': ['看电影', '逛街', '宅家', '运动', '爬山', '探店'],
    },
  ];

  static const List<String> _wheelColors = [
    '#FF6B6B', '#4ECDC4', '#FFE66D', '#95E1D3',
    '#F38181', '#AA96DA', '#FFD93D', '#6BCB77',
  ];

  // Initialize preset collections
  static Future<void> initPresetCollections() async {
    final collections = await getCollections();
    if (collections.isNotEmpty) return; // Already initialized

    final db = await DatabaseService.database;

    for (int i = 0; i < _presetCollections.length; i++) {
      final preset = _presetCollections[i];

      // Insert collection
      final collectionMap = {
        'name': preset['name'],
        'icon_type': preset['icon_type'],
        'icon': preset['icon'],
        'is_preset': 1,
        'sort_order': i,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };

      final collectionId = await db.insert('wheel_collections', collectionMap);

      // Insert options
      final options = preset['options'] as List<String>;
      for (int j = 0; j < options.length; j++) {
        final optionMap = {
          'collection_id': collectionId,
          'name': options[j],
          'icon_type': 0,
          'weight': 1.0,
          'color': _wheelColors[j % _wheelColors.length],
          'sort_order': j,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        };
        await db.insert('wheel_options', optionMap);
      }
    }
  }

  // ========== Collection CRUD ==========

  static Future<List<WheelCollection>> getCollections() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'wheel_collections',
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return maps.map((m) => WheelCollection.fromMap(m)).toList();
  }

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

  static Future<int> saveCollection(WheelCollection collection) async {
    final db = await DatabaseService.database;
    if (collection.id == null) {
      return await db.insert('wheel_collections', collection.toMap());
    } else {
      await db.update(
        'wheel_collections',
        collection.toMap(),
        where: 'id = ?',
        whereArgs: [collection.id],
      );
      return collection.id!;
    }
  }

  static Future<void> deleteCollection(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'wheel_collections',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateSortOrder(List<WheelCollection> collections) async {
    final db = await DatabaseService.database;
    final batch = db.batch();
    for (int i = 0; i < collections.length; i++) {
      batch.update(
        'wheel_collections',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [collections[i].id],
      );
    }
    await batch.commit(noResult: true);
  }

  // ========== Option CRUD ==========

  static Future<List<WheelOption>> getOptions(int collectionId) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'wheel_options',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return maps.map((m) => WheelOption.fromMap(m)).toList();
  }

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

  static Future<int> saveOption(WheelOption option) async {
    final db = await DatabaseService.database;
    if (option.id == null) {
      // Assign color for new option
      final existingOptions = await getOptions(option.collectionId);
      final colorIndex = existingOptions.length % _wheelColors.length;
      final map = option.toMap();
      map['color'] = option.color ?? _wheelColors[colorIndex];
      return await db.insert('wheel_options', map);
    } else {
      await db.update(
        'wheel_options',
        option.toMap(),
        where: 'id = ?',
        whereArgs: [option.id],
      );
      return option.id!;
    }
  }

  static Future<void> deleteOption(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'wheel_options',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> updateOptionSortOrder(List<WheelOption> options) async {
    final db = await DatabaseService.database;
    final batch = db.batch();
    for (int i = 0; i < options.length; i++) {
      batch.update(
        'wheel_options',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [options[i].id],
      );
    }
    await batch.commit(noResult: true);
  }

  // ========== Utility ==========

  static String getColorForIndex(int index) {
    return _wheelColors[index % _wheelColors.length];
  }
}
```

- [ ] **Step 2: Commit service**

```bash
git add app/lib/tools/big_wheel/services/
git commit -m "feat(big_wheel): add BigWheelService with CRUD and preset initialization"
```

---

## Task 4: ToolModule Implementation

**Files:**
- Create: `app/lib/tools/big_wheel/big_wheel_tool.dart`
- Modify: `app/lib/main.dart`

- [ ] **Step 1: Create BigWheelTool**

```dart
// app/lib/tools/big_wheel/big_wheel_tool.dart

import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'big_wheel_page.dart';
import 'services/big_wheel_service.dart';

class BigWheelTool implements ToolModule {
  @override
  String get id => 'big_wheel';

  @override
  String get name => '大转盘';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.rotate_right;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const BigWheelPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {
    await BigWheelService.initPresetCollections();
  }

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: Register tool in main.dart**

Add import at top of `app/lib/main.dart`:
```dart
import 'tools/big_wheel/big_wheel_tool.dart';
```

Add registration in main() function (around line 52, after RmbConvertorTool):
```dart
ToolRegistry.register(BigWheelTool());
```

- [ ] **Step 3: Commit tool registration**

```bash
git add app/lib/tools/big_wheel/big_wheel_tool.dart app/lib/main.dart
git commit -m "feat(big_wheel): add BigWheelTool and register in main"
```

---

## Task 5: Wheel Widgets

**Files:**
- Create: `app/lib/tools/big_wheel/widgets/wheel_painter.dart`
- Create: `app/lib/tools/big_wheel/widgets/wheel_pointer.dart`
- Create: `app/lib/tools/big_wheel/widgets/result_dialog.dart`

- [ ] **Step 1: Create WheelPainter**

```dart
// app/lib/tools/big_wheel/widgets/wheel_painter.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wheel_option.dart';

class WheelPainter extends CustomPainter {
  final List<WheelOption> options;
  final double rotationAngle;

  WheelPainter({
    required this.options,
    required this.rotationAngle,
  });

  @override
   void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final totalWeight = options.fold<double>(0, (sum, o) => sum + o.weight);
    double currentAngle = rotationAngle * (pi / 180);

    for (final option in options) {
      final sweepAngle = (option.weight / totalWeight) * 2 * pi;

      // Draw sector
      final paint = Paint()
        ..color = _parseColor(option.color)
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          currentAngle,
          sweepAngle,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);

      // Draw text
      final textAngle = currentAngle + sweepAngle / 2;
      final textRadius = radius * 0.65;
      final textOffset = Offset(
        center.dx + cos(textAngle) * textRadius,
        center.dy + sin(textAngle) * textRadius,
      );

      _drawText(canvas, option.name, textOffset, textAngle);

      currentAngle += sweepAngle;
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.08, centerPaint);

    final centerBorderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.08, centerBorderPaint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, double angle) {
    // Simple text drawing - adjust angle for readability
    double displayAngle = angle;
    if (angle > pi / 2 && angle < 3 * pi / 2) {
      displayAngle += pi; // Flip text on left side
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(displayAngle);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null) return Colors.blue;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.options.length != options.length;
  }
}
```

- [ ] **Step 2: Create WheelPointer**

```dart
// app/lib/tools/big_wheel/widgets/wheel_pointer.dart

import 'package:flutter/material.dart';

class WheelPointer extends StatelessWidget {
  final double size;

  const WheelPointer({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.2),
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.7)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 0.5,
        0,
        size.height * 0.7,
      )
      ..close();

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, borderPaint);

    // Center circle
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.6),
      6,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

- [ ] **Step 3: Create ResultDialog**

```dart
// app/lib/tools/big_wheel/widgets/result_dialog.dart

import 'package:flutter/material.dart';
import '../models/wheel_option.dart';

class ResultDialog extends StatelessWidget {
  final WheelOption option;
  final VoidCallback onSpinAgain;

  const ResultDialog({
    super.key,
    required this.option,
    required this.onSpinAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉 结果',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _parseColor(option.color),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (option.icon != null)
                      Text(
                        option.icon!,
                        style: const TextStyle(fontSize: 40),
                      ),
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('关闭'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onSpinAgain();
                  },
                  icon: const Icon(Icons.rotate_right),
                  label: const Text('再转一次'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null) return Colors.blue;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
```

- [ ] **Step 4: Commit widgets**

```bash
git add app/lib/tools/big_wheel/widgets/
git commit -m "feat(big_wheel): add wheel painter, pointer, and result dialog widgets"
```

---

## Task 6: Main Page and Wheel View

**Files:**
- Create: `app/lib/tools/big_wheel/big_wheel_page.dart`
- Create: `app/lib/tools/big_wheel/big_wheel_view.dart`

- [ ] **Step 1: Create BigWheelView (single wheel widget)**

```dart
// app/lib/tools/big_wheel/big_wheel_view.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'models/wheel_collection.dart';
import 'models/wheel_option.dart';
import 'services/big_wheel_service.dart';
import 'widgets/wheel_painter.dart';
import 'widgets/wheel_pointer.dart';
import 'widgets/result_dialog.dart';

class BigWheelView extends StatefulWidget {
  final WheelCollection collection;

  const BigWheelView({
    super.key,
    required this.collection,
  });

  @override
  State<BigWheelView> createState() => _BigWheelViewState();
}

class _BigWheelViewState extends State<BigWheelView>
    with SingleTickerProviderStateMixin {
  List<WheelOption> _options = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentAngle = 0;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _loadOptions();
  }

  @override
  void didUpdateWidget(covariant BigWheelView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collection.id != widget.collection.id) {
      _loadOptions();
      _currentAngle = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final options = await BigWheelService.getOptions(widget.collection.id!);
    setState(() {
      _options = options;
    });
  }

  void _spin() {
    if (_isSpinning || _options.length < 2) return;

    setState(() {
      _isSpinning = true;
    });

    // Calculate target option based on weights
    final targetOption = _selectOptionByWeight();
    final targetAngle = _calculateTargetAngle(targetOption);

    // Random spins between 3-8
    final spins = 3 + Random().nextInt(6);
    final finalAngle = _currentAngle + spins * 360 + targetAngle;

    _animation = Tween<double>(
      begin: _currentAngle,
      end: finalAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    ));

    _animation.addListener(() {
      setState(() {
        _currentAngle = _animation.value;
      });
    });

    _controller.forward(from: 0).then((_) {
      setState(() {
        _isSpinning = false;
      });
      _showResult(targetOption);
    });
  }

  WheelOption _selectOptionByWeight() {
    final totalWeight = _options.fold<double>(0, (sum, o) => sum + o.weight);
    final random = Random().nextDouble() * totalWeight;
    double currentWeight = 0;

    for (final option in _options) {
      currentWeight += option.weight;
      if (random <= currentWeight) return option;
    }
    return _options.last;
  }

  double _calculateTargetAngle(WheelOption targetOption) {
    final totalWeight = _options.fold<double>(0, (sum, o) => sum + o.weight);
    double currentAngle = 0;

    for (final option in _options) {
      final sweepAngle = (option.weight / totalWeight) * 360;
      if (option.id == targetOption.id) {
        // Return angle to center this option at top (270 degrees / -90 degrees)
        return 270 - (currentAngle + sweepAngle / 2);
      }
      currentAngle += sweepAngle;
    }
    return 0;
  }

  void _showResult(WheelOption option) {
    showDialog(
      context: context,
      builder: (context) => ResultDialog(
        option: option,
        onSpinAgain: _spin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // AppBar area
        AppBar(
          title: Text(widget.collection.name),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to collection edit
                Navigator.pushNamed(context, '/big_wheel/collection/edit',
                    arguments: widget.collection);
              },
            ),
          ],
        ),

        // Wheel area
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Wheel
                    RepaintBoundary(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: WheelPainter(
                          options: _options,
                          rotationAngle: _currentAngle,
                        ),
                      ),
                    ),

                    // Pointer (fixed at top)
                    Positioned(
                      top: 0,
                      child: const WheelPointer(size: 40),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Controls
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (_options.length < 2)
                const Text(
                  '请添加至少2个选项',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ElevatedButton.icon(
                  onPressed: _isSpinning ? null : _spin,
                  icon: _isSpinning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.rotate_right),
                  label: Text(_isSpinning ? '转动中...' : '开始转动'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/big_wheel/options',
                    arguments: widget.collection,
                  );
                },
                icon: const Icon(Icons.list),
                label: const Text('管理选项'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Create BigWheelPage (main page with PageView)**

```dart
// app/lib/tools/big_wheel/big_wheel_page.dart

import 'package:flutter/material.dart';
import 'big_wheel_view.dart';
import 'models/wheel_collection.dart';
import 'services/big_wheel_service.dart';
import 'pages/collection_list_page.dart';

class BigWheelPage extends StatefulWidget {
  const BigWheelPage({super.key});

  @override
  State<BigWheelPage> createState() => _BigWheelPageState();
}

class _BigWheelPageState extends State<BigWheelPage> {
  List<WheelCollection> _collections = [];
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCollections() async {
    final collections = await BigWheelService.getCollections();
    setState(() {
      _collections = collections;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_collections.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _collections.length,
        itemBuilder: (context, index) {
          return BigWheelView(collection: _collections[index]);
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'manage',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CollectionListPage(),
                ),
              );
              _loadCollections();
            },
            child: const Icon(Icons.folder_open),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CollectionListPage(),
                ),
              );
              _loadCollections();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigationBar: _buildPageIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rotate_right, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '暂无转盘',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CollectionListPage(),
                  ),
                );
                _loadCollections();
              },
              icon: const Icon(Icons.add),
              label: const Text('创建转盘'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _collections.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentIndex
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit pages**

```bash
git add app/lib/tools/big_wheel/big_wheel_page.dart app/lib/tools/big_wheel/big_wheel_view.dart
git commit -m "feat(big_wheel): add main page with PageView and wheel view"
```

---

## Task 7: Management Pages

**Files:**
- Create: `app/lib/tools/big_wheel/pages/collection_list_page.dart`
- Create: `app/lib/tools/big_wheel/pages/collection_edit_page.dart`
- Create: `app/lib/tools/big_wheel/pages/option_list_page.dart`
- Create: `app/lib/tools/big_wheel/pages/option_edit_page.dart`

- [ ] **Step 1: Create CollectionListPage**

```dart
// app/lib/tools/big_wheel/pages/collection_list_page.dart

import 'package:flutter/material.dart';
import '../models/wheel_collection.dart';
import '../services/big_wheel_service.dart';
import 'collection_edit_page.dart';

class CollectionListPage extends StatefulWidget {
  const CollectionListPage({super.key});

  @override
  State<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  List<WheelCollection> _collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final collections = await BigWheelService.getCollections();
    setState(() {
      _collections = collections;
    });
  }

  Future<void> _deleteCollection(WheelCollection collection) async {
    if (collection.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预设转盘不能删除')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${collection.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await BigWheelService.deleteCollection(collection.id!);
      _loadCollections();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('转盘管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CollectionEditPage(),
                ),
              );
              _loadCollections();
            },
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _collections.length,
        onReorder: (oldIndex, newIndex) async {
          if (newIndex > oldIndex) newIndex--;
          final item = _collections.removeAt(oldIndex);
          _collections.insert(newIndex, item);
          await BigWheelService.updateSortOrder(_collections);
          setState(() {});
        },
        itemBuilder: (context, index) {
          final collection = _collections[index];
          return _buildCollectionItem(collection);
        },
      ),
    );
  }

  Widget _buildCollectionItem(WheelCollection collection) {
    return Dismissible(
      key: Key('collection_${collection.id}'),
      direction: collection.isPreset
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteCollection(collection),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(collection.icon),
        ),
        title: Text(collection.name),
        subtitle: collection.isPreset ? const Text('预设') : null,
        trailing: const Icon(Icons.drag_handle),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollectionEditPage(
                collection: collection,
              ),
            ),
          );
          _loadCollections();
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Create CollectionEditPage**

```dart
// app/lib/tools/big_wheel/pages/collection_edit_page.dart

import 'package:flutter/material.dart';
import '../models/wheel_collection.dart';
import '../services/big_wheel_service.dart';
import 'option_list_page.dart';

class CollectionEditPage extends StatefulWidget {
  final WheelCollection? collection;

  const CollectionEditPage({super.key, this.collection});

  @override
  State<CollectionEditPage> createState() => _CollectionEditPageState();
}

class _CollectionEditPageState extends State<CollectionEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  bool _isEmoji = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.collection?.name ?? '',
    );
    _iconController = TextEditingController(
      text: widget.collection?.icon ?? '🎯',
    );
    _isEmoji = widget.collection?.iconType != IconType.material;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入转盘名称')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final collection = WheelCollection(
      id: widget.collection?.id,
      name: _nameController.text.trim(),
      icon: _iconController.text.trim(),
      iconType: _isEmoji ? IconType.emoji : IconType.material,
      isPreset: widget.collection?.isPreset ?? false,
      sortOrder: widget.collection?.sortOrder ?? 0,
    );

    await BigWheelService.saveCollection(collection);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.collection != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑转盘' : '新建转盘'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Icon selection
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Emoji')),
                    ButtonSegment(value: false, label: Text('图标')),
                  ],
                  selected: {_isEmoji},
                  onSelectionChanged: (value) {
                    setState(() {
                      _isEmoji = value.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _iconController.text,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Icon input
          TextField(
            controller: _iconController,
            decoration: const InputDecoration(
              labelText: '图标',
              hintText: '输入 Emoji 或图标名称',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Name input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '转盘名称',
              hintText: '例如：今天吃什么',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Manage options button (only when editing)
          if (isEditing)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OptionListPage(
                      collection: widget.collection!,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('管理选项'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create OptionListPage**

```dart
// app/lib/tools/big_wheel/pages/option_list_page.dart

import 'package:flutter/material.dart';
import '../models/wheel_collection.dart';
import '../models/wheel_option.dart';
import '../services/big_wheel_service.dart';
import 'option_edit_page.dart';

class OptionListPage extends StatefulWidget {
  final WheelCollection collection;

  const OptionListPage({super.key, required this.collection});

  @override
  State<OptionListPage> createState() => _OptionListPageState();
}

class _OptionListPageState extends State<OptionListPage> {
  List<WheelOption> _options = [];

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final options = await BigWheelService.getOptions(widget.collection.id!);
    setState(() {
      _options = options;
    });
  }

  Future<void> _deleteOption(WheelOption option) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${option.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await BigWheelService.deleteOption(option.id!);
      _loadOptions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.collection.name} - 选项管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OptionEditPage(
                    collectionId: widget.collection.id!,
                  ),
                ),
              );
              _loadOptions();
            },
          ),
        ],
      ),
      body: ReorderableListView.builder(
        itemCount: _options.length,
        onReorder: (oldIndex, newIndex) async {
          if (newIndex > oldIndex) newIndex--;
          final item = _options.removeAt(oldIndex);
          _options.insert(newIndex, item);
          await BigWheelService.updateOptionSortOrder(_options);
          setState(() {});
        },
        itemBuilder: (context, index) {
          final option = _options[index];
          return _buildOptionItem(option);
        },
      ),
    );
  }

  Widget _buildOptionItem(WheelOption option) {
    return Dismissible(
      key: Key('option_${option.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteOption(option),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(option.color),
          child: option.icon != null
              ? Text(option.icon!, style: const TextStyle(fontSize: 20))
              : null,
        ),
        title: Text(option.name),
        subtitle: option.weight != 1.0
            ? Text('权重: ${option.weight.toStringAsFixed(1)}')
            : null,
        trailing: const Icon(Icons.drag_handle),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OptionEditPage(
                collectionId: widget.collection.id!,
                option: option,
              ),
            ),
          );
          _loadOptions();
        },
      ),
    );
  }

  Color _parseColor(String? colorStr) {
    if (colorStr == null) return Colors.blue;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
```

- [ ] **Step 4: Create OptionEditPage**

```dart
// app/lib/tools/big_wheel/pages/option_edit_page.dart

import 'package:flutter/material.dart';
import '../models/wheel_option.dart';
import '../services/big_wheel_service.dart';

class OptionEditPage extends StatefulWidget {
  final int collectionId;
  final WheelOption? option;

  const OptionEditPage({
    super.key,
    required this.collectionId,
    this.option,
  });

  @override
  State<OptionEditPage> createState() => _OptionEditPageState();
}

class _OptionEditPageState extends State<OptionEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _iconController;
  late TextEditingController _weightController;
  bool _isEmoji = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.option?.name ?? '',
    );
    _iconController = TextEditingController(
      text: widget.option?.icon ?? '',
    );
    _weightController = TextEditingController(
      text: (widget.option?.weight ?? 1.0).toString(),
    );
    _isEmoji = widget.option?.iconType != IconType.material;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入选项名称')),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text) ?? 1.0;
    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('权重必须大于0')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final option = WheelOption(
      id: widget.option?.id,
      collectionId: widget.collectionId,
      name: _nameController.text.trim(),
      icon: _iconController.text.trim().isEmpty
          ? null
          : _iconController.text.trim(),
      iconType: _isEmoji ? IconType.emoji : IconType.material,
      weight: weight,
      color: widget.option?.color,
      sortOrder: widget.option?.sortOrder ?? 0,
    );

    await BigWheelService.saveOption(option);

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.option != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑选项' : '新建选项'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Icon selection
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Emoji')),
                    ButtonSegment(value: false, label: Text('图标')),
                  ],
                  selected: {_isEmoji},
                  onSelectionChanged: (value) {
                    setState(() {
                      _isEmoji = value.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _iconController.text.isEmpty ? '?' : _iconController.text,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Icon input
          TextField(
            controller: _iconController,
            decoration: const InputDecoration(
              labelText: '图标（可选）',
              hintText: '输入 Emoji 或图标名称',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Name input
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '选项名称',
              hintText: '例如：火锅',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Weight input
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: '权重',
              hintText: '默认 1.0，越大被选中的概率越高',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          const Text(
            '提示：权重越大，该选项被选中的概率越高。所有选项默认权重为1.0。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Commit management pages**

```bash
git add app/lib/tools/big_wheel/pages/
git commit -m "feat(big_wheel): add collection and option management pages"
```

---

## Task 8: Final Integration

**Files:**
- Test the complete feature
- Fix any navigation issues

- [ ] **Step 1: Fix navigation in BigWheelView**

The navigation to management pages needs to be updated to use MaterialPageRoute instead of named routes:

In `app/lib/tools/big_wheel/big_wheel_view.dart`, update the settings button onPressed:

```dart
IconButton(
  icon: const Icon(Icons.settings),
  onPressed: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CollectionEditPage(
          collection: widget.collection,
        ),
      ),
    );
    // Reload options after returning
    _loadOptions();
  },
),
```

Also update the "管理选项" button in the same file to navigate properly.

Add import at top:
```dart
import 'pages/collection_edit_page.dart';
import 'pages/option_list_page.dart';
```

Update the "管理选项" button:
```dart
TextButton.icon(
  onPressed: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OptionListPage(
          collection: widget.collection,
        ),
      ),
    );
    _loadOptions();
  },
  icon: const Icon(Icons.list),
  label: const Text('管理选项'),
),
```

- [ ] **Step 2: Test build**

```bash
cd app && flutter analyze
```

Expected: No errors

- [ ] **Step 3: Commit final fixes**

```bash
git add app/lib/tools/big_wheel/
git commit -m "fix(big_wheel): fix navigation routes in wheel view"
```

---

## Summary

After completing all tasks, you should have:

1. **Database**: wheel_collections and wheel_options tables (v7)
2. **Models**: WheelCollection, WheelOption with IconType enum
3. **Service**: BigWheelService with CRUD and preset initialization
4. **Tool**: BigWheelTool registered in main.dart
5. **Widgets**: WheelPainter, WheelPointer, ResultDialog
6. **Pages**: BigWheelPage, BigWheelView, and all management pages

**Testing Checklist:**
- [ ] App builds without errors
- [ ] Preset wheels appear on first run
- [ ] Can swipe between wheels
- [ ] Wheel spins with animation
- [ ] Result dialog shows correct option
- [ ] Can create new wheel collection
- [ ] Can add/edit/delete options
- [ ] Weight setting affects probability
- [ ] Can reorder collections and options
