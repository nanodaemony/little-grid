# 奶茶计划实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现奶茶计划功能，一个帮助用户追踪含糖饮料摄入习惯的日历工具

**Architecture：** 新增独立的 drink_plan 工具模块，包含数据模型、服务层、页面组件。使用 PageView 实现月视图滑动切换，年视图使用 GridView。数据存储使用 SQflite，复用 lunar 库计算农历。

**Tech Stack：** Flutter, Dart, sqflite, lunar, provider

---

## 文件结构映射

```
lib/tools/drink_plan/
├── drink_plan_tool.dart              # ToolModule 实现，注册到 ToolRegistry
├── models/
│   └── drink_record.dart             # DrinkRecord 数据模型
├── services/
│   └── drink_plan_service.dart       # 数据访问服务
├── pages/
│   ├── drink_plan_page.dart          # 主页面（月/年视图切换）
│   ├── day_detail_page.dart          # 日详情页
│   └── settings_page.dart            # 设置页
├── widgets/
│   ├── month_view.dart               # 月视图组件
│   ├── year_view.dart                # 年视图组件
│   ├── day_cell.dart                 # 日期单元格
│   ├── mark_selector.dart            # Emoji/图片选择器
│   └── health_tip_banner.dart        # 健康提示横幅
└── constants/
    └── health_tips.dart              # 健康提示文案

lib/core/services/database_service.dart  # 修改：添加数据库迁移
lib/main.dart                            # 修改：注册 DrinkPlanTool
```

---

## Task 1: 数据模型

**Files:**
- Create: `lib/tools/drink_plan/models/drink_record.dart`
- Test: `test/tools/drink_plan/models/drink_record_test.dart`

- [ ] **Step 1: 编写 DrinkRecord 模型测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/drink_plan/models/drink_record.dart';

