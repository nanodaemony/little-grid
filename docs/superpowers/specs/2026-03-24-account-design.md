# 账本功能设计文档

## 概述

账本是一个个人日常收支记账工具，支持收支记录、分类管理、统计报表和预算管理功能。

## 功能需求

### 核心功能
- **记账**：记录收入和支出，支持分类、备注、日期
- **分类管理**：二级分类结构，支持Emoji/内置图标，预设+自定义
- **统计报表**：按月/年统计，分类饼图，趋势折线图
- **预算管理**：设置月度预算，进度展示，超支提醒

### 非功能需求
- 单账户模式（不区分现金/银行卡等）
- 本地数据存储（SQLite）
- 离线可用

## 数据模型

### Dart 模型类

#### Record（账单）

```dart
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
    required this.createdAt,
    required this.updatedAt,
  });

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

#### Category（分类）

```dart
enum IconType { emoji, asset }

class Category {
  final int? id;
  final String name;
  final String icon;
  final IconType iconType;
  final int parentId;  // 一级分类为0
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

#### Budget（预算）

```dart
class Budget {
  final int? id;
  final int categoryId;
  final String month;  // 格式：YYYY-MM
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    this.id,
    required this.categoryId,
    required this.month,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

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

#### 统计结果模型

```dart
/// 月度统计结果
class MonthlySummary {
  final double income;
  final double expense;

  MonthlySummary({required this.income, required this.expense});

  double get balance => income - expense;
}

/// 分类统计结果
class CategoryStats {
  final Category category;
  final double amount;

  CategoryStats({required this.category, required this.amount});
}

/// 月度趋势数据
class TrendData {
  final String month;
  final double income;
  final double expense;

  TrendData({required this.month, required this.income, required this.expense});
}

/// 预算与分类关联
class BudgetWithCategory {
  final Budget budget;
  final Category category;

  BudgetWithCategory({required this.budget, required this.category});
}
```

### 数据库表结构

#### 账单表 (account_records)

| 字段 | 类型 | 说明 |
|-----|------|-----|
| id | INTEGER | 主键，自增 |
| amount | REAL | 金额 |
| type | INTEGER | 类型：1=支出，2=收入 |
| category_id | INTEGER | 一级分类ID |
| sub_category_id | INTEGER | 二级分类ID（可空） |
| date | INTEGER | 日期时间戳（毫秒） |
| note | TEXT | 备注 |
| created_at | INTEGER | 创建时间戳 |
| updated_at | INTEGER | 更新时间戳 |

**索引**：
- `idx_account_records_date` ON (date) - 用于日期范围查询
- `idx_account_records_category` ON (category_id) - 用于分类统计

#### 分类表 (account_categories)

| 字段 | 类型 | 说明 |
|-----|------|-----|
| id | INTEGER | 主键，自增 |
| name | TEXT | 分类名称 |
| icon | TEXT | 图标（Emoji或资源路径） |
| icon_type | INTEGER | 图标类型：1=Emoji，2=内置资源 |
| parent_id | INTEGER | 父分类ID（一级分类为0） |
| type | INTEGER | 类型：1=支出，2=收入 |
| sort_order | INTEGER | 排序权重 |
| is_preset | INTEGER | 是否预设：0=自定义，1=预设 |
| is_hidden | INTEGER | 是否隐藏：0=显示，1=隐藏 |

**索引**：
- `idx_account_categories_parent` ON (parent_id) - 用于查询二级分类

#### 预算表 (account_budgets)

| 字段 | 类型 | 说明 |
|-----|------|-----|
| id | INTEGER | 主键，自增 |
| category_id | INTEGER | 分类ID（一级分类） |
| month | TEXT | 月份（格式：YYYY-MM） |
| amount | REAL | 预算金额 |
| created_at | INTEGER | 创建时间戳 |
| updated_at | INTEGER | 更新时间戳 |

**索引**：
- `idx_account_budgets_category_month` ON (category_id, month) - 用于预算查询

**唯一约束**：
- UNIQUE (category_id, month) - 同一分类同月只能有一条预算记录

### 业务规则

#### 分类删除规则
- **预设分类**：不可删除，只能隐藏（设置 `is_hidden = 1`）
- **自定义分类**：可删除，但需检查是否有关联账单
  - 若有关联账单，提示用户选择：
    - 将账单移至"其他"分类
    - 取消删除
  - 若无关联账单，直接删除

#### 子分类验证
保存账单时，若指定了 `sub_category_id`，需验证：
1. 该二级分类存在且未隐藏
2. 该二级分类的 `parent_id` 等于账单的 `category_id`

#### 金额精度
金额使用 `double` 类型存储。对于个人记账场景，double 精度足够（支持约15位有效数字）。显示时使用 `amount.toStringAsFixed(2)` 保留两位小数。

### 数据库迁移说明

数据库当前版本为4，账本功能需要在 `_onCreate` 和 `_onUpgrade` 中添加新表。

**迁移步骤**：
1. 修改 `AppConstants.dbVersion` 从 4 改为 5
2. 在 `_onCreate` 中添加表和索引
3. 在 `_onUpgrade` 中添加 `if (oldVersion < 5)` 分支创建新表和索引
4. 首次启动时初始化预设分类数据

**建表SQL**：

```sql
-- 账单表
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
);

