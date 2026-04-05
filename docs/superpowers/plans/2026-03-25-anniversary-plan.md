# 纪念日功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现纪念日功能格子，支持纪念日和倒数日两种类型，可按年/月/周循环，首页混合展示并按紧急程度排序。

**Architecture:** 采用基类+子类设计模式，`AnniversaryBase` 为抽象基类，`AnniversaryItem` 和 `CountdownItem` 为具体实现。数据持久化使用 sqflite，UI 采用网格+卡片列表布局，重要条目使用大卡片展示。

**Tech Stack:** Flutter, Dart, sqflite

---

## 文件结构

### 新建文件
- `lib/tools/anniversary/models/anniversary_models.dart` - 数据模型（枚举、基类、子类、显示数据）
- `lib/tools/anniversary/services/anniversary_service.dart` - 数据库服务（CRUD 操作）
- `lib/tools/anniversary/widgets/anniversary_card.dart` - 小卡片组件
- `lib/tools/anniversary/widgets/anniversary_card_large.dart` - 大卡片组件
- `lib/tools/anniversary/widgets/anniversary_dialog.dart` - 添加/编辑弹窗
- `lib/tools/anniversary/anniversary_page.dart` - 主页面
- `lib/tools/anniversary/anniversary_tool.dart` - ToolModule 实现

### 修改文件
- `lib/core/services/database_service.dart` - 添加 anniversary_items 表创建
- `lib/main.dart` - 注册 AnniversaryTool

---

## 任务列表

### Task 1: 创建数据模型

**Files:**
- Create: `lib/tools/anniversary/models/anniversary_models.dart`

**Dependencies:** None

- [ ] **Step 1.1: 编写枚举类型**

```dart
enum AnniversaryType {
  anniversary,
  countdown,
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}
```

- [ ] **Step 1.2: 编写显示数据类**

```dart
class AnniversaryDisplayData {
  final int primaryNumber;
  final String primaryLabel;
  final String? secondaryText;

  AnniversaryDisplayData({
    required this.primaryNumber,
    required this.primaryLabel,
    this.secondaryText,
  });
}
```

- [ ] **Step 1.3: 编写抽象基类**

```dart
import 'package:flutter/material.dart';

abstract class AnniversaryBase {
  final int? id;
  final String title;
  final DateTime targetDate;
  final AnniversaryType type;
  final RepeatType repeatType;
  final String? notes;
  final int iconColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnniversaryBase({
    this.id,
    required this.title,
    required this.targetDate,
    required this.type,
    required this.repeatType,
    this.notes,
    required this.iconColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  AnniversaryDisplayData calculateDisplay();

  Map<String, dynamic> toMap();
}
```

- [ ] **Step 1.4: 编写 AnniversaryItem 类**

```dart
class AnniversaryItem extends AnniversaryBase {
  AnniversaryItem({
    super.id,
    required super.title,
    required super.targetDate,
    required super.repeatType,
    super.notes,
    required super.iconColor,
    super.createdAt,
    super.updatedAt,
  }) : super(type: AnniversaryType.anniversary);

  @override
  AnniversaryDisplayData calculateDisplay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (repeatType == RepeatType.none) {
      final daysPassed = today.difference(targetDate).inDays;
      return AnniversaryDisplayData(
        primaryNumber: daysPassed.abs(),
        primaryLabel: daysPassed >= 0 ? '天已过' : '天后',
        secondaryText: null,
      );
    } else {
      final nextDate = _calculateNextDate(today, targetDate, repeatType);
      final daysUntil = nextDate.difference(today).inDays;
      return AnniversaryDisplayData(
        primaryNumber: daysUntil,
        primaryLabel: '天后',
        secondaryText: '${nextDate.year}年${nextDate.month}月${nextDate.day}日',
      );
    }
  }

  DateTime _calculateNextDate(DateTime today, DateTime targetDate, RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.daily:
        return today.add(const Duration(days: 1));

      case RepeatType.weekly:
        final targetWeekday = targetDate.weekday;
        final todayWeekday = today.weekday;
        int daysToAdd = targetWeekday - todayWeekday;
        if (daysToAdd <= 0) {
          daysToAdd += 7;
        }
        return today.add(Duration(days: daysToAdd));

      case RepeatType.monthly:
        int targetYear = today.year;
        int targetMonth = today.month;
        int targetDay = targetDate.day;

        DateTime candidate = DateTime(targetYear, targetMonth, targetDay);

        if (candidate.isBefore(today) || candidate.day != targetDay) {
          targetMonth++;
          if (targetMonth > 12) {
            targetMonth = 1;
            targetYear++;
          }
          candidate = DateTime(targetYear, targetMonth, 1);
          final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
          candidate = DateTime(targetYear, targetMonth,
              targetDay > lastDayOfMonth ? lastDayOfMonth : targetDay);
        }
        return candidate;

      case RepeatType.yearly:
        int targetYear = today.year;
        int targetMonth = targetDate.month;
        int targetDay = targetDate.day;

        DateTime candidate = DateTime(targetYear, targetMonth, targetDay);

        if (targetMonth == 2 && targetDay == 29) {
          if (!_isLeapYear(targetYear)) {
            candidate = DateTime(targetYear, 2, 28);
          }
        }

        if (candidate.isBefore(today)) {
          targetYear++;
          candidate = DateTime(targetYear, targetMonth, targetDay);
          if (targetMonth == 2 && targetDay == 29 && !_isLeapYear(targetYear)) {
            candidate = DateTime(targetYear, 2, 28);
          }
        }
        return candidate;

      default:
        return targetDate;
    }
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  factory AnniversaryItem.fromMap(Map<String, dynamic> map) {
    return AnniversaryItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int),
      repeatType: RepeatType.values[map['repeat_type'] as int],
      notes: map['notes'] as String?,
      iconColor: map['icon_color'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_date': targetDate.millisecondsSinceEpoch,
      'type': type.index,
      'repeat_type': repeatType.index,
      'notes': notes,
      'icon_color': iconColor,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
```

