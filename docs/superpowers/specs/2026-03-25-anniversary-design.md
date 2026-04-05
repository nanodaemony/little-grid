# 纪念日功能设计文档

## 1. 概述

### 1.1 功能目标
新增"纪念日"功能格子，帮助用户记录和追踪重要日期。

### 1.2 功能定义
- **纪念日**：过去的日子，关注"已过去多久"或"距离下一个还有多久"
- **倒数日**：未来的日子，关注"距离目标还有多久"
- **周期性**：支持不循环/日/周/月/年循环

### 1.3 设计原则
- 混合展示纪念日和倒数日
- 按紧急程度排序（距离近的优先）
- 重要/紧急的条目使用大卡片展示

---

## 2. 数据模型设计

### 2.1 枚举类型

```dart
/// 纪念日类型
enum AnniversaryType {
  anniversary,  // 纪念日（过去的日子）
  countdown,    // 倒数日（未来的日子）
}

/// 循环周期类型
enum RepeatType {
  none,   // 不循环
  daily,  // 每日
  weekly, // 每周
  monthly,// 每月
  yearly, // 每年
}
```

### 2.2 抽象基类

```dart
abstract class AnniversaryBase {
  final int? id;
  final String title;
  final DateTime targetDate;      // 目标日期
  final AnniversaryType type;
  final RepeatType repeatType;
  final String? notes;
  final int iconColor;            // 图标颜色（存储为 int）
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
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// 计算显示用的天数和描述
  AnniversaryDisplayData calculateDisplay();

  Map<String, dynamic> toMap();
}
```

### 2.3 具体实现类

**AnniversaryItem**（纪念日）：

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
      // 不循环：显示已过去多少天
      final daysPassed = today.difference(targetDate).inDays;
      return AnniversaryDisplayData(
        primaryNumber: daysPassed.abs(),
        primaryLabel: daysPassed >= 0 ? '天已过' : '天后',
        secondaryText: null,
      );
    } else {
      // 循环：计算下一个纪念日
      final nextDate = _calculateNextDate(today, targetDate, repeatType);
      final daysUntil = nextDate.difference(today).inDays;
      return AnniversaryDisplayData(
        primaryNumber: daysUntil,
        primaryLabel: '天后',
        secondaryText: '${nextDate.year}年${nextDate.month}月${nextDate.day}日',
      );
    }
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

**CountdownItem**（倒数日）：

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

### 2.4 显示数据类

```dart
class AnniversaryDisplayData {
  final int primaryNumber;    // 主要显示的数字
  final String primaryLabel;  // 标签（天后/天已过）
  final String? secondaryText;// 次要文本（如具体的下一个日期）

  AnniversaryDisplayData({
    required this.primaryNumber,
    required this.primaryLabel,
    this.secondaryText,
  });
}
```

---

## 3. 数据库设计

### 3.1 表结构

```sql
CREATE TABLE anniversary_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  target_date INTEGER NOT NULL,  -- 毫秒时间戳
  type INTEGER NOT NULL,         -- 0=anniversary, 1=countdown
  repeat_type INTEGER NOT NULL,  -- 0=none, 1=daily, 2=weekly, 3=monthly, 4=yearly
  notes TEXT,
  icon_color INTEGER NOT NULL,   -- Color.value
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

### 3.2 序列化/反序列化

- `toMap()`：将对象转换为数据库 Map
- `fromMap()`：根据 `type` 字段反序列化为对应子类

---

## 4. UI 设计

### 4.1 文件结构

```
lib/tools/anniversary/
├── anniversary_tool.dart          # ToolModule 实现
├── anniversary_page.dart          # 主页面
├── models/
│   └── anniversary_models.dart    # 数据模型
├── services/
│   └── anniversary_service.dart   # 数据服务
└── widgets/
    ├── anniversary_card.dart      # 小卡片（网格模式）
    ├── anniversary_card_large.dart # 大卡片
    └── anniversary_dialog.dart    # 添加/编辑弹窗
```

### 4.2 主页面布局

**模式切换**：
- 网格模式：卡片网格展示
- 列表模式：卡片列表展示

**排序规则**（按紧急程度）：

排序的核心逻辑是"距离目标日期的天数越少越紧急"，无论是纪念日还是倒数日：

- **倒数日**：`primaryNumber` 直接表示距离目标还有几天，值越小越紧急
- **纪念日**：
  - 不循环：`primaryNumber` 表示已过去多少天（越大越不紧急，应排在后面）
  - 循环：`primaryNumber` 表示距离下一个还有几天（值越小越紧急）

**统一排序算法**：
```dart
List<AnniversaryBase> _sortByUrgency(List<AnniversaryBase> items) {
  return items.sorted((a, b) {
    // 统一使用"距离目标日期的天数"作为排序依据
    final daysA = _getUrgencyDays(a);
    final daysB = _getUrgencyDays(b);
    return daysA.compareTo(daysB); // 天数少的排在前面
  });
}