void main() {
  group('DrinkRecord', () {
    test('should create DrinkRecord with all fields', () {
      final record = DrinkRecord(
        id: 1,
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime(2026, 3, 24, 10, 30),
        updatedAt: DateTime(2026, 3, 24, 10, 30),
      );

      expect(record.id, 1);
      expect(record.date, '2026-03-24');
      expect(record.mark, '🧋');
    });

    test('should convert to map correctly', () {
      final createdAt = DateTime(2026, 3, 24, 10, 30);
      final record = DrinkRecord(
        date: '2026-03-24',
        mark: 'asset:milk_tea',
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      final map = record.toMap();

      expect(map['date'], '2026-03-24');
      expect(map['mark'], 'asset:milk_tea');
      expect(map['created_at'], createdAt.millisecondsSinceEpoch);
    });

    test('should create from map correctly', () {
      final createdAt = DateTime(2026, 3, 24, 10, 30);
      final map = {
        'id': 1,
        'date': '2026-03-24',
        'mark': '🧋',
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': createdAt.millisecondsSinceEpoch,
      };

      final record = DrinkRecord.fromMap(map);

      expect(record.id, 1);
      expect(record.date, '2026-03-24');
      expect(record.mark, '🧋');
      expect(record.createdAt, createdAt);
    });

    test('should support copyWith', () {
      final record = DrinkRecord(
        id: 1,
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime(2026, 3, 24),
        updatedAt: DateTime(2026, 3, 24),
      );

      final updated = record.copyWith(mark: '☕');

      expect(updated.mark, '☕');
      expect(updated.date, record.date);
      expect(updated.id, record.id);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
cd /home/nano/littlegrid/.worktrees/feature-xxx/app
flutter test test/tools/drink_plan/models/drink_record_test.dart
```

Expected: FAIL - "Target of URI doesn't exist"

- [ ] **Step 3: 创建 DrinkRecord 模型**

```dart
// lib/tools/drink_plan/models/drink_record.dart

class DrinkRecord {
  final int? id;
  final String date;
  final String mark;
  final DateTime createdAt;
  final DateTime updatedAt;

  DrinkRecord({
    this.id,
    required this.date,
    required this.mark,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mark': mark,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DrinkRecord.fromMap(Map<String, dynamic> map) {
    return DrinkRecord(
      id: map['id'],
      date: map['date'],
      mark: map['mark'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  DrinkRecord copyWith({
    int? id,
    String? date,
    String? mark,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DrinkRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      mark: mark ?? this.mark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

```bash
flutter test test/tools/drink_plan/models/drink_record_test.dart
```

Expected: PASS - All tests passed

- [ ] **Step 5: 提交**

```bash
git add lib/tools/drink_plan/models/drink_record.dart test/tools/drink_plan/models/drink_record_test.dart
git commit -m "feat(drink_plan): add DrinkRecord model with tests

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: 数据库迁移

**Files:**
- Modify: `lib/core/services/database_service.dart`

- [ ] **Step 1: 更新数据库版本号**

修改 `lib/core/constants/app_constants.dart` 中的 `dbVersion`：

```dart
// lib/core/constants/app_constants.dart
static const int dbVersion = 6;  // 从 5 改为 6
```

- [ ] **Step 2: 添加数据库迁移代码**

在 `DatabaseService._onUpgrade` 方法中添加：

```dart
if (oldVersion < 6) {
  // 奶茶计划记录表
  await db.execute('''
    CREATE TABLE drink_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL UNIQUE,
      mark TEXT NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
  await db.execute('CREATE INDEX idx_drink_records_date ON drink_records(date)');

  // 奶茶计划设置表
  await db.execute('''
    CREATE TABLE drink_plan_settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');

  AppLogger.i('Added drink_plan tables');
}
```

- [ ] **Step 3: 验证代码编译**

```bash
flutter analyze lib/core/services/database_service.dart
```

Expected: No issues found

- [ ] **Step 4: 提交**

```bash
git add lib/core/services/database_service.dart lib/core/constants/app_constants.dart
git commit -m "feat(drink_plan): add database migration for drink records and settings

- Create drink_records table with UNIQUE constraint on date
- Create drink_plan_settings table for user preferences
- Update dbVersion to 6

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 数据服务层

**Files:**
- Create: `lib/tools/drink_plan/services/drink_plan_service.dart`
- Test: `test/tools/drink_plan/services/drink_plan_service_test.dart`

- [ ] **Step 1: 编写 DrinkPlanService 测试**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/drink_plan/services/drink_plan_service.dart';
import 'package:app/tools/drink_plan/models/drink_record.dart';
import 'package:app/core/services/database_service.dart';

void main() {
  group('DrinkPlanService', () {
    setUpAll(() async {
      await DatabaseService.database;
    });

    tearDown(() async {
      final db = await DatabaseService.database;
      await db.delete('drink_records');
      await db.delete('drink_plan_settings');
    });

    test('should add and retrieve record', () async {
      final record = DrinkRecord(
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DrinkPlanService.addRecord(record);
      final retrieved = await DrinkPlanService.getRecordByDate('2026-03-24');

      expect(retrieved, isNotNull);
      expect(retrieved!.mark, '🧋');
    });

    test('should get records by month', () async {
      await DrinkPlanService.addRecord(DrinkRecord(
        date: '2026-03-01',
        mark: '🧋',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await DrinkPlanService.addRecord(DrinkRecord(
        date: '2026-03-15',
        mark: '☕',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final records = await DrinkPlanService.getRecordsByMonth(2026, 3);

      expect(records.length, 2);
    });

    test('should delete record', () async {
      await DrinkPlanService.addRecord(DrinkRecord(
        date: '2026-03-24',
        mark: '🧋',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await DrinkPlanService.deleteRecord('2026-03-24');
      final retrieved = await DrinkPlanService.getRecordByDate('2026-03-24');

      expect(retrieved, isNull);
    });

    test('should save and retrieve settings', () async {
      await DrinkPlanService.saveSettings(0.5);
      final opacity = await DrinkPlanService.getBackgroundOpacity();

      expect(opacity, 0.5);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

```bash
flutter test test/tools/drink_plan/services/drink_plan_service_test.dart
```

Expected: FAIL - Target of URI doesn't exist

- [ ] **Step 3: 实现 DrinkPlanService**

```dart
// lib/tools/drink_plan/services/drink_plan_service.dart

import 'package:sqflite/sqflite.dart';
import '../../../core/services/database_service.dart';
import '../models/drink_record.dart';

class DrinkPlanService {
  static const String _tableRecords = 'drink_records';
  static const String _tableSettings = 'drink_plan_settings';

  /// 获取指定月份的所有记录
  static Future<List<DrinkRecord>> getRecordsByMonth(int year, int month) async {
    final db = await DatabaseService.database;
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = '$year-${month.toString().padLeft(2, '0')}-31';

    final maps = await db.query(
      _tableRecords,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC',
    );

    return maps.map((map) => DrinkRecord.fromMap(map)).toList();
  }

  /// 获取单条记录
  static Future<DrinkRecord?> getRecordByDate(String date) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableRecords,
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return DrinkRecord.fromMap(maps.first);
  }

  /// 添加记录（同一日期会覆盖）
  static Future<void> addRecord(DrinkRecord record) async {
    final db = await DatabaseService.database;
    await db.insert(
      _tableRecords,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 删除记录
  static Future<void> deleteRecord(String date) async {
    final db = await DatabaseService.database;
    await db.delete(
      _tableRecords,
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  /// 获取指定年月已标记的日期列表
  static Future<Set<String>> getMarkedDates(int year, int month) async {
    final records = await getRecordsByMonth(year, month);
    return records.map((r) => r.date).toSet();
  }

  /// 获取背景透明度设置（默认 0.3）
  static Future<double> getBackgroundOpacity() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      _tableSettings,
      where: 'key = ?',
      whereArgs: ['background_opacity'],
      limit: 1,
    );

    if (maps.isEmpty) return 0.3;
    return double.tryParse(maps.first['value'] as String? ?? '0.3') ?? 0.3;
  }

  /// 保存背景透明度设置
  static Future<void> saveSettings(double opacity) async {
    final db = await DatabaseService.database;
    await db.insert(
      _tableSettings,
      {'key': 'background_opacity', 'value': opacity.toString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

```bash
flutter test test/tools/drink_plan/services/drink_plan_service_test.dart
```

Expected: PASS - All tests passed

- [ ] **Step 5: 提交**

```bash
git add lib/tools/drink_plan/services/drink_plan_service.dart test/tools/drink_plan/services/drink_plan_service_test.dart
git commit -m "feat(drink_plan): add DrinkPlanService with CRUD operations

- Add getRecordsByMonth, getRecordByDate, addRecord, deleteRecord
- Add getMarkedDates for efficient calendar rendering
- Add settings management for background opacity
- Include comprehensive tests

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 健康提示常量

**Files:**
- Create: `lib/tools/drink_plan/constants/health_tips.dart`

- [ ] **Step 1: 创建健康提示常量文件**

```dart
// lib/tools/drink_plan/constants/health_tips.dart

import 'dart:math';

class HealthTips {
  static const List<String> tips = [
    '🥤 你看看你现在多少斤了，还在喝？',
    '☕ 今天的咖啡因摄入已超标，小心失眠哦',
    '🧋 奶茶虽好，可不要贪杯哦',
    '🍬 这杯糖的甜度，够你跑3公里了',
    '💪 放下饮料，拿起水杯，你可以的！',
    '🦷 想想你的牙齿，它们正在哭泣',
    '💰 这杯奶茶钱，够买两斤水果了',
    '🏃‍♀️ 喝前想一想，今天的运动白做了吗？',
    '🍎 不如来杯鲜榨果汁？',
    '😴 糖分会让你更疲惫，真的需要吗？',
    '🌊 多喝水，皮肤会更好哦',
    '🎯 小目标：今天只喝一杯！',
  ];

  static final Random _random = Random();

  /// 获取随机提示
  static String getRandomTip() {
    return tips[_random.nextInt(tips.length)];
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/constants/health_tips.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/constants/health_tips.dart
git commit -m "feat(drink_plan): add health tips constants

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: 日期单元格组件

**Files:**
- Create: `lib/tools/drink_plan/widgets/day_cell.dart`

- [ ] **Step 1: 创建 DayCell 组件**

```dart
// lib/tools/drink_plan/widgets/day_cell.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

class DayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isWeekend;
  final String? mark;
  final double backgroundOpacity;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const DayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isWeekend,
    this.mark,
    this.backgroundOpacity = 0.5,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : null,
          shape: BoxShape.circle,
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景图/Emoji
            if (mark != null && !isSelected)
              _buildBackground(),
            // 日期数字
            Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isWeekend
                          ? AppColors.error
                          : AppColors.textPrimary,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final isAsset = mark!.startsWith('asset:');

    if (isAsset) {
      // 图片资源
      final assetName = mark!.substring(6);
      return Opacity(
        opacity: backgroundOpacity,
        child: ClipOval(
          child: Image.asset(
            'assets/drink_plan/$assetName.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      );
    } else {
      // Emoji - 放大显示作为背景
      return Center(
        child: Opacity(
          opacity: backgroundOpacity,
          child: Text(
            mark!,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      );
    }
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/widgets/day_cell.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/widgets/day_cell.dart
git commit -m "feat(drink_plan): add DayCell widget

- Support emoji and asset image backgrounds
- Configurable background opacity
- Today/selected/weekend state styling

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: 月视图组件

**Files:**
- Create: `lib/tools/drink_plan/widgets/month_view.dart`

- [ ] **Step 1: 创建 MonthView 组件**

```dart
// lib/tools/drink_plan/widgets/month_view.dart

import 'package:flutter/material.dart';
import '../services/drink_plan_service.dart';
import 'day_cell.dart';

class MonthView extends StatefulWidget {
  final DateTime month;
  final DateTime? selectedDate;
  final double backgroundOpacity;
  final Function(DateTime) onDateSelected;
  final Function(DateTime)? onDateLongPress;

  const MonthView({
    super.key,
    required this.month,
    this.selectedDate,
    required this.backgroundOpacity,
    required this.onDateSelected,
    this.onDateLongPress,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  Map<String, String> _marks = {};

  @override
  void initState() {
    super.initState();
    _loadMarks();
  }

  @override
  void didUpdateWidget(MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month) {
      _loadMarks();
    }
  }

  Future<void> _loadMarks() async {
    final records = await DrinkPlanService.getRecordsByMonth(
      widget.month.year,
      widget.month.month,
    );
    final marks = <String, String>{};
    for (final record in records) {
      marks[record.date] = record.mark;
    }
    if (mounted) {
      setState(() {
        _marks = marks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(widget.month.year, widget.month.month, 1);
    final lastDayOfMonth = DateTime(widget.month.year, widget.month.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday;

    final days = <Widget>[];

    // 填充月初空白
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // 填充日期
    final today = DateTime.now();
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(widget.month.year, widget.month.month, day);
      final dateStr = _formatDate(date);
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      final isSelected = widget.selectedDate != null &&
          date.year == widget.selectedDate!.year &&
          date.month == widget.selectedDate!.month &&
          date.day == widget.selectedDate!.day;
      final isWeekend = date.weekday == 6 || date.weekday == 7;

      days.add(DayCell(
        date: date,
        isToday: isToday,
        isSelected: isSelected,
        isWeekend: isWeekend,
        mark: _marks[dateStr],
        backgroundOpacity: widget.backgroundOpacity,
        onTap: () => widget.onDateSelected(date),
        onLongPress: _marks[dateStr] != null
            ? () => widget.onDateLongPress?.call(date)
            : null,
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/widgets/month_view.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/widgets/month_view.dart
git commit -m "feat(drink_plan): add MonthView widget

- Display month grid with 7 columns
- Load marks from database
- Support date selection and long press
- Auto-refresh when month changes

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: 年视图组件

**Files:**
- Create: `lib/tools/drink_plan/widgets/year_view.dart`

- [ ] **Step 1: 创建 YearView 组件**

```dart
// lib/tools/drink_plan/widgets/year_view.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../services/drink_plan_service.dart';

class YearView extends StatelessWidget {
  final int year;
  final Function(int year, int month) onMonthSelected;

  const YearView({
    super.key,
    required this.year,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16),
      childAspectRatio: 1.2,
      children: List.generate(12, (index) {
        final month = index + 1;
        return _MonthPreview(
          year: year,
          month: month,
          onTap: () => onMonthSelected(year, month),
        );
      }),
    );
  }
}

class _MonthPreview extends StatefulWidget {
  final int year;
  final int month;
  final VoidCallback onTap;

  const _MonthPreview({
    required this.year,
    required this.month,
    required this.onTap,
  });

  @override
  State<_MonthPreview> createState() => _MonthPreviewState();
}

class _MonthPreviewState extends State<_MonthPreview> {
  int _markedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final records = await DrinkPlanService.getRecordsByMonth(
      widget.year,
      widget.month,
    );
    if (mounted) {
      setState(() {
        _markedCount = records.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = ['1月', '2月', '3月', '4月', '5月', '6月',
                       '7月', '8月', '9月', '10月', '11月', '12月'];

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                monthNames[widget.month - 1],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_markedCount > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_drink,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_markedCount天',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '无记录',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/widgets/year_view.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/widgets/year_view.dart
git commit -m "feat(drink_plan): add YearView widget

- Display 12 months in 3x4 grid
- Show marked days count per month
- Tap to navigate to month view

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: 健康提示横幅组件

**Files:**
- Create: `lib/tools/drink_plan/widgets/health_tip_banner.dart`

- [ ] **Step 1: 创建 HealthTipBanner 组件**

```dart
// lib/tools/drink_plan/widgets/health_tip_banner.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../constants/health_tips.dart';

class HealthTipBanner extends StatelessWidget {
  const HealthTipBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        HealthTips.getRandomTip(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/widgets/health_tip_banner.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/widgets/health_tip_banner.dart
git commit -m "feat(drink_plan): add HealthTipBanner widget

- Display random health tip from constants
- Styled with primary light background

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 9: 标记选择器组件

**Files:**
- Create: `lib/tools/drink_plan/widgets/mark_selector.dart`

- [ ] **Step 1: 创建 MarkSelector 组件**

```dart
// lib/tools/drink_plan/widgets/mark_selector.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

class MarkSelector extends StatelessWidget {
  final String? selectedMark;
  final Function(String) onMarkSelected;

  const MarkSelector({
    super.key,
    this.selectedMark,
    required this.onMarkSelected,
  });

  // 预设 Emoji 列表
  static const List<String> _emojis = [
    '🧋', '☕', '🥤', '🍵', '🍺',
    '🍷', '🥃', '🧃', '🥛', '💧',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择标记',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _emojis.map((emoji) {
            final isSelected = selectedMark == emoji;
            return GestureDetector(
              onTap: () => onMarkSelected(emoji),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        const Text(
          '自定义图片（后续支持）',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/widgets/mark_selector.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/widgets/mark_selector.dart
git commit -m "feat(drink_plan): add MarkSelector widget

- Grid of preset emojis for drink marking
- Visual selection state with primary color border
- Placeholder for custom images

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 10: 设置页面

**Files:**
- Create: `lib/tools/drink_plan/pages/settings_page.dart`

- [ ] **Step 1: 创建设置页面**

```dart
// lib/tools/drink_plan/pages/settings_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../services/drink_plan_service.dart';

class DrinkPlanSettingsPage extends StatefulWidget {
  const DrinkPlanSettingsPage({super.key});

  @override
  State<DrinkPlanSettingsPage> createState() => _DrinkPlanSettingsPageState();
}

class _DrinkPlanSettingsPageState extends State<DrinkPlanSettingsPage> {
  double _opacity = 0.5;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final opacity = await DrinkPlanService.getBackgroundOpacity();
    if (mounted) {
      setState(() {
        _opacity = opacity;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOpacity(double opacity) async {
    await DrinkPlanService.saveSettings(opacity);
    if (mounted) {
      setState(() {
        _opacity = opacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '背景透明度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '调整日期单元格背景图的透明程度',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _OpacityOption(
                  label: '100%（不透明）',
                  value: 1.0,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                _OpacityOption(
                  label: '75%（轻微透明）',
                  value: 0.75,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                _OpacityOption(
                  label: '50%（半透明）',
                  value: 0.5,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                _OpacityOption(
                  label: '25%（高度透明）',
                  value: 0.25,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                const SizedBox(height: 24),
                // 预览
                const Text(
                  '预览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: _opacity,
                          child: const Center(
                            child: Text(
                              '🧋',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            '24',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _OpacityOption extends StatelessWidget {
  final String label;
  final double value;
  final double currentValue;
  final Function(double) onSelected;

  const _OpacityOption({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = (currentValue - value).abs() < 0.01;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () => onSelected(value),
    );
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/pages/settings_page.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/pages/settings_page.dart
git commit -m "feat(drink_plan): add settings page

- Background opacity options (100%, 75%, 50%, 25%)
- Real-time preview of selected opacity
- Persist settings to database

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 11: 日详情页面

**Files:**
- Create: `lib/tools/drink_plan/pages/day_detail_page.dart`

- [ ] **Step 1: 创建日详情页面**

```dart
// lib/tools/drink_plan/pages/day_detail_page.dart

import 'package:flutter/material.dart';
import 'package:lunar/lunar.dart';
import '../../../core/ui/app_colors.dart';
import '../models/drink_record.dart';
import '../services/drink_plan_service.dart';
import '../widgets/mark_selector.dart';

class DayDetailPage extends StatefulWidget {
  final DateTime date;

  const DayDetailPage({
    super.key,
    required this.date,
  });

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  DrinkRecord? _record;
  bool _isLoading = true;
  int _monthlyCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dateStr = _formatDate(widget.date);
    final record = await DrinkPlanService.getRecordByDate(dateStr);
    final monthlyRecords = await DrinkPlanService.getRecordsByMonth(
      widget.date.year,
      widget.date.month,
    );

    if (mounted) {
      setState(() {
        _record = record;
        _monthlyCount = monthlyRecords.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _onMarkSelected(String mark) async {
    final dateStr = _formatDate(widget.date);
    final record = DrinkRecord(
      date: dateStr,
      mark: mark,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await DrinkPlanService.addRecord(record);
    Navigator.pop(context, true);
  }

  Future<void> _deleteRecord() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dateStr = _formatDate(widget.date);
      await DrinkPlanService.deleteRecord(dateStr);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lunar = Lunar.fromDate(widget.date);
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录详情'),
        actions: [
          if (_record != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteRecord,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 日期信息卡片
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${widget.date.month}月${widget.date.day}日',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.date.year}年 ${weekdays[widget.date.weekday - 1]}',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '农历 ${lunar.getMonthInChinese()}${lunar.getDayInChinese()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          if (lunar.getJieQi() != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              lunar.getJieQi()!,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 本月统计
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                      ),
                      title: const Text('本月已记录'),
                      trailing: Text(
                        '$_monthlyCount天',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 标记选择
                  MarkSelector(
                    selectedMark: _record?.mark,
                    onMarkSelected: _onMarkSelected,
                  ),
                ],
              ),
            ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/pages/day_detail_page.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/pages/day_detail_page.dart
git commit -m "feat(drink_plan): add day detail page

- Display date, weekday, lunar calendar
- Show monthly statistics
- Mark selector for adding/updating records
- Delete record functionality

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 12: 主页面

**Files:**
- Create: `lib/tools/drink_plan/pages/drink_plan_page.dart`

- [ ] **Step 1: 创建主页面**

```dart
// lib/tools/drink_plan/pages/drink_plan_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../services/drink_plan_service.dart';
import '../widgets/health_tip_banner.dart';
import '../widgets/month_view.dart';
import '../widgets/year_view.dart';
import 'day_detail_page.dart';
import 'settings_page.dart';

class DrinkPlanPage extends StatefulWidget {
  const DrinkPlanPage({super.key});

  @override
  State<DrinkPlanPage> createState() => _DrinkPlanPageState();
}

class _DrinkPlanPageState extends State<DrinkPlanPage> {
  bool _isMonthView = true;
  DateTime _currentMonth = DateTime.now();
  int _currentYear = DateTime.now().year;
  DateTime? _selectedDate;
  double _backgroundOpacity = 0.5;

  static const int _initialPage = 1200;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _pageController = PageController(initialPage: _initialPage);
    _loadSettings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final opacity = await DrinkPlanService.getBackgroundOpacity();
    if (mounted) {
      setState(() {
        _backgroundOpacity = opacity;
      });
    }
  }

  void _onPageChanged(int page) {
    final monthOffset = page - _initialPage;
    final newMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month + monthOffset,
      1,
    );
    setState(() {
      _currentMonth = newMonth;
    });
  }

  DateTime _getMonthFromPageIndex(int index) {
    final monthOffset = index - _initialPage;
    return DateTime(
      DateTime.now().year,
      DateTime.now().month + monthOffset,
      1,
    );
  }

  Future<void> _onDateSelected(DateTime date) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DayDetailPage(date: date),
      ),
    );

    if (result == true) {
      // 刷新当前视图
      setState(() {});
    }
  }

  Future<void> _onDateLongPress(DateTime date) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除标记'),
        content: const Text('确定要删除这天的记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DrinkPlanService.deleteRecord(dateStr);
      setState(() {});
    }
  }

  void _onMonthSelected(int year, int month) {
    final now = DateTime.now();
    final monthOffset = (year - now.year) * 12 + (month - now.month);
    final page = _initialPage + monthOffset;

    _pageController.jumpToPage(page);
    setState(() {
      _isMonthView = true;
      _currentMonth = DateTime(year, month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('奶茶计划'),
        actions: [
          // 视图切换按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('月视图'),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('年视图'),
                ),
              ],
              selected: {_isMonthView},
              onSelectionChanged: (Set<bool> selected) {
                setState(() {
                  _isMonthView = selected.first;
                });
              },
            ),
          ),
          // 设置按钮
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrinkPlanSettingsPage(),
                ),
              );
              // 返回后刷新设置
              _loadSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 健康提示横幅
          const HealthTipBanner(),

          // 月份/年份标题
          if (_isMonthView)
            _buildMonthHeader()
          else
            _buildYearHeader(),

          // 星期标题（仅月视图）
          if (_isMonthView) _buildWeekdayHeader(),

          // 视图内容
          Expanded(
            child: _isMonthView ? _buildMonthView() : _buildYearView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Text(
            '${_currentMonth.year}年${_currentMonth.month}月',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildYearHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentYear--;
              });
            },
          ),
          Text(
            '$_currentYear年',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentYear++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
      ),
      child: Row(
        children: weekdays.map((day) {
          final isWeekend = day == '六' || day == '日';
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color:
                      isWeekend ? AppColors.error : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _initialPage * 2,
      itemBuilder: (context, index) {
        final month = _getMonthFromPageIndex(index);
        return MonthView(
          month: month,
          selectedDate: _selectedDate,
          backgroundOpacity: _backgroundOpacity,
          onDateSelected: _onDateSelected,
          onDateLongPress: _onDateLongPress,
        );
      },
    );
  }

  Widget _buildYearView() {
    return YearView(
      year: _currentYear,
      onMonthSelected: _onMonthSelected,
    );
  }
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/pages/drink_plan_page.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/pages/drink_plan_page.dart
git commit -m "feat(drink_plan): add main drink plan page

- Month/year view toggle with SegmentedButton
- Swipe to switch months in month view
- Health tip banner at top
- Settings button for opacity configuration
- Navigation to day detail and settings pages

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 13: ToolModule 实现

**Files:**
- Create: `lib/tools/drink_plan/drink_plan_tool.dart`

- [ ] **Step 1: 创建 DrinkPlanTool**

```dart
// lib/tools/drink_plan/drink_plan_tool.dart

import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'pages/drink_plan_page.dart';

class DrinkPlanTool implements ToolModule {
  @override
  String get id => 'drink_plan';

  @override
  String get name => '奶茶计划';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.local_drink;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const DrinkPlanPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/tools/drink_plan/drink_plan_tool.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/tools/drink_plan/drink_plan_tool.dart
git commit -m "feat(drink_plan): add DrinkPlanTool module

- Implement ToolModule interface
- Configure as life category tool with gridSize 2
- Icon: local_drink

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 14: 注册工具

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: 导入并注册 DrinkPlanTool**

在 `lib/main.dart` 中找到 `ToolRegistry.registerAll` 调用，添加 `DrinkPlanTool`：

```dart
// 添加导入
import 'tools/drink_plan/drink_plan_tool.dart';

// 在 ToolRegistry.registerAll 中添加
ToolRegistry.registerAll([
  // ... 现有工具
  DrinkPlanTool(),
]);
```

- [ ] **Step 2: 验证代码编译**

```bash
flutter analyze lib/main.dart
```

Expected: No issues found

- [ ] **Step 3: 提交**

```bash
git add lib/main.dart
git commit -m "feat(drink_plan): register DrinkPlanTool in app

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 15: 集成测试

**Files:**
- Create: `test/tools/drink_plan/drink_plan_integration_test.dart`

- [ ] **Step 1: 创建集成测试**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/drink_plan/drink_plan_tool.dart';
import 'package:app/tools/drink_plan/pages/drink_plan_page.dart';

void main() {
  group('DrinkPlan Integration', () {
    testWidgets('should display tool page', (WidgetTester tester) async {
      final tool = DrinkPlanTool();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => tool.buildPage(context),
          ),
        ),
      );

      // 等待页面加载
      await tester.pumpAndSettle();

      // 验证页面标题
      expect(find.text('奶茶计划'), findsOneWidget);
    });

    test('should have correct tool metadata', () {
      final tool = DrinkPlanTool();

      expect(tool.id, 'drink_plan');
      expect(tool.name, '奶茶计划');
      expect(tool.category, ToolCategory.life);
      expect(tool.gridSize, 2);
    });
  });
}
```

- [ ] **Step 2: 运行集成测试**

```bash
flutter test test/tools/drink_plan/drink_plan_integration_test.dart
```

Expected: PASS - All tests passed

- [ ] **Step 3: 提交**

```bash
git add test/tools/drink_plan/drink_plan_integration_test.dart
git commit -m "test(drink_plan): add integration tests

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## 完成清单

- [x] DrinkRecord 数据模型及测试
- [x] 数据库迁移（drink_records 和 drink_plan_settings 表）
- [x] DrinkPlanService 数据服务层及测试
- [x] 健康提示常量
- [x] DayCell 日期单元格组件
- [x] MonthView 月视图组件
- [x] YearView 年视图组件
- [x] HealthTipBanner 健康提示横幅
- [x] MarkSelector 标记选择器
- [x] SettingsPage 设置页面
- [x] DayDetailPage 日详情页面
- [x] DrinkPlanPage 主页面
- [x] DrinkPlanTool ToolModule 实现
- [x] 在 main.dart 中注册工具
- [x] 集成测试

---

**Plan completed at:** 2026-03-24