- [ ] **Step 1.5: 编写 CountdownItem 类**

```dart
class CountdownItem extends AnniversaryBase {
  CountdownItem({
    super.id,
    required super.title,
    required super.targetDate,
    super.notes,
    required super.iconColor,
    super.createdAt,
    super.updatedAt,
  }) : super(type: AnniversaryType.countdown, repeatType: RepeatType.none);

  @override
  AnniversaryDisplayData calculateDisplay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysUntil = targetDate.difference(today).inDays;

    return AnniversaryDisplayData(
      primaryNumber: daysUntil,
      primaryLabel: '天后',
      secondaryText: null,
    );
  }

  factory CountdownItem.fromMap(Map<String, dynamic> map) {
    return CountdownItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int),
      notes: map['notes'] as String?,
      iconColor: map['icon_color'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_date': targetDate.millisecondsSinceEpoch,
      'type': type.index,
      'repeat_type': repeatType.index,
      'notes': notes,
      'icon_color': iconColor,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}
```

- [ ] **Step 1.6: 添加反序列化辅助函数**

```dart
AnniversaryBase anniversaryFromMap(Map<String, dynamic> map) {
  final type = AnniversaryType.values[map['type'] as int];
  switch (type) {
    case AnniversaryType.anniversary:
      return AnniversaryItem.fromMap(map);
    case AnniversaryType.countdown:
      return CountdownItem.fromMap(map);
  }
}
```

- [ ] **Step 1.7: 提交**

```bash
git add lib/tools/anniversary/models/
git commit -m "feat(anniversary): 添加数据模型"
```

---

### Task 2: 添加数据库表

**Files:**
- Modify: `lib/core/services/database_service.dart`

**Dependencies:** Task 1

- [ ] **Step 2.1: 在 onCreate 中添加 anniversary_items 表**

找到 `onCreate` 方法中的 `CREATE TABLE` 语句，在最后一个表创建之后添加：

```dart
// anniversary_items 表
await db.execute('''
  CREATE TABLE anniversary_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    target_date INTEGER NOT NULL,
    type INTEGER NOT NULL,
    repeat_type INTEGER NOT NULL,
    notes TEXT,
    icon_color INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''');
```

- [ ] **Step 2.2: 提交**

```bash
git add lib/core/services/database_service.dart
git commit -m "feat(database): 添加 anniversary_items 表"
```

---

### Task 3: 创建数据服务

**Files:**
- Create: `lib/tools/anniversary/services/anniversary_service.dart`

**Dependencies:** Task 1, Task 2

- [ ] **Step 3.1: 编写 AnniversaryService**

```dart
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
```

- [ ] **Step 3.2: 提交**

```bash
git add lib/tools/anniversary/services/
git commit -m "feat(anniversary): 添加数据服务"
```

---

### Task 4: 创建小卡片组件

**Files:**
- Create: `lib/tools/anniversary/widgets/anniversary_card.dart`

**Dependencies:** Task 1

- [ ] **Step 4.1: 编写 AnniversaryCard**