CREATE INDEX idx_account_records_date ON account_records(date);
CREATE INDEX idx_account_records_category ON account_records(category_id);

-- 分类表
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
);

CREATE INDEX idx_account_categories_parent ON account_categories(parent_id);

-- 预算表
CREATE TABLE account_budgets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_id INTEGER NOT NULL,
  month TEXT NOT NULL,
  amount REAL NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  UNIQUE (category_id, month)
);

CREATE INDEX idx_account_budgets_category_month ON account_budgets(category_id, month);
```

**与现有 ledger 表的关系**：
- 现有 `ledger_records` 和 `ledger_categories` 表保持不变，可能被其他功能使用
- 新的 account_* 表是独立的账本功能，支持更复杂的二级分类和预算功能
- 两个表结构不兼容，不进行数据迁移

## 预设分类

### 支出类

| 一级分类 | 二级分类 |
|---------|---------|
| 🍚 餐饮 | 🍜 早餐、🍱 午餐、🍲 晚餐、☕ 饮料、🍰 零食 |
| 🚌 交通 | 🚇 地铁、🚌 公交、🚗 打车、⛽ 加油、🅿️ 停车 |
| 🛒 购物 | 👔 服饰、👟 鞋包、💄 化妆品、🏠 日用品、📱 数码 |
| 🏠 居住 | 💰 房租、💡 水电、🔥 燃气、📶 网费、🔧 维修 |
| 🎮 娱乐 | 🎬 电影、🎮 游戏、🎤 KTV、📚 书籍、✈️ 旅游 |
| 🏥 医疗 | 💊 药品、🏥 门诊、🦷 牙科、👓 眼镜 |
| 📚 教育 | 📖 培训、📕 书籍、🎓 学费、🎹 兴趣班 |
| 🐾 宠物 | 🐱 猫粮、🐾 猫砂、🐶 狗粮、💉 疫苗、🏥 宠物医疗 |
| 💝 人情 | 🎁 礼物、💒 红包、🎂 生日、💍 婚庆 |
| 💳 其他 | 📝 其他支出 |

### 收入类

| 一级分类 | 二级分类 |
|---------|---------|
| 💵 工资 | 💰 基本工资、🎁 奖金、📈 加班费 |
| 💼 兼职 | 💻 自由职业、📝 兼职收入 |
| 📈 理财 | 📊 股票、💰 基金、🏦 利息 |
| 🎁 其他 | 📝 其他收入 |

## 页面设计

### 首页（概览页）
- 顶部：本月概览卡片（收入/支出/结余）
- 中部：快速记账按钮
- 下部：最近账单列表（按日期分组，显示分类图标、金额、备注）

### 记账页
- 金额输入（数字键盘）
- 收入/支出切换
- 分类选择（一级 → 二级，弹窗选择）
- 日期选择（默认今天）
- 备注输入
- 保存/取消按钮

### 统计页
- 顶部：月份切换器
- 收支概览卡片（本月收入/支出/结余）
- 支出分类饼图
- 收入分类饼图
- 月度趋势折线图（近6个月）

### 预算页
- 本月预算总览（总预算/已用/剩余）
- 各分类预算列表（进度条显示）
- 超支分类红色高亮提醒
- 点击可编辑预算金额

### 分类管理页
- 分类列表（一级+二级层级展示）
- 添加自定义分类按钮
- 编辑/删除分类（预设分类不可删除，可隐藏）

## 技术架构

### 目录结构
```
app/lib/tools/account/
├── account_tool.dart          # 工具入口
├── account_page.dart          # 首页（概览）
├── models/
│   ├── record.dart            # 账单模型
│   ├── category.dart          # 分类模型
│   ├── budget.dart            # 预算模型
│   └── stats_models.dart      # 统计结果模型
├── services/
│   └── account_service.dart   # 业务逻辑（增删改查）
├── pages/
│   ├── add_record_page.dart   # 记账页
│   ├── stats_page.dart        # 统计页
│   ├── budget_page.dart       # 预算页
│   └── category_page.dart     # 分类管理页
└── widgets/
    ├── record_list_item.dart  # 账单列表项
    ├── category_picker.dart   # 分类选择器
    ├── pie_chart.dart         # 饼图组件
    ├── trend_chart.dart       # 趋势图组件
    └── budget_progress.dart   # 预算进度条