int _getUrgencyDays(AnniversaryBase item) {
  final display = item.calculateDisplay();
  if (item is AnniversaryItem && item.repeatType == RepeatType.none) {
    // 不循环的纪念日：视为已过去，用一个大数表示不紧急
    return 9999;
  }
  return display.primaryNumber;
}
```

**卡片大小规则**：
- 距离目标日期 ≤ 7 天 → 大卡片
- 其他 → 小卡片

### 4.3 卡片设计

**大卡片**（`AnniversaryCardLarge`）：
```
┌─────────────────────────────┐
│  [图标]  标题                │
│                             │
│     45                      │
│     天后                    │
│                             │
│  2025年5月20日              │
└─────────────────────────────┘
```

**小卡片**（`AnniversaryCard`）：
```
┌────────────┐
│ [图标] 标题 │
│            │
│    45天后   │
└────────────┘
```

### 4.4 添加/编辑弹窗

**表单字段**：
1. 标题（必填）
2. 日期选择（日历选择器）
3. 类型选择（纪念日/倒数日）
4. 循环周期（不循环/日/周/月/年）
5. 图标颜色选择
6. 备注（可选）

---

## 5. 服务层设计

### 5.1 AnniversaryService

```dart
class AnniversaryService {
  static Future<int> add(AnniversaryBase item);
  static Future<List<AnniversaryBase>> getAll();
  static Future<void> update(AnniversaryBase item);
  static Future<void> delete(int id);
}
```

### 5.2 核心逻辑

**计算下一个日期**（用于循环纪念日）：

```dart
DateTime _calculateNextDate(DateTime today, DateTime targetDate, RepeatType repeatType) {
  switch (repeatType) {
    case RepeatType.daily:
      // 明天
      return today.add(Duration(days: 1));

    case RepeatType.weekly:
      // 下一个相同星期几的日期
      final targetWeekday = targetDate.weekday;
      final todayWeekday = today.weekday;
      int daysToAdd = targetWeekday - todayWeekday;
      if (daysToAdd <= 0) {
        daysToAdd += 7; // 如果今天已经过了或就是这一天，取下周
      }
      return today.add(Duration(days: daysToAdd));

    case RepeatType.monthly:
      // 下一个相同月日的日期
      int targetYear = today.year;
      int targetMonth = today.month;
      int targetDay = targetDate.day;

      // 尝试构造本月的目标日期
      DateTime candidate = DateTime(targetYear, targetMonth, targetDay);

      // 如果今天已经过了这个日期，或者本月没有这一天
      if (candidate.isBefore(today) || candidate.day != targetDay) {
        // 移到下个月
        targetMonth++;
        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
        }
        // 重新尝试，处理月末情况（如 1月31日 -> 2月28/29日）
        candidate = DateTime(targetYear, targetMonth, 1);
        // 获取该月最后一天
        final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
        candidate = DateTime(targetYear, targetMonth,
          targetDay > lastDayOfMonth ? lastDayOfMonth : targetDay);
      }
      return candidate;

    case RepeatType.yearly:
      // 下一个相同月日的日期
      int targetYear = today.year;
      int targetMonth = targetDate.month;
      int targetDay = targetDate.day;

      // 尝试构造今年的目标日期
      DateTime candidate = DateTime(targetYear, targetMonth, targetDay);

      // 处理闰年2月29日 -> 平年2月28日
      if (targetMonth == 2 && targetDay == 29) {
        if (!isLeapYear(targetYear)) {
          candidate = DateTime(targetYear, 2, 28);
        }
      }

      // 如果今年已经过了
      if (candidate.isBefore(today)) {
        targetYear++;
        candidate = DateTime(targetYear, targetMonth, targetDay);
        // 再次处理闰年情况
        if (targetMonth == 2 && targetDay == 29 && !isLeapYear(targetYear)) {
          candidate = DateTime(targetYear, 2, 28);
        }
      }
      return candidate;

    default:
      return targetDate;
  }
}

bool isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}
```

---

## 6. 集成点

### 6.1 注册到 ToolRegistry

在 `main.dart` 中添加：
```dart
import 'tools/anniversary/anniversary_tool.dart';

void main() {
  // ...
  ToolRegistry.register(AnniversaryTool());
  // ...
}
```

### 6.2 ToolModule 实现

```dart
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
  int get gridSize => 2;  // 大格子

  @override
  Widget buildPage(BuildContext context) => const AnniversaryPage();

  // ... 其他方法
}
```

### 6.3 数据库迁移

在 `DatabaseService` 的 `onCreate` 中添加新表创建：
```dart
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

---

## 7. 边界情况处理

### 7.1 日期计算

- **跨闰年**：2月29日的周期性处理
- **跨月计算**：不同月份天数差异
- **时区问题**：统一使用本地时间

### 7.2 数据验证

- 标题不能为空
- 日期必须有效
- 倒数日的目标日期必须在今天之后

### 7.3 空状态

首页无数据时显示引导：
```
┌─────────────────────────────┐
│                             │
│      [空状态图标]            │
│                             │
│    还没有纪念日              │
│    点击右下角添加第一个      │
│                             │
└─────────────────────────────┘
```

---

## 8. 测试要点

### 8.1 单元测试

- `calculateDisplay()` 的各种场景
- `_calculateNextDate()` 的循环计算
- 序列化/反序列化正确性

### 8.2 集成测试

- 添加/编辑/删除完整流程
- 数据库操作正确性
- 首页排序和展示

---

## 9. 实现顺序

1. **数据模型** - `anniversary_models.dart`
2. **数据库服务** - `anniversary_service.dart`
3. **UI 组件** - 卡片、弹窗
4. **主页面** - `anniversary_page.dart`
5. **工具注册** - `anniversary_tool.dart` + `main.dart`
6. **集成测试**

---

## 10. 附录

### 10.1 参考文件

- 项目现有工具模式：`tools/todo/todo_tool.dart`
- 数据服务模式：`tools/todo/todo_service.dart`
- 数据库服务：`core/services/database_service.dart`

### 10.2 命名约定

- 文件名：snake_case（如 `anniversary_page.dart`）
- 类名：PascalCase（如 `AnniversaryPage`）
- 方法/变量：camelCase（如 `calculateDisplay`）