```dart
import 'package:flutter/material.dart';
import '../models/anniversary_models.dart';

class AnniversaryCard extends StatelessWidget {
  final AnniversaryBase item;
  final VoidCallback onTap;

  const AnniversaryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = item.calculateDisplay();
    final color = Color(item.iconColor);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${display.primaryNumber}${display.primaryLabel}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
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

- [ ] **Step 4.2: 提交**

```bash
git add lib/tools/anniversary/widgets/anniversary_card.dart
git commit -m "feat(anniversary): 添加小卡片组件"
```

---

### Task 5: 创建大卡片组件

**Files:**
- Create: `lib/tools/anniversary/widgets/anniversary_card_large.dart`

**Dependencies:** Task 1

- [ ] **Step 5.1: 编写 AnniversaryCardLarge**

```dart
import 'package:flutter/material.dart';
import '../models/anniversary_models.dart';

class AnniversaryCardLarge extends StatelessWidget {
  final AnniversaryBase item;
  final VoidCallback onTap;

  const AnniversaryCardLarge({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final display = item.calculateDisplay();
    final color = Color(item.iconColor);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Text(
                      '${display.primaryNumber}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      display.primaryLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (display.secondaryText != null)
                Text(
                  display.secondaryText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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

- [ ] **Step 5.2: 提交**

```bash
git add lib/tools/anniversary/widgets/anniversary_card_large.dart
git commit -m "feat(anniversary): 添加大卡片组件"
```

---

### Task 6: 创建添加/编辑弹窗

**Files:**
- Create: `lib/tools/anniversary/widgets/anniversary_dialog.dart`

**Dependencies:** Task 1

- [ ] **Step 6.1: 编写 AnniversaryDialog**

```dart
import 'package:flutter/material.dart';
import '../models/anniversary_models.dart';

class AnniversaryDialog extends StatefulWidget {
  final AnniversaryBase? item;
  final Function(AnniversaryBase item) onSave;

  const AnniversaryDialog({
    super.key,
    this.item,
    required this.onSave,
  });

  @override
  State<AnniversaryDialog> createState() => _AnniversaryDialogState();
}

class _AnniversaryDialogState extends State<AnniversaryDialog> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late AnniversaryType _type;
  late RepeatType _repeatType;
  late Color _selectedColor;

  final List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _titleController = TextEditingController(text: item?.title ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _selectedDate = item?.targetDate ?? DateTime.now();
    _type = item?.type ?? AnniversaryType.anniversary;
    _repeatType = item?.repeatType ?? RepeatType.none;
    _selectedColor = item != null ? Color(item.iconColor) : Colors.red;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? '添加纪念日' : '编辑纪念日'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '例如：结婚纪念日',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('日期'),
              subtitle: Text(
                '${_selectedDate.year}年${_selectedDate.month}月${_selectedDate.day}日',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            const Text('类型'),
            const SizedBox(height: 8),
            SegmentedButton<AnniversaryType>(
              segments: const [
                ButtonSegment(
                  value: AnniversaryType.anniversary,
                  label: Text('纪念日'),
                ),
                ButtonSegment(
                  value: AnniversaryType.countdown,
                  label: Text('倒数日'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (set) {
                setState(() {
                  _type = set.first;
                  if (_type == AnniversaryType.countdown) {
                    _repeatType = RepeatType.none;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('循环周期'),
            const SizedBox(height: 8),
            DropdownButtonFormField<RepeatType>(
              value: _repeatType,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: _type == AnniversaryType.countdown
                  ? [
                      const DropdownMenuItem(
                        value: RepeatType.none,
                        child: Text('不循环'),
                      ),
                    ]
                  : [
                      const DropdownMenuItem(
                        value: RepeatType.none,
                        child: Text('不循环'),
                      ),
                      const DropdownMenuItem(
                        value: RepeatType.daily,
                        child: Text('每天'),
                      ),
                      const DropdownMenuItem(
                        value: RepeatType.weekly,
                        child: Text('每周'),
                      ),
                      const DropdownMenuItem(
                        value: RepeatType.monthly,
                        child: Text('每月'),
                      ),
                      const DropdownMenuItem(
                        value: RepeatType.yearly,
                        child: Text('每年'),
                      ),
                    ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _repeatType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('图标颜色'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '备注（可选）',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入标题')),
      );
      return;
    }

    AnniversaryBase item;
    if (_type == AnniversaryType.anniversary) {
      item = AnniversaryItem(
        id: widget.item?.id,
        title: title,
        targetDate: _selectedDate,
        repeatType: _repeatType,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        iconColor: _selectedColor.value,
        createdAt: widget.item?.createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      item = CountdownItem(
        id: widget.item?.id,
        title: title,
        targetDate: _selectedDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        iconColor: _selectedColor.value,
        createdAt: widget.item?.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    widget.onSave(item);
    Navigator.pop(context);
  }
}
```

- [ ] **Step 6.2: 提交**

```bash
git add lib/tools/anniversary/widgets/anniversary_dialog.dart
git commit -m "feat(anniversary): 添加添加/编辑弹窗"
```

---

### Task 7: 创建主页面

**Files:**
- Create: `lib/tools/anniversary/anniversary_page.dart`

**Dependencies:** Task 3, Task 4, Task 5, Task 6

- [ ] **Step 7.1: 编写 AnniversaryPage**

```dart
import 'package:flutter/material.dart';
import 'models/anniversary_models.dart';
import 'services/anniversary_service.dart';
import 'widgets/anniversary_card.dart';
import 'widgets/anniversary_card_large.dart';
import 'widgets/anniversary_dialog.dart';

class AnniversaryPage extends StatefulWidget {
  const AnniversaryPage({super.key});

  @override
  State<AnniversaryPage> createState() => _AnniversaryPageState();
}

class _AnniversaryPageState extends State<AnniversaryPage> {
  List<AnniversaryBase> _items = [];
  bool _isLoading = true;
  bool _isGridMode = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await AnniversaryService.getAll();
    final sorted = AnniversaryService.sortByUrgency(items);
    setState(() {
      _items = sorted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('纪念日'),
        actions: [
          IconButton(
            icon: Icon(_isGridMode ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridMode = !_isGridMode),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmptyState()
              : _isGridMode
                  ? _buildGridView()
                  : _buildListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有纪念日',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加第一个',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final isUrgent = _isUrgent(item);

        if (isUrgent) {
          return AnniversaryCardLarge(
            item: item,
            onTap: () => _showEditDialog(item),
          );
        } else {
          return AnniversaryCard(
            item: item,
            onTap: () => _showEditDialog(item),
          );
        }
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AnniversaryCard(
            item: item,
            onTap: () => _showEditDialog(item),
          ),
        );
      },
    );
  }

  bool _isUrgent(AnniversaryBase item) {
    final display = item.calculateDisplay();
    if (item is AnniversaryItem && item.repeatType == RepeatType.none) {
      return false;
    }
    return display.primaryNumber <= 7;
  }

  Future<void> _showAddDialog() async {
    showDialog(
      context: context,
      builder: (context) => AnniversaryDialog(
        onSave: (item) async {
          await AnniversaryService.add(item);
          _loadItems();
        },
      ),
    );
  }

  Future<void> _showEditDialog(AnniversaryBase item) async {
    showDialog(
      context: context,
      builder: (context) => AnniversaryDialog(
        item: item,
        onSave: (updated) async {
          await AnniversaryService.update(updated);
          _loadItems();
        },
      ),
    );
  }
}
```

- [ ] **Step 7.2: 提交**

```bash
git add lib/tools/anniversary/anniversary_page.dart
git commit -m "feat(anniversary): 添加主页面"
```

---

### Task 8: 创建 ToolModule 实现

**Files:**
- Create: `lib/tools/anniversary/anniversary_tool.dart`

**Dependencies:** Task 7

- [ ] **Step 8.1: 编写 AnniversaryTool**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'anniversary_page.dart';

class AnniversaryTool implements ToolModule {
  @override
  String get id => 'anniversary';

  @override
  String get name => '纪念日';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.favorite;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const AnniversaryPage();
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

- [ ] **Step 8.2: 提交**

```bash
git add lib/tools/anniversary/anniversary_tool.dart
git commit -m "feat(anniversary): 添加 ToolModule 实现"
```

---

### Task 9: 注册工具

**Files:**
- Modify: `lib/main.dart`

**Dependencies:** Task 8

- [ ] **Step 9.1: 导入 AnniversaryTool**

在 `lib/main.dart` 顶部添加导入：

```dart
import 'tools/anniversary/anniversary_tool.dart';
```

- [ ] **Step 9.2: 注册工具**

在 `main()` 函数中 `ToolRegistry.register(LifeGridTool());` 之后添加：

```dart
ToolRegistry.register(AnniversaryTool());
```

- [ ] **Step 9.3: 提交**

```bash
git add lib/main.dart
git commit -m "feat(anniversary): 注册纪念日工具"
```

---

## 完成验证

所有任务完成后，进行以下验证：

- [ ] 应用可以正常编译运行
- [ ] 首页能看到"纪念日"工具图标
- [ ] 点击进入后显示空状态
- [ ] 可以添加纪念日/倒数日
- [ ] 添加后按紧急程度排序展示
- [ ] 可以编辑已有条目
- [ ] 可以删除条目
- [ ] 周期性纪念日正确计算下一个日期
