# 账本 (Account) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a personal finance tracking tool with expense/income records, category management, statistics charts, and budget management.

**Architecture:** SQLite database with three tables (records, categories, budgets), service layer for business logic, and Flutter UI with fl_chart for visualizations. Follows existing tool pattern with ToolModule implementation.

**Tech Stack:** Flutter, SQLite (sqflite), fl_chart for charts

---

## File Structure

```
app/lib/tools/account/
├── account_tool.dart              # Tool module entry point
├── account_page.dart              # Main page (overview with monthly summary, quick add, recent records)
├── models/
│   ├── record.dart                # Record model (expense/income)
│   ├── category.dart              # Category model (two-level hierarchy)
│   ├── budget.dart                # Budget model
│   └── stats_models.dart          # Statistics result models
├── services/
│   └── account_service.dart       # All database operations and business logic
├── pages/
│   ├── add_record_page.dart       # Add/edit record page
│   ├── stats_page.dart            # Statistics with pie charts and trend line
│   ├── budget_page.dart           # Budget management with progress bars
│   └── category_page.dart         # Category management (CRUD)
└── widgets/
    ├── record_list_item.dart      # Record list item with swipe delete
    ├── category_picker.dart       # Two-level category selector dialog
    ├── pie_chart.dart             # Expense/income pie chart using fl_chart
    ├── trend_chart.dart           # Monthly trend line chart
    └── budget_progress.dart       # Budget progress bar widget
```

**Files to modify:**
- `app/lib/core/constants/app_constants.dart` - Update dbVersion from 4 to 5
- `app/lib/core/services/database_service.dart` - Add account tables in _onCreate and _onUpgrade
- `app/lib/main.dart` - Register AccountTool
- `app/pubspec.yaml` - Add fl_chart dependency

---

## Task 1: Update Database Schema

**Files:**
- Modify: `app/lib/core/constants/app_constants.dart:11`
- Modify: `app/lib/core/services/database_service.dart:172-227`

- [ ] **Step 1: Update database version**

```dart
// In app/lib/core/constants/app_constants.dart
// Change line 11 from:
static const int dbVersion = 4;
// To:
static const int dbVersion = 5;
```

- [ ] **Step 2: Add account tables to _onCreate**

Insert after line 169 (after pomodoro_records table creation):

```dart
    // Account records table
    await db.execute('''
      CREATE TABLE account_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        sub_category_id INTEGER,
        date INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_account_records_date ON account_records(date)');
    await db.execute('CREATE INDEX idx_account_records_category ON account_records(category_id)');

    // Account categories table
    await db.execute('''
      CREATE TABLE account_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        icon_type INTEGER DEFAULT 1,
        parent_id INTEGER DEFAULT 0,
        type INTEGER NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_preset INTEGER DEFAULT 0,
        is_hidden INTEGER DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_account_categories_parent ON account_categories(parent_id)');

    // Account budgets table
    await db.execute('''
      CREATE TABLE account_budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        month TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE (category_id, month)
      )
    ''');
    await db.execute('CREATE INDEX idx_account_budgets_category_month ON account_budgets(category_id, month)');
```

- [ ] **Step 3: Add migration to _onUpgrade**

Add after line 226 (after pomodoro_records migration):

```dart
    if (oldVersion < 5) {
      // Account records table
      await db.execute('''
        CREATE TABLE account_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          type INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          sub_category_id INTEGER,
          date INTEGER NOT NULL,
          note TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_account_records_date ON account_records(date)');
      await db.execute('CREATE INDEX idx_account_records_category ON account_records(category_id)');

      // Account categories table
      await db.execute('''
        CREATE TABLE account_categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT NOT NULL,
          icon_type INTEGER DEFAULT 1,
          parent_id INTEGER DEFAULT 0,
          type INTEGER NOT NULL,
          sort_order INTEGER DEFAULT 0,
          is_preset INTEGER DEFAULT 0,
          is_hidden INTEGER DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX idx_account_categories_parent ON account_categories(parent_id)');

      // Account budgets table
      await db.execute('''
        CREATE TABLE account_budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          month TEXT NOT NULL,
          amount REAL NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          UNIQUE (category_id, month)
        )
      ''');
      await db.execute('CREATE INDEX idx_account_budgets_category_month ON account_budgets(category_id, month)');

      AppLogger.i('Added account tables');
    }
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/core/constants/app_constants.dart app/lib/core/services/database_service.dart
git commit -m "feat(account): add database schema for account records, categories, and budgets"
```

---

## Task 2: Create Data Models

**Files:**
- Create: `app/lib/tools/account/models/record.dart`
- Create: `app/lib/tools/account/models/category.dart`
- Create: `app/lib/tools/account/models/budget.dart`
- Create: `app/lib/tools/account/models/stats_models.dart`

- [ ] **Step 1: Create Record model**

```dart
// app/lib/tools/account/models/record.dart

enum RecordType { expense, income }

class Record {
  final int? id;
  final double amount;
  final RecordType type;
  final int categoryId;
  final int? subCategoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Record({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.subCategoryId,
    required this.date,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type == RecordType.expense ? 1 : 2,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 1 ? RecordType.expense : RecordType.income,
      categoryId: map['category_id'] as int,
      subCategoryId: map['sub_category_id'] as int?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Record copyWith({
    int? id,
    double? amount,
    RecordType? type,
    int? categoryId,
    int? subCategoryId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Record(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

- [ ] **Step 2: Create Category model**

```dart
// app/lib/tools/account/models/category.dart

import 'record.dart';

enum IconType { emoji, asset }