```

### 依赖

**图表库**：使用 `fl_chart` 库实现饼图和折线图
- 在 `pubspec.yaml` 中添加依赖：`fl_chart: ^0.66.0`
- 饼图使用 `PieChart` 组件
- 趋势图使用 `LineChart` 组件

### 服务层

#### AccountService API

```dart
class AccountService {
  /// 初始化预设分类
  /// 检查 account_categories 表是否为空，为空则插入预设分类
  /// 后续启动不会重复插入
  static Future<void> initPresetCategories() async;

  // ========== 账单操作 ==========

  /// 插入账单记录
  static Future<int> insertRecord(Record record) async;

  /// 更新账单记录
  static Future<int> updateRecord(Record record) async;

  /// 删除账单记录
  static Future<int> deleteRecord(int id) async;

  /// 获取账单列表（按日期倒序）
  /// 可按日期范围、分类筛选，可限制数量
  static Future<List<Record>> getRecords({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    int? limit,
  }) async;

  /// 获取单条账单
  static Future<Record?> getRecordById(int id) async;

  /// 批量更新账单分类（用于删除分类前迁移账单）
  static Future<int> updateRecordsCategory(int oldCategoryId, int newCategoryId) async;

  /// 获取某分类下的账单数量
  static Future<int> getRecordCountByCategory(int categoryId) async;

  // ========== 统计查询 ==========

  /// 获取月度统计（总收入、总支出）
  static Future<MonthlySummary> getMonthlySummary(String month) async;

  /// 获取分类统计（按一级分类聚合）
  static Future<List<CategoryStats>> getCategoryStats(
    String month,
    RecordType type,
  ) async;

  /// 获取近N个月趋势数据
  static Future<List<TrendData>> getTrendData(int months) async;

  // ========== 分类操作 ==========

  /// 获取所有一级分类
  static Future<List<Category>> getCategories(RecordType type) async;

  /// 获取二级分类
  static Future<List<Category>> getSubCategories(int parentId) async;

  /// 插入自定义分类
  static Future<int> insertCategory(Category category) async;

  /// 更新分类
  static Future<int> updateCategory(Category category) async;

  /// 隐藏分类（预设分类只能隐藏）
  static Future<int> hideCategory(int id) async;

  /// 删除自定义分类（仅无关联账单时可删除）
  /// 返回：成功删除返回1，有关联账单返回0
  static Future<int> deleteCategory(int id) async;

  // ========== 预算操作 ==========

  /// 获取月度预算列表
  static Future<List<BudgetWithCategory>> getBudgets(String month) async;

  /// 设置分类预算
  static Future<int> setBudget(int categoryId, String month, double amount) async;

  /// 获取分类本月支出
  static Future<double> getCategorySpending(int categoryId, String month) async;
}
```

## 数据流

### 记账流程
1. 用户点击快速记账 → 打开记账页
2. 输入金额、选择收支类型、选择分类、填写备注
3. 点击保存 → 调用 AccountService.insertRecord()
4. 写入 account_records 表 → 返回首页刷新列表

### 编辑账单流程
1. 用户在账单列表点击某条账单 → 打开记账页（预填数据）
2. 修改金额/分类/备注等
3. 点击保存 → 调用 AccountService.updateRecord()
4. 更新 account_records 表 → 返回首页刷新列表

### 删除账单流程
1. 用户在账单列表左滑或长按 → 显示删除选项
2. 确认删除 → 调用 AccountService.deleteRecord()
3. 从 account_records 表删除 → 刷新列表

### 统计展示
1. 进入统计页 → 选择月份
2. 查询该月账单，按分类聚合计算
3. 生成饼图数据、趋势图数据
4. 渲染图表

### 预算管理
1. 进入预算页 → 查询本月各分类预算设置
2. 查询本月各分类实际支出
3. 计算进度百分比，渲染进度条
4. 超支分类显示红色提醒

## 工具注册

工具分类：`ToolCategory.life`（生活实用）

```dart
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
    // 初始化预设分类
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