class Category {
  final int? id;
  final String name;
  final String icon;
  final IconType iconType;
  final int parentId;
  final RecordType type;
  final int sortOrder;
  final bool isPreset;
  final bool isHidden;

  Category({
    this.id,
    required this.name,
    required this.icon,
    this.iconType = IconType.emoji,
    this.parentId = 0,
    required this.type,
    this.sortOrder = 0,
    this.isPreset = false,
    this.isHidden = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'icon_type': iconType == IconType.emoji ? 1 : 2,
      'parent_id': parentId,
      'type': type == RecordType.expense ? 1 : 2,
      'sort_order': sortOrder,
      'is_preset': isPreset ? 1 : 0,
      'is_hidden': isHidden ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      iconType: map['icon_type'] == 1 ? IconType.emoji : IconType.asset,
      parentId: map['parent_id'] as int,
      type: map['type'] == 1 ? RecordType.expense : RecordType.income,
      sortOrder: map['sort_order'] as int,
      isPreset: map['is_preset'] == 1,
      isHidden: map['is_hidden'] == 1,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    IconType? iconType,
    int? parentId,
    RecordType? type,
    int? sortOrder,
    bool? isPreset,
    bool? isHidden,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      iconType: iconType ?? this.iconType,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isPreset: isPreset ?? this.isPreset,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
```

- [ ] **Step 3: Create Budget model**

```dart
// app/lib/tools/account/models/budget.dart

class Budget {
  final int? id;
  final int categoryId;
  final String month;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    this.id,
    required this.categoryId,
    required this.month,
    required this.amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'month': month,
      'amount': amount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      month: map['month'] as String,
      amount: (map['amount'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Budget copyWith({
    int? id,
    int? categoryId,
    String? month,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

- [ ] **Step 4: Create statistics models**

```dart
// app/lib/tools/account/models/stats_models.dart

import 'category.dart';
import 'budget.dart';

/// Monthly summary
class MonthlySummary {
  final double income;
  final double expense;

  MonthlySummary({required this.income, required this.expense});

  double get balance => income - expense;
}

/// Category statistics
class CategoryStats {
  final Category category;
  final double amount;

  CategoryStats({required this.category, required this.amount});
}

/// Trend data for line chart
class TrendData {
  final String month;
  final double income;
  final double expense;

  TrendData({required this.month, required this.income, required this.expense});
}

/// Budget with associated category
class BudgetWithCategory {
  final Budget budget;
  final Category category;
  final double spent;

  BudgetWithCategory({
    required this.budget,
    required this.category,
    this.spent = 0,
  });

  double get remaining => budget.amount - spent;
  double get progress => budget.amount > 0 ? (spent / budget.amount).clamp(0, 1) : 0;
  bool get isOverBudget => spent > budget.amount;
}
```

- [ ] **Step 5: Commit**

```bash
git add app/lib/tools/account/models/
git commit -m "feat(account): add data models for record, category, budget, and statistics"
```

---

## Task 3: Create Account Service

**Files:**
- Create: `app/lib/tools/account/services/account_service.dart`

- [ ] **Step 1: Create the service with all methods**

```dart
// app/lib/tools/account/services/account_service.dart

import '../../../core/services/database_service.dart';
import '../models/record.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/stats_models.dart';

class AccountService {
  // ========== Preset Categories Data ==========

  static final List<Category> _presetExpenseCategories = [
    // 餐饮
    Category(name: '餐饮', icon: '🍚', type: RecordType.expense, isPreset: true, sortOrder: 1),
    Category(name: '早餐', icon: '🍜', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '午餐', icon: '🍱', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '晚餐', icon: '🍲', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '饮料', icon: '☕', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '零食', icon: '🍰', type: RecordType.expense, parentId: -1, isPreset: true),
    // 交通
    Category(name: '交通', icon: '🚌', type: RecordType.expense, isPreset: true, sortOrder: 2),
    Category(name: '地铁', icon: '🚇', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '公交', icon: '🚌', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '打车', icon: '🚗', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '加油', icon: '⛽', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '停车', icon: '🅿️', type: RecordType.expense, parentId: -1, isPreset: true),
    // 购物
    Category(name: '购物', icon: '🛒', type: RecordType.expense, isPreset: true, sortOrder: 3),
    Category(name: '服饰', icon: '👔', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '鞋包', icon: '👟', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '化妆品', icon: '💄', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '日用品', icon: '🏠', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '数码', icon: '📱', type: RecordType.expense, parentId: -1, isPreset: true),
    // 居住
    Category(name: '居住', icon: '🏠', type: RecordType.expense, isPreset: true, sortOrder: 4),
    Category(name: '房租', icon: '💰', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '水电', icon: '💡', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '燃气', icon: '🔥', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '网费', icon: '📶', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '维修', icon: '🔧', type: RecordType.expense, parentId: -1, isPreset: true),
    // 娱乐
    Category(name: '娱乐', icon: '🎮', type: RecordType.expense, isPreset: true, sortOrder: 5),
    Category(name: '电影', icon: '🎬', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '游戏', icon: '🎮', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: 'KTV', icon: '🎤', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '书籍', icon: '📚', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '旅游', icon: '✈️', type: RecordType.expense, parentId: -1, isPreset: true),
    // 医疗
    Category(name: '医疗', icon: '🏥', type: RecordType.expense, isPreset: true, sortOrder: 6),
    Category(name: '药品', icon: '💊', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '门诊', icon: '🏥', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '牙科', icon: '🦷', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '眼镜', icon: '👓', type: RecordType.expense, parentId: -1, isPreset: true),
    // 教育
    Category(name: '教育', icon: '📚', type: RecordType.expense, isPreset: true, sortOrder: 7),
    Category(name: '培训', icon: '📖', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '书籍', icon: '📕', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '学费', icon: '🎓', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '兴趣班', icon: '🎹', type: RecordType.expense, parentId: -1, isPreset: true),
    // 宠物
    Category(name: '宠物', icon: '🐾', type: RecordType.expense, isPreset: true, sortOrder: 8),
    Category(name: '猫粮', icon: '🐱', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '猫砂', icon: '🐾', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '狗粮', icon: '🐶', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '疫苗', icon: '💉', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '宠物医疗', icon: '🏥', type: RecordType.expense, parentId: -1, isPreset: true),
    // 人情
    Category(name: '人情', icon: '💝', type: RecordType.expense, isPreset: true, sortOrder: 9),
    Category(name: '礼物', icon: '🎁', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '红包', icon: '💒', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '生日', icon: '🎂', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '婚庆', icon: '💍', type: RecordType.expense, parentId: -1, isPreset: true),
    // 其他
    Category(name: '其他', icon: '💳', type: RecordType.expense, isPreset: true, sortOrder: 10),
    Category(name: '其他支出', icon: '📝', type: RecordType.expense, parentId: -1, isPreset: true),
  ];

  static final List<Category> _presetIncomeCategories = [
    // 工资
    Category(name: '工资', icon: '💵', type: RecordType.income, isPreset: true, sortOrder: 1),
    Category(name: '基本工资', icon: '💰', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '奖金', icon: '🎁', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '加班费', icon: '📈', type: RecordType.income, parentId: -1, isPreset: true),
    // 兼职
    Category(name: '兼职', icon: '💼', type: RecordType.income, isPreset: true, sortOrder: 2),
    Category(name: '自由职业', icon: '💻', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '兼职收入', icon: '📝', type: RecordType.income, parentId: -1, isPreset: true),
    // 理财
    Category(name: '理财', icon: '📈', type: RecordType.income, isPreset: true, sortOrder: 3),
    Category(name: '股票', icon: '📊', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '基金', icon: '💰', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '利息', icon: '🏦', type: RecordType.income, parentId: -1, isPreset: true),
    // 其他
    Category(name: '其他', icon: '🎁', type: RecordType.income, isPreset: true, sortOrder: 4),
    Category(name: '其他收入', icon: '📝', type: RecordType.income, parentId: -1, isPreset: true),
  ];

  /// Initialize preset categories (called once on first run)
  static Future<void> initPresetCategories() async {
    final db = await DatabaseService.database;
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM account_categories');
    final existingCount = (count.first['count'] as int);

    if (existingCount > 0) return;

    // Insert expense categories
    int? lastParentId;
    for (final category in _presetExpenseCategories) {
      final catToInsert = category.parentId == -1 && lastParentId != null
          ? category.copyWith(parentId: lastParentId)
          : category;
      final id = await db.insert('account_categories', catToInsert.toMap());
      if (category.parentId == 0) {
        lastParentId = id;
      }
    }

    // Insert income categories
    lastParentId = null;
    for (final category in _presetIncomeCategories) {
      final catToInsert = category.parentId == -1 && lastParentId != null
          ? category.copyWith(parentId: lastParentId)
          : category;
      final id = await db.insert('account_categories', catToInsert.toMap());
      if (category.parentId == 0) {
        lastParentId = id;
      }
    }
  }

  // ========== Record Operations ==========

  static Future<int> insertRecord(Record record) async {
    final db = await DatabaseService.database;
    return await db.insert('account_records', record.toMap());
  }

  static Future<int> updateRecord(Record record) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_records',
      record.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<int> deleteRecord(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'account_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Record>> getRecords({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    int? limit,
  }) async {
    final db = await DatabaseService.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    if (categoryId != null) {
      whereClauses.add('(category_id = ? OR sub_category_id = ?)');
      whereArgs.addAll([categoryId, categoryId]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'account_records',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );

    return maps.map((map) => Record.fromMap(map)).toList();
  }

  static Future<Record?> getRecordById(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'account_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Record.fromMap(maps.first);
  }

  static Future<int> updateRecordsCategory(int oldCategoryId, int newCategoryId) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_records',
      {'category_id': newCategoryId, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'category_id = ?',
      whereArgs: [oldCategoryId],
    );
  }

  static Future<int> getRecordCountByCategory(int categoryId) async {
    final db = await DatabaseService.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM account_records WHERE category_id = ? OR sub_category_id = ?',
      [categoryId, categoryId],
    );
    return (count.first['count'] as int);
  }

  // ========== Statistics ==========

  static Future<MonthlySummary> getMonthlySummary(String month) async {
    final db = await DatabaseService.database;
    final startOfMonth = DateTime.parse('$month-01');
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN type = 1 THEN amount ELSE 0 END) as expense,
        SUM(CASE WHEN type = 2 THEN amount ELSE 0 END) as income
      FROM account_records
      WHERE date >= ? AND date <= ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    final map = result.first;
    return MonthlySummary(
      income: (map['income'] as num?)?.toDouble() ?? 0,
      expense: (map['expense'] as num?)?.toDouble() ?? 0,
    );
  }

  static Future<List<CategoryStats>> getCategoryStats(
    String month,
    RecordType type,
  ) async {
    final db = await DatabaseService.database;
    final startOfMonth = DateTime.parse('$month-01');
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0, 23, 59, 59);
    final typeValue = type == RecordType.expense ? 1 : 2;

    final result = await db.rawQuery('''
      SELECT category_id, SUM(amount) as total
      FROM account_records
      WHERE type = ? AND date >= ? AND date <= ?
      GROUP BY category_id
      ORDER BY total DESC
    ''', [typeValue, startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    final stats = <CategoryStats>[];
    for (final row in result) {
      final categoryId = row['category_id'] as int;
      final category = await getCategoryById(categoryId);
      if (category != null) {
        stats.add(CategoryStats(
          category: category,
          amount: (row['total'] as num).toDouble(),
        ));
      }
    }
    return stats;
  }

  static Future<List<TrendData>> getTrendData(int months) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final result = <TrendData>[];

    for (int i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStr = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      final summary = await getMonthlySummary(monthStr);
      result.add(TrendData(
        month: monthStr,
        income: summary.income,
        expense: summary.expense,
      ));
    }

    return result;
  }

  // ========== Category Operations ==========

  static Future<List<Category>> getCategories(RecordType type) async {
    final db = await DatabaseService.database;
    final typeValue = type == RecordType.expense ? 1 : 2;

    final List<Map<String, dynamic>> maps = await db.query(
      'account_categories',
      where: 'type = ? AND parent_id = 0 AND is_hidden = 0',
      whereArgs: [typeValue],
      orderBy: 'sort_order ASC, id ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  static Future<List<Category>> getSubCategories(int parentId) async {
    final db = await DatabaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'account_categories',
      where: 'parent_id = ? AND is_hidden = 0',
      whereArgs: [parentId],
      orderBy: 'id ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  static Future<Category?> getCategoryById(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'account_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  static Future<int> insertCategory(Category category) async {
    final db = await DatabaseService.database;
    return await db.insert('account_categories', category.toMap());
  }

  static Future<int> updateCategory(Category category) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> hideCategory(int id) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_categories',
      {'is_hidden': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCategory(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'account_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== Budget Operations ==========

  static Future<List<BudgetWithCategory>> getBudgets(String month) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.icon as category_icon, c.icon_type as category_icon_type
      FROM account_budgets b
      INNER JOIN account_categories c ON b.category_id = c.id
      WHERE b.month = ?
      ORDER BY b.amount DESC
    ''', [month]);

    final budgets = <BudgetWithCategory>[];
    for (final row in result) {
      final budget = Budget.fromMap(row);
      final category = Category(
        id: budget.categoryId,
        name: row['category_name'] as String,
        icon: row['category_icon'] as String,
        iconType: row['category_icon_type'] == 1 ? IconType.emoji : IconType.asset,
        type: RecordType.expense,
      );
      final spent = await getCategorySpending(budget.categoryId, month);
      budgets.add(BudgetWithCategory(
        budget: budget,
        category: category,
        spent: spent,
      ));
    }
    return budgets;
  }

  static Future<int> setBudget(int categoryId, String month, double amount) async {
    final db = await DatabaseService.database;

    // Try to update existing
    final updated = await db.update(
      'account_budgets',
      {
        'amount': amount,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'category_id = ? AND month = ?',
      whereArgs: [categoryId, month],
    );

    if (updated > 0) return updated;

    // Insert new
    final budget = Budget(
      categoryId: categoryId,
      month: month,
      amount: amount,
    );
    return await db.insert('account_budgets', budget.toMap());
  }

  static Future<double> getCategorySpending(int categoryId, String month) async {
    final db = await DatabaseService.database;
    final startOfMonth = DateTime.parse('$month-01');
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM account_records
      WHERE category_id = ? AND type = 1 AND date >= ? AND date <= ?
    ''', [categoryId, startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  static Future<void> deleteBudget(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'account_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/account/services/account_service.dart
git commit -m "feat(account): add account service with CRUD operations, statistics, and preset categories"
```

---

## Task 4: Create Account Tool Module

**Files:**
- Create: `app/lib/tools/account/account_tool.dart`

- [ ] **Step 1: Create tool module**

```dart
// app/lib/tools/account/account_tool.dart

import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'account_page.dart';
import 'services/account_service.dart';

class AccountTool implements ToolModule {
  @override
  String get id => 'account';

  @override
  String get name => '账本';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.account_balance_wallet;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const AccountPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {
    await AccountService.initPresetCategories();
  }

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/account/account_tool.dart
git commit -m "feat(account): add account tool module"
```

---

## Task 5: Create Main Account Page

**Files:**
- Create: `app/lib/tools/account/account_page.dart`

- [ ] **Step 1: Create main page**

```dart
// app/lib/tools/account/account_page.dart

import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';
import 'models/record.dart';
import 'services/account_service.dart';
import 'pages/add_record_page.dart';
import 'pages/stats_page.dart';
import 'pages/budget_page.dart';
import 'pages/category_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<Record> _records = [];
  bool _isLoading = true;
  double _monthlyIncome = 0;
  double _monthlyExpense = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final summary = await AccountService.getMonthlySummary(monthStr);
    final records = await AccountService.getRecords(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      limit: 20,
    );

    setState(() {
      _monthlyIncome = summary.income;
      _monthlyExpense = summary.expense;
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账本'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoryPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_balance),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetPage()),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildSummaryCard()),
                  SliverToBoxAdapter(child: _buildQuickActions()),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '最近记录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  _records.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildRecordItem(_records[index]),
                            childCount: _records.length,
                          ),
                        ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRecord(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final balance = _monthlyIncome - _monthlyExpense;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '本月结余',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('收入', _monthlyIncome, Icons.arrow_upward),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _buildSummaryItem('支出', _monthlyExpense, Icons.arrow_downward),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_circle,
              label: '记支出',
              color: AppColors.error,
              onTap: () => _addRecord(type: RecordType.expense),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.add_circle,
              label: '记收入',
              color: AppColors.success,
              onTap: () => _addRecord(type: RecordType.income),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            '暂无记录',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            '点击右下角添加记账',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(Record record) {
    return FutureBuilder(
      future: _loadRecordCategory(record),
      builder: (context, snapshot) {
        final category = snapshot.data;
        final isExpense = record.type == RecordType.expense;

        return Dismissible(
          key: Key('record_${record.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => _deleteRecord(record),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isExpense
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.success.withOpacity(0.1),
              child: Text(
                category?.icon ?? '📝',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(category?.name ?? '未知分类'),
            subtitle: Text(
              '${record.date.month}/${record.date.day} ${record.note ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              '${isExpense ? '-' : '+'}¥${record.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isExpense ? AppColors.error : AppColors.success,
              ),
            ),
            onTap: () => _editRecord(record),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _loadRecordCategory(Record record) async {
    final category = await AccountService.getCategoryById(record.categoryId);
    final subCategory = record.subCategoryId != null
        ? await AccountService.getCategoryById(record.subCategoryId!)
        : null;
    return {
      'icon': subCategory?.icon ?? category?.icon ?? '📝',
      'name': subCategory?.name ?? category?.name ?? '未知分类',
    };
  }

  Future<void> _addRecord({RecordType? type}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecordPage(initialType: type),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _editRecord(Record record) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRecordPage(record: record),
      ),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteRecord(Record record) async {
    if (record.id == null) return;
    await AccountService.deleteRecord(record.id!);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('记录已删除')),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/account/account_page.dart
git commit -m "feat(account): add main page with monthly summary and recent records"
```

---

## Task 6: Create Add/Edit Record Page

**Files:**
- Create: `app/lib/tools/account/pages/add_record_page.dart`

- [ ] **Step 1: Create add record page**

```dart
// app/lib/tools/account/pages/add_record_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/record.dart';
import '../models/category.dart';
import '../services/account_service.dart';
import '../widgets/category_picker.dart';

class AddRecordPage extends StatefulWidget {
  final Record? record;
  final RecordType? initialType;

  const AddRecordPage({super.key, this.record, this.initialType});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  late RecordType _type;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  Category? _selectedCategory;
  Category? _selectedSubCategory;
  List<Category> _categories = [];

  String get _title => widget.record == null ? '记一笔' : '编辑记录';

  @override
  void initState() {
    super.initState();
    _type = widget.record?.type ?? widget.initialType ?? RecordType.expense;
    _loadCategories();

    if (widget.record != null) {
      _amountController.text = widget.record!.amount.toStringAsFixed(2);
      _noteController.text = widget.record!.note ?? '';
      _date = widget.record!.date;
      _loadExistingCategories();
    }
  }

  Future<void> _loadCategories() async {
    final categories = await AccountService.getCategories(_type);
    setState(() => _categories = categories);
  }

  Future<void> _loadExistingCategories() async {
    if (widget.record == null) return;
    final category = await AccountService.getCategoryById(widget.record!.categoryId);
    final subCategory = widget.record!.subCategoryId != null
        ? await AccountService.getCategoryById(widget.record!.subCategoryId!)
        : null;
    setState(() {
      _selectedCategory = category;
      _selectedSubCategory = subCategory;
    });
  }

  void _switchType(RecordType type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _selectedCategory = null;
      _selectedSubCategory = null;
    });
    _loadCategories();
  }

  Future<void> _selectCategory() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CategoryPicker(
        type: _type,
        selectedCategory: _selectedCategory,
        selectedSubCategory: _selectedSubCategory,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result['category'] as Category?;
        _selectedSubCategory = result['subCategory'] as Category?;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('请输入有效金额');
      return;
    }
    if (_selectedCategory == null) {
      _showError('请选择分类');
      return;
    }

    final record = Record(
      id: widget.record?.id,
      amount: amount,
      type: _type,
      categoryId: _selectedCategory!.id!,
      subCategoryId: _selectedSubCategory?.id,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (widget.record == null) {
      await AccountService.insertRecord(record);
    } else {
      await AccountService.updateRecord(record);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type toggle
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // Amount input
            _buildAmountInput(),
            const SizedBox(height: 24),

            // Category selector
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Date selector
            _buildDateSelector(),
            const SizedBox(height: 16),

            // Note input
            _buildNoteInput(),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: '支出',
              isSelected: _type == RecordType.expense,
              color: AppColors.error,
              onTap: () => _switchType(RecordType.expense),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: '收入',
              isSelected: _type == RecordType.income,
              color: AppColors.success,
              onTap: () => _switchType(RecordType.income),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('金额', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '¥ ',
            prefixStyle: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _type == RecordType.expense ? AppColors.error : AppColors.success,
            ),
            border: InputBorder.none,
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return InkWell(
      onTap: _selectCategory,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (_selectedCategory != null) ...[
              Text(_selectedSubCategory?.icon ?? _selectedCategory!.icon,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                _selectedSubCategory?.name ?? _selectedCategory!.name,
                style: const TextStyle(fontSize: 16),
              ),
            ] else ...[
              Icon(Icons.category, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Text('选择分类', style: TextStyle(color: Colors.grey.shade500)),
            ],
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Text(
              '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: '备注（可选）',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.edit_note),
      ),
      maxLines: 2,
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/account/pages/add_record_page.dart
git commit -m "feat(account): add record creation/editing page"
```

---

## Task 7: Create Category Picker Widget

**Files:**
- Create: `app/lib/tools/account/widgets/category_picker.dart`

- [ ] **Step 1: Create category picker**

```dart
// app/lib/tools/account/widgets/category_picker.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/category.dart';
import '../models/record.dart';
import '../services/account_service.dart';

class CategoryPicker extends StatefulWidget {
  final RecordType type;
  final Category? selectedCategory;
  final Category? selectedSubCategory;

  const CategoryPicker({
    super.key,
    required this.type,
    this.selectedCategory,
    this.selectedSubCategory,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Category> _subCategories = [];
  Category? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedSubCategory = widget.selectedSubCategory;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await AccountService.getCategories(widget.type);
    setState(() => _categories = categories);

    if (_selectedCategory != null) {
      _loadSubCategories(_selectedCategory!);
    }
  }

  Future<void> _loadSubCategories(Category category) async {
    final subCategories = await AccountService.getSubCategories(category.id!);
    setState(() {
      _subCategories = subCategories;
      if (_subCategories.isEmpty) {
        // No subcategories, select this category directly
        _confirmSelection();
      }
    });
  }

  void _selectCategory(Category category) {
    if (_selectedCategory?.id == category.id) return;

    setState(() {
      _selectedCategory = category;
      _selectedSubCategory = null;
      _subCategories = [];
    });
    _loadSubCategories(category);
  }

  void _selectSubCategory(Category subCategory) {
    setState(() => _selectedSubCategory = subCategory);
    _confirmSelection();
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                // Primary categories
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.grey.shade50,
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory?.id == category.id;
                        return _CategoryItem(
                          category: category,
                          isSelected: isSelected,
                          onTap: () => _selectCategory(category),
                        );
                      },
                    ),
                  ),
                ),
                // Secondary categories
                Expanded(
                  flex: 3,
                  child: _subCategories.isEmpty
                      ? Center(
                          child: Text(
                            '该分类暂无子分类',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _subCategories.length,
                          itemBuilder: (context, index) {
                            final sub = _subCategories[index];
                            final isSelected = _selectedSubCategory?.id == sub.id;
                            return _SubCategoryItem(
                              category: sub,
                              isSelected: isSelected,
                              onTap: () => _selectSubCategory(sub),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text(
            '选择分类',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/account/widgets/category_picker.dart
git commit -m "feat(account): add category picker widget"
```

---

## Task 8: Create Statistics Page with Charts

**Files:**
- Create: `app/lib/tools/account/pages/stats_page.dart`

- [ ] **Step 1: Add fl_chart dependency**

Add to `app/pubspec.yaml` under dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... existing dependencies
  fl_chart: ^0.66.0
```

Run: `flutter pub get`

- [ ] **Step 2: Create stats page**

```dart
// app/lib/tools/account/pages/stats_page.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/ui/app_colors.dart';
import '../models/record.dart';
import '../models/category.dart';
import '../models/stats_models.dart';
import '../services/account_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime _currentMonth = DateTime.now();
  MonthlySummary _summary = MonthlySummary(income: 0, expense: 0);
  List<CategoryStats> _expenseStats = [];
  List<CategoryStats> _incomeStats = [];
  List<TrendData> _trendData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final monthStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';

    final summary = await AccountService.getMonthlySummary(monthStr);
    final expenseStats = await AccountService.getCategoryStats(monthStr, RecordType.expense);
    final incomeStats = await AccountService.getCategoryStats(monthStr, RecordType.income);
    final trendData = await AccountService.getTrendData(6);

    setState(() {
      _summary = summary;
      _expenseStats = expenseStats;
      _incomeStats = incomeStats;
      _trendData = trendData;
      _isLoading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    if (_currentMonth.year == DateTime.now().year &&
        _currentMonth.month == DateTime.now().month) {
      return;
    }
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 24),
                  if (_expenseStats.isNotEmpty) ...[
                    _buildSectionTitle('支出分类'),
                    const SizedBox(height: 12),
                    _buildPieChart(_expenseStats, AppColors.error),
                    const SizedBox(height: 8),
                    _buildLegend(_expenseStats),
                    const SizedBox(height: 24),
                  ],
                  if (_incomeStats.isNotEmpty) ...[
                    _buildSectionTitle('收入分类'),
                    const SizedBox(height: 12),
                    _buildPieChart(_incomeStats, AppColors.success),
                    const SizedBox(height: 8),
                    _buildLegend(_incomeStats),
                    const SizedBox(height: 24),
                  ],
                  if (_trendData.isNotEmpty) ...[
                    _buildSectionTitle('近6个月趋势'),
                    const SizedBox(height: 12),
                    _buildTrendChart(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        Text(
          '${_currentMonth.year}年${_currentMonth.month}月',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('收入', _summary.income, AppColors.success),
          _buildSummaryItem('支出', _summary.expense, AppColors.error),
          _buildSummaryItem('结余', _summary.balance, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          '¥${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPieChart(List<CategoryStats> stats, Color baseColor) {
    final total = stats.fold<double>(0, (sum, s) => sum + s.amount);
    if (total == 0) return const SizedBox();

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: stats.map((s) {
            final percentage = (s.amount / total * 100).toStringAsFixed(1);
            return PieChartSectionData(
              value: s.amount,
              title: '$percentage%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              color: _getCategoryColor(stats.indexOf(s)),
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildLegend(List<CategoryStats> stats) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCategoryColor(index),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text('${stat.category.icon} ${stat.category.name}'),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTrendChart() {
    final maxAmount = _trendData
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '¥${value.toInt()}',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < _trendData.length) {
                    final month = _trendData[value.toInt()].month;
                    return Text(
                      month.substring(5),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxAmount * 1.2,
          lineBarsData: [
            // Income line
            LineChartBarData(
              spots: _trendData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.income);
              }).toList(),
              isCurved: true,
              color: AppColors.success,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
            // Expense line
            LineChartBarData(
              spots: _trendData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.expense);
              }).toList(),
              isCurved: true,
              color: AppColors.error,
              barWidth: 3,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.error,
      AppColors.success,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/pubspec.yaml app/lib/tools/account/pages/stats_page.dart
git commit -m "feat(account): add statistics page with pie charts and trend line"
```

---

## Task 9: Create Budget Page

**Files:**
- Create: `app/lib/tools/account/pages/budget_page.dart`

- [ ] **Step 1: Create budget page**

```dart
// app/lib/tools/account/pages/budget_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/category.dart';
import '../models/stats_models.dart';
import '../services/account_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  DateTime _currentMonth = DateTime.now();
  List<BudgetWithCategory> _budgets = [];
  double _totalBudget = 0;
  double _totalSpent = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final monthStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
    final budgets = await AccountService.getBudgets(monthStr);

    double totalBudget = 0;
    double totalSpent = 0;
    for (final b in budgets) {
      totalBudget += b.budget.amount;
      totalSpent += b.spent;
    }

    setState(() {
      _budgets = budgets;
      _totalBudget = totalBudget;
      _totalSpent = totalSpent;
      _isLoading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    if (_currentMonth.year == DateTime.now().year &&
        _currentMonth.month == DateTime.now().month) {
      return;
    }
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadData();
  }

  Future<void> _setBudget(Category category) async {
    final controller = TextEditingController();
    final existingBudget = _budgets.firstWhere(
      (b) => b.category.id == category.id,
      orElse: () => BudgetWithCategory(
        budget: Budget(categoryId: category.id!, month: '', amount: 0),
        category: category,
      ),
    );

    if (existingBudget.budget.id != null) {
      controller.text = existingBudget.budget.amount.toStringAsFixed(0);
    }

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('设置预算 - ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '预算金额',
            prefixText: '¥ ',
          ),
        ),
        actions: [
          if (existingBudget.budget.id != null)
            TextButton(
              onPressed: () async {
                await AccountService.deleteBudget(existingBudget.budget.id!);
                if (mounted) Navigator.pop(context, -1);
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == -1) {
      _loadData();
      return;
    }

    if (result != null && result > 0) {
      final monthStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
      await AccountService.setBudget(category.id!, monthStr, result);
      _loadData();
    }
  }

  Future<void> _addBudget() async {
    final categories = await AccountService.getCategories(expense);
    final categoriesWithBudget = _budgets.map((b) => b.category.id).toSet();
    final availableCategories = categories
        .where((c) => !categoriesWithBudget.contains(c.id))
        .toList();

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所有分类都已设置预算')),
      );
      return;
    }

    final selectedCategory = await showDialog<Category>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分类'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableCategories.length,
            itemBuilder: (context, index) {
              final category = availableCategories[index];
              return ListTile(
                leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                title: Text(category.name),
                onTap: () => Navigator.pop(context, category),
              );
            },
          ),
        ),
      ),
    );

    if (selectedCategory != null) {
      _setBudget(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _totalBudget - _totalSpent;
    final progress = _totalBudget > 0 ? (_totalSpent / _totalBudget).clamp(0, 1) : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('预算')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthSelector(),
                _buildOverviewCard(remaining, progress),
                Expanded(
                  child: _budgets.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _budgets.length,
                          itemBuilder: (context, index) {
                            return _buildBudgetItem(_budgets[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudget,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            '${_currentMonth.year}年${_currentMonth.month}月',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(double remaining, double progress) {
    final isOverBudget = remaining < 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [AppColors.error, Colors.red.shade400]
              : [AppColors.primary, const Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOverBudget ? '已超支' : '本月剩余',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${remaining.abs().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '总预算: ¥${_totalBudget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '已用: ¥${_totalSpent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% 已使用',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            '暂无预算设置',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            '点击右下角添加预算',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(BudgetWithCategory item) {
    final isOverBudget = item.isOverBudget;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _setBudget(item.category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(item.category.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '¥${item.spent.toStringAsFixed(0)} / ¥${item.budget.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverBudget ? AppColors.error : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOverBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '超支',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    isOverBudget ? AppColors.error : AppColors.primary,
                  ),
                  minHeight: 6,
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

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/account/pages/budget_page.dart
git commit -m "feat(account): add budget management page with progress tracking"
```

---

## Task 10: Create Category Management Page

**Files:**
- Create: `app/lib/tools/account/pages/category_page.dart`

- [ ] **Step 1: Create category page**

```dart
// app/lib/tools/account/pages/category_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/category.dart';
import '../models/record.dart';
import '../services/account_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  RecordType _type = RecordType.expense;
  List<Category> _categories = [];
  Map<int, List<Category>> _subCategories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final categories = await AccountService.getCategories(_type);
    final subCategories = <int, List<Category>>{};

    for (final cat in categories) {
      if (cat.id != null) {
        final subs = await AccountService.getSubCategories(cat.id!);
        subCategories[cat.id!] = subs;
      }
    }

    setState(() {
      _categories = categories;
      _subCategories = subCategories;
      _isLoading = false;
    });
  }

  void _switchType(RecordType type) {
    setState(() => _type = type);
    _loadData();
  }

  Future<void> _addCategory() async {
    final result = await _showCategoryDialog();
    if (result != null) {
      final category = Category(
        name: result['name'] as String,
        icon: result['icon'] as String,
        type: _type,
        parentId: result['parentId'] as int? ?? 0,
      );
      await AccountService.insertCategory(category);
      _loadData();
    }
  }

  Future<void> _editCategory(Category category) async {
    if (category.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预设分类不可编辑')),
      );
      return;
    }

    final result = await _showCategoryDialog(category: category);
    if (result != null) {
      final updated = category.copyWith(
        name: result['name'] as String,
        icon: result['icon'] as String,
      );
      await AccountService.updateCategory(updated);
      _loadData();
    }
  }

  Future<void> _hideCategory(Category category) async {
    if (!category.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('只能隐藏预设分类')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐藏分类'),
        content: Text('确定要隐藏 "${category.name}" 吗？隐藏后该分类将不再显示，但已有记录会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('隐藏'),
          ),
        ],
      ),
    );

    if (confirm == true && category.id != null) {
      await AccountService.hideCategory(category.id!);
      _loadData();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    if (category.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预设分类不能删除')),
      );
      return;
    }

    if (category.id == null) return;

    // Check if category has records
    final recordCount = await AccountService.getRecordCountByCategory(category.id!);

    if (recordCount > 0) {
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('分类有关联记录'),
          content: Text('"${category.name}" 下有 $recordCount 条记录。请选择处理方式：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'move'),
              child: const Text('移至"其他"'),
            ),
          ],
        ),
      );

      if (choice == 'move') {
        // Find "其他" category
        final otherCategory = _categories.firstWhere(
          (c) => c.name == '其他',
          orElse: () => category,
        );
        if (otherCategory.id != null) {
          await AccountService.updateRecordsCategory(category.id!, otherCategory.id!);
          await AccountService.deleteCategory(category.id!);
          _loadData();
        }
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除 "${category.name}" 吗？'),
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

      if (confirm == true) {
        await AccountService.deleteCategory(category.id!);
        _loadData();
      }
    }
  }

  Future<Map<String, dynamic>?> _showCategoryDialog({Category? category}) async {
    final nameController = TextEditingController(text: category?.name);
    final iconController = TextEditingController(text: category?.icon ?? '📝');
    int? parentId = category?.parentId ?? 0;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? '添加分类' : '编辑分类'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: '图标 (Emoji)',
                  hintText: '📝',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  hintText: '输入分类名称',
                ),
              ),
              if (category == null) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  value: parentId == 0 ? null : parentId,
                  decoration: const InputDecoration(labelText: '上级分类'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('一级分类'),
                    ),
                    ..._categories.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.icon} ${c.name}'),
                    )),
                  ],
                  onChanged: (value) => parentId = value ?? 0,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'icon': iconController.text.isEmpty ? '📝' : iconController.text,
                  'parentId': parentId,
                });
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
        actions: [
          TextButton(
            onPressed: _addCategory,
            child: const Text('添加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeToggle(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final subs = _subCategories[category.id] ?? [];
                          return _buildCategoryItem(category, subs);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: '支出',
                isSelected: _type == RecordType.expense,
                color: AppColors.error,
                onTap: () => _switchType(RecordType.expense),
              ),
            ),
            Expanded(
              child: _TypeButton(
                label: '收入',
                isSelected: _type == RecordType.income,
                color: AppColors.success,
                onTap: () => _switchType(RecordType.income),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            '暂无分类',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category, List<Category> subs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
        title: Text(category.name),
        subtitle: category.isPreset
            ? const Text('预设', style: TextStyle(fontSize: 12, color: Colors.grey))
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editCategory(category);
                break;
              case 'hide':
                _hideCategory(category);
                break;
              case 'delete':
                _deleteCategory(category);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!category.isPreset)
              const PopupMenuItem(value: 'edit', child: Text('编辑')),
            if (category.isPreset)
              const PopupMenuItem(value: 'hide', child: Text('隐藏')),
            if (!category.isPreset)
              const PopupMenuItem(
                value: 'delete',
                child: Text('删除', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        children: subs.map((sub) => _buildSubCategoryItem(sub)).toList(),
      ),
    );
  }

  Widget _buildSubCategoryItem(Category sub) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      leading: Text(sub.icon, style: const TextStyle(fontSize: 20)),
      title: Text(sub.name, style: const TextStyle(fontSize: 14)),
      dense: true,
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/account/pages/category_page.dart
git commit -m "feat(account): add category management page with CRUD operations"
```

---

## Task 11: Register Account Tool in Main

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: Add import and registration**

```dart
// Add import after line 23:
import 'tools/account/account_tool.dart';

// Add registration after line 42:
ToolRegistry.register(AccountTool());
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat(account): register account tool in app"
```

---

## Task 12: Final Verification

- [ ] **Step 1: Run build verification**

```bash
cd app && flutter analyze
```

Expected: No errors in the new account files.

- [ ] **Step 2: Commit any fixes if needed**

```bash
git add -A
git commit -m "fix(account): resolve analysis issues"
```

---

## Summary

This implementation plan creates a complete personal finance tracking tool with:

1. **Database Layer**: Three tables (account_records, account_categories, account_budgets) with proper indexes
2. **Models**: Record, Category, Budget, and statistics result models
3. **Service Layer**: Full CRUD operations, statistics queries, and preset category initialization
4. **UI Pages**:
   - Main page: Monthly summary, quick actions, recent records list
   - Add/Edit record: Amount input, type toggle, category picker, date selector
   - Statistics: Pie charts for expense/income by category, 6-month trend line chart
   - Budget: Progress tracking with visual indicators for over-budget categories
   - Category management: Two-level hierarchy, add/edit/hide/delete with record migration
5. **Widgets**: Category picker with two-level selection

The implementation follows existing patterns in the codebase (Todo, Calendar tools) and uses fl_chart for data visualization.
