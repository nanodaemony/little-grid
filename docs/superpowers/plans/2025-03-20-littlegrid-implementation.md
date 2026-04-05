# 小方格 (LittleGrid) APP 实现计划

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个 Flutter 多工具集合 APP，包含投硬币、骰子、待办清单等工具，采用模块化架构严格隔离各工具。

**Architecture:** 采用模块化插件架构，每个工具实现 ToolModule 接口独立开发；使用 Provider 全局状态管理；SQLite (sqflite) 本地存储；瀑布流格子页展示工具入口。

**Tech Stack:** Flutter 3.x + Dart + Provider + sqflite + fl_chart + flutter_localizations

---

## 文件结构规划

```
app/
├── lib/
│   ├── core/                          # 核心框架
│   │   ├── constants/
│   │   │   ├── app_constants.dart     # 应用常量
│   │   │   └── theme_constants.dart   # 主题常量
│   │   ├── models/
│   │   │   ├── tool_config.dart       # 工具配置模型
│   │   │   └── usage_stat.dart        # 使用统计模型
│   │   ├── services/
│   │   │   ├── database_service.dart  # 数据库服务
│   │   │   ├── storage_service.dart   # 存储服务
│   │   │   ├── usage_service.dart     # 使用统计服务
│   │   │   └── tool_registry.dart     # 工具注册表
│   │   ├── ui/
│   │   │   ├── theme.dart             # 主题定义
│   │   │   ├── app_colors.dart        # 颜色定义
│   │   │   └── common_widgets.dart    # 通用组件
│   │   └── utils/
│   │       └── logger.dart            # 日志工具
│   ├── tools/                         # 工具模块（严格隔离）
│   │   ├── coin/                      # 投硬币
│   │   │   ├── coin_tool.dart         # 工具实现
│   │   │   ├── coin_page.dart         # 页面
│   │   │   └── widgets/               # 专属组件
│   │   ├── dice/                      # 骰子
│   │   ├── todo/                      # 待办清单
│   │   ├── ledger/                    # 记账本
│   │   ├── wheel/                     # 大转盘
│   │   ├── card/                      # 翻扑克牌
│   │   └── calculator/                # 房贷计算器
│   ├── pages/                         # 主页面
│   │   ├── grid_page.dart             # 格子页（首页）
│   │   ├── profile_page.dart          # 我的页面
│   │   └── settings_page.dart         # 设置页
│   ├── providers/                     # 全局状态
│   │   ├── app_provider.dart          # 应用状态
│   │   └── theme_provider.dart        # 主题状态
│   ├── l10n/                          # 国际化
│   │   ├── app_zh.arb
│   │   └── app_en.arb
│   └── main.dart                      # 入口
├── test/                              # 测试
│   ├── core/
│   └── tools/
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Chunk 1: 项目初始化与核心框架搭建

### Task 1: 创建 Flutter 项目

**Files:**
- Create: `app/pubspec.yaml`
- Create: `app/analysis_options.yaml`
- Create: `app/.gitignore`
- Create: `app/lib/main.dart`

- [ ] **Step 1: 创建 Flutter 项目骨架**

```bash
cd /Users/nano/claude/littlegrid
flutter create --project-name littlegrid --org com.littlegrid app
```

Expected: 创建成功，显示 "Created project app"

- [ ] **Step 2: 添加依赖到 pubspec.yaml**

Create: `app/pubspec.yaml`

```yaml
name: littlegrid
description: 小方格 - 实用工具集合

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

  # 状态管理
  provider: ^6.1.1

  # 数据库
  sqflite: ^2.3.0
  path: ^1.8.3

  # 图表
  fl_chart: ^0.66.0

  # 图片选择
  image_picker: ^1.0.7

  # 日志
  logger: ^2.0.2

  # 动画
  flutter_animate: ^4.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/web/
```

- [ ] **Step 3: 获取依赖**

```bash
cd app
flutter pub get
```

Expected: 成功获取所有依赖

- [ ] **Step 4: Commit**

```bash
git add app/
git commit -m "chore: initialize Flutter project with dependencies"
```

---

### Task 2: 创建核心常量与主题

**Files:**
- Create: `app/lib/core/constants/app_constants.dart`
- Create: `app/lib/core/constants/theme_constants.dart`
- Create: `app/lib/core/ui/app_colors.dart`

- [ ] **Step 1: 创建 App 常量**

Create: `app/lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = '小方格';
  static const String appNameEn = 'LittleGrid';
  static const String version = '1.0.0';

  // 数据库
  static const String dbName = 'littlegrid.db';
  static const int dbVersion = 1;

  // 分类
  static const String categoryLife = 'life';
  static const String categoryGame = 'game';
  static const String categoryCalc = 'calc';

  static const Map<String, String> categoryNames = {
    categoryLife: '生活',
    categoryGame: '趣味',
    categoryCalc: '计算',
  };
}
```

- [ ] **Step 2: 创建主题常量**

Create: `app/lib/core/constants/theme_constants.dart`

```dart
class ThemeConstants {
  ThemeConstants._();

  // 圆角
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // 间距
  static const double spacingSmall = 4.0;
  static const double spacingMedium = 8.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;

  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;

  // 动画时长
  static const Duration animationShort = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
}
```

- [ ] **Step 3: 创建颜色定义**

Create: `app/lib/core/ui/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 主色调 - 淡蓝色系
  static const Color primary = Color(0xFF5B9BD5);
  static const Color primaryLight = Color(0xFFBDD7EE);
  static const Color primaryDark = Color(0xFF2E5C8A);

  // 中性色
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);

  // 文字颜色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);

  // 功能色
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFFF4D4F);
  static const Color info = Color(0xFF1890FF);

  // 分类颜色
  static const Color categoryLife = Color(0xFF52C41A);
  static const Color categoryGame = Color(0xFFFA8C16);
  static const Color categoryCalc = Color(0xFF1890FF);
}
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/core/
git commit -m "feat: add core constants and color definitions"
```

---

### Task 3: 创建主题定义

**Files:**
- Create: `app/lib/core/ui/theme.dart`

- [ ] **Step 1: 创建应用主题**

Create: `app/lib/core/ui/theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/theme_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: ThemeConstants.fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: ThemeConstants.fontSizeXXLarge,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: ThemeConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: ThemeConstants.fontSizeLarge,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: ThemeConstants.fontSizeMedium,
          color: AppColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: ThemeConstants.fontSizeSmall,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // MVP 阶段先不实现深色主题，返回 lightTheme
    return lightTheme;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/core/ui/theme.dart
git commit -m "feat: add app theme definition"
```

---

### Task 4: 创建日志工具

**Files:**
- Create: `app/lib/core/utils/logger.dart`

- [ ] **Step 1: 创建日志工具类**

Create: `app/lib/core/utils/logger.dart`

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

class AppLogger {
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/core/utils/logger.dart
git commit -m "feat: add logger utility"
```

---

## Chunk 2: 数据库服务与模型

### Task 5: 创建数据模型

**Files:**
- Create: `app/lib/core/models/tool_config.dart`
- Create: `app/lib/core/models/usage_stat.dart`

- [ ] **Step 1: 创建工具配置模型**

Create: `app/lib/core/models/tool_config.dart`

```dart
class ToolConfig {
  final String id;
  final String name;
  final String category;
  final int sortOrder;
  final bool isPinned;
  final int useCount;
  final DateTime? lastUsedAt;
  final int gridSize;

  ToolConfig({
    required this.id,
    required this.name,
    required this.category,
    this.sortOrder = 0,
    this.isPinned = false,
    this.useCount = 0,
    this.lastUsedAt,
    this.gridSize = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sort_order': sortOrder,
      'is_pinned': isPinned ? 1 : 0,
      'use_count': useCount,
      'last_used_at': lastUsedAt?.millisecondsSinceEpoch,
      'grid_size': gridSize,
    };
  }

  factory ToolConfig.fromMap(Map<String, dynamic> map) {
    return ToolConfig(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      useCount: map['use_count'] as int? ?? 0,
      lastUsedAt: map['last_used_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_used_at'] as int)
          : null,
      gridSize: map['grid_size'] as int? ?? 1,
    );
  }

  ToolConfig copyWith({
    String? id,
    String? name,
    String? category,
    int? sortOrder,
    bool? isPinned,
    int? useCount,
    DateTime? lastUsedAt,
    int? gridSize,
  }) {
    return ToolConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      isPinned: isPinned ?? this.isPinned,
      useCount: useCount ?? this.useCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      gridSize: gridSize ?? this.gridSize,
    );
  }
}
```

- [ ] **Step 2: 创建使用统计模型**

Create: `app/lib/core/models/usage_stat.dart`

```dart
class UsageStat {
  final int? id;
  final String toolId;
  final DateTime usedAt;
  final int? duration;

  UsageStat({
    this.id,
    required this.toolId,
    required this.usedAt,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tool_id': toolId,
      'used_at': usedAt.millisecondsSinceEpoch,
      'duration': duration,
    };
  }

  factory UsageStat.fromMap(Map<String, dynamic> map) {
    return UsageStat(
      id: map['id'] as int?,
      toolId: map['tool_id'] as String,
      usedAt: DateTime.fromMillisecondsSinceEpoch(map['used_at'] as int),
      duration: map['duration'] as int?,
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/core/models/
git commit -m "feat: add ToolConfig and UsageStat models"
```

---

### Task 6: 创建数据库服务

**Files:**
- Create: `app/lib/core/services/database_service.dart`

- [ ] **Step 1: 创建数据库服务**

Create: `app/lib/core/services/database_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.dbName);

    AppLogger.i('Initializing database at: $path');

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('Creating database tables...');

    // 工具配置表
    await db.execute('''
      CREATE TABLE tool_configs (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_pinned INTEGER DEFAULT 0,
        use_count INTEGER DEFAULT 0,
        last_used_at INTEGER,
        grid_size INTEGER DEFAULT 1
      )
    ''');

    // 使用统计表
    await db.execute('''
      CREATE TABLE usage_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tool_id TEXT NOT NULL,
        used_at INTEGER NOT NULL,
        duration INTEGER
      )
    ''');

    // 用户配置表
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        type TEXT DEFAULT 'string'
      )
    ''');

    // 待办清单表
    await db.execute('''
      CREATE TABLE todo_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        priority INTEGER DEFAULT 1,
        due_date INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    // 记账记录表
    await db.execute('''
      CREATE TABLE ledger_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        account TEXT,
        date INTEGER NOT NULL,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 记账分类表
    await db.execute('''
      CREATE TABLE ledger_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 大转盘选项表
    await db.execute('''
      CREATE TABLE wheel_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tool_id TEXT NOT NULL,
        name TEXT NOT NULL,
        color TEXT,
        probability REAL DEFAULT 1.0,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // 房贷计算历史表
    await db.execute('''
      CREATE TABLE mortgage_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_amount REAL NOT NULL,
        loan_years INTEGER NOT NULL,
        interest_rate REAL NOT NULL,
        repayment_type TEXT NOT NULL,
        monthly_payment REAL,
        total_interest REAL,
        total_amount REAL,
        calculated_at INTEGER NOT NULL
      )
    ''');

    AppLogger.i('Database tables created successfully');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    AppLogger.i('Upgrading database from $oldVersion to $newVersion');
    // 数据库升级逻辑
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/core/services/database_service.dart
git commit -m "feat: add database service with table definitions"
```

---

### Task 7: 创建工具配置存储服务

**Files:**
- Create: `app/lib/core/services/storage_service.dart`

- [ ] **Step 1: 创建存储服务**

Create: `app/lib/core/services/storage_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/tool_config.dart';
import '../utils/logger.dart';

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
    final db = await DatabaseService.database;
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
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/core/services/storage_service.dart
git commit -m "feat: add storage service for tool configs and settings"
```

---

### Task 8: 创建使用统计服务

**Files:**
- Create: `app/lib/core/services/usage_service.dart`

- [ ] **Step 1: 创建使用统计服务**

Create: `app/lib/core/services/usage_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import '../models/usage_stat.dart';
import '../utils/logger.dart';

class UsageService {
  static final Map<String, DateTime> _sessionStartTimes = {};

  static void recordEnter(String toolId) {
    _sessionStartTimes[toolId] = DateTime.now();
    AppLogger.d('Tool entered: $toolId');
  }

  static Future<void> recordExit(String toolId) async {
    final startTime = _sessionStartTimes[toolId];
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime).inSeconds;

    await recordUsage(UsageStat(
      toolId: toolId,
      usedAt: startTime,
      duration: duration,
    ));

    _sessionStartTimes.remove(toolId);
    AppLogger.d('Tool exited: $toolId, duration: ${duration}s');
  }

  static Future<void> recordUsage(UsageStat stat) async {
    final db = await DatabaseService.database;
    await db.insert('usage_stats', stat.toMap());
  }

  static Future<List<UsageStat>> getUsageStats({String? toolId}) async {
    final db = await DatabaseService.database;

    String? where;
    List<Object?>? whereArgs;

    if (toolId != null) {
      where = 'tool_id = ?';
      whereArgs = [toolId];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'usage_stats',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'used_at DESC',
    );

    return maps.map((map) => UsageStat.fromMap(map)).toList();
  }

  static Future<Map<String, int>> getUsageCounts() async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery('''
      SELECT tool_id, COUNT(*) as count
      FROM usage_stats
      GROUP BY tool_id
    ''');

    return {
      for (var row in result) row['tool_id'] as String: row['count'] as int,
    };
  }

  static Future<void> clearOldStats({int daysToKeep = 90}) async {
    final db = await DatabaseService.database;
    final cutoff = DateTime.now().subtract(Duration(days: daysToKeep));

    await db.delete(
      'usage_stats',
      where: 'used_at < ?',
      whereArgs: [cutoff.millisecondsSinceEpoch],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/core/services/usage_service.dart
git commit -m "feat: add usage tracking service"
```

---

## Chunk 3: 工具模块接口与注册表

### Task 9: 创建工具模块抽象类

**Files:**
- Create: `app/lib/core/services/tool_registry.dart`

- [ ] **Step 1: 创建工具模块接口和注册表**

Create: `app/lib/core/services/tool_registry.dart`

```dart
import 'package:flutter/material.dart';

/// 工具分类
enum ToolCategory {
  life,   // 生活实用
  game,   // 趣味随机
  calc,   // 计算工具
}

/// 工具设置接口
abstract class ToolSettings {
  String get title;
  Widget buildSettingsPage();
  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
}

/// 工具模块接口 - 每个工具必须实现
abstract class ToolModule {
  /// 唯一标识（如：coin, dice, todo）
  String get id;

  /// 显示名称（如：投硬币）
  String get name;

  /// 版本号（如：1.0.0）
  String get version;

  /// 图标
  IconData get icon;

  /// 分类
  ToolCategory get category;

  /// 格子大小（1=小，2=大）
  int get gridSize;

  /// 构建工具页面
  Widget buildPage(BuildContext context);

  /// 可选：工具设置页面
  ToolSettings? get settings;

  /// 初始化时调用
  Future<void> onInit() async {}

  /// 销毁时调用
  Future<void> onDispose() async {}

  /// 进入工具时调用
  void onEnter() {}

  /// 退出工具时调用
  void onExit() {}
}

/// 工具注册表 - 管理所有工具
class ToolRegistry {
  static final Map<String, ToolModule> _tools = {};

  /// 注册工具
  static void register(ToolModule tool) {
    _tools[tool.id] = tool;
    tool.onInit();
    debugPrint('Tool registered: ${tool.id}');
  }

  /// 批量注册工具
  static void registerAll(List<ToolModule> tools) {
    for (final tool in tools) {
      register(tool);
    }
  }

  /// 获取工具
  static ToolModule? get(String id) => _tools[id];

  /// 获取所有工具
  static List<ToolModule> getAll() => _tools.values.toList();

  /// 获取指定分类的工具
  static List<ToolModule> getByCategory(ToolCategory category) {
    return _tools.values
        .where((tool) => tool.category == category)
        .toList();
  }

  /// 注销工具
  static Future<void> unregister(String id) async {
    final tool = _tools[id];
    if (tool != null) {
      await tool.onDispose();
      _tools.remove(id);
    }
  }

  /// 清空所有工具
  static Future<void> clear() async {
    for (final tool in _tools.values) {
      await tool.onDispose();
    }
    _tools.clear();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/core/services/tool_registry.dart
git commit -m "feat: add ToolModule interface and ToolRegistry"
```

---

## Chunk 4: 第一个工具 - 投硬币

### Task 10: 创建投硬币工具

**Files:**
- Create: `app/lib/tools/coin/coin_tool.dart`
- Create: `app/lib/tools/coin/coin_page.dart`

- [ ] **Step 1: 创建投硬币页面**

Create: `app/lib/tools/coin/coin_page.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ui/app_colors.dart';
import '../../core/constants/theme_constants.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipping = false;
  bool? _isHeads; // true=正面, false=反面
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCoin() {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    _controller.forward(from: 0).then((_) {
      setState(() {
        _isHeads = _random.nextBool();
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投硬币'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 硬币显示
            GestureDetector(
              onTap: _flipCoin,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final angle = _controller.value * 4 * 3.14159;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getCoinColor(),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.amber.shade700,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: _isFlipping
                            ? const SizedBox()
                            : Text(
                                _getCoinText(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 48),

            // 结果文字
            if (!_isFlipping && _isHeads != null)
              Text(
                _isHeads! ? '正面' : '反面',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .scale(delay: 100.ms, duration: 300.ms)
                  .fadeIn(),

            const SizedBox(height: 48),

            // 投掷按钮
            ElevatedButton.icon(
              onPressed: _isFlipping ? null : _flipCoin,
              icon: const Icon(Icons.refresh),
              label: const Text('投硬币'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoinColor() {
    if (_isFlipping) return Colors.amber;
    return (_isHeads == null || _isHeads!) ? Colors.amber : Colors.orange;
  }

  String _getCoinText() {
    if (_isHeads == null) return '?';
    return _isHeads! ? '正' : '反';
  }
}
```

- [ ] **Step 2: 创建投硬币工具模块**

Create: `app/lib/tools/coin/coin_tool.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'coin_page.dart';

class CoinTool implements ToolModule {
  @override
  String get id => 'coin';

  @override
  String get name => '投硬币';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.monetization_on;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const CoinPage();
  }

  @override
  ToolSettings? get settings => null;
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/coin/
git commit -m "feat: add coin flip tool"
```

---

## Chunk 5: 格子页布局与导航

### Task 11: 创建格子页

**Files:**
- Create: `app/lib/pages/grid_page.dart`
- Create: `app/lib/providers/app_provider.dart`

- [ ] **Step 1: 创建 AppProvider**

Create: `app/lib/providers/app_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../core/models/tool_config.dart';
import '../core/services/storage_service.dart';
import '../core/services/tool_registry.dart';
import '../core/utils/logger.dart';

class AppProvider extends ChangeNotifier {
  List<ToolConfig> _toolConfigs = [];
  bool _isLoading = true;

  List<ToolConfig> get toolConfigs => _toolConfigs;
  bool get isLoading => _isLoading;

  /// 初始化工具配置
  Future<void> initTools() async {
    _isLoading = true;
    notifyListeners();

    try {
      var configs = await StorageService.getToolConfigs();

      // 如果没有配置，创建默认配置
      if (configs.isEmpty) {
        configs = _createDefaultConfigs();
        await StorageService.saveToolConfigs(configs);
      }

      _toolConfigs = configs;
    } catch (e, stack) {
      AppLogger.e('Failed to init tools', e, stack);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 记录工具使用
  Future<void> recordToolUse(String toolId) async {
    await StorageService.updateToolUsage(toolId);
    await initTools(); // 刷新配置
  }

  /// 切换置顶状态
  Future<void> togglePin(String toolId) async {
    final config = _toolConfigs.firstWhere((c) => c.id == toolId);
    await StorageService.togglePin(toolId, !config.isPinned);
    await initTools();
  }

  /// 获取排序后的工具
  List<ToolConfig> getSortedTools() {
    final sorted = List<ToolConfig>.from(_toolConfigs);

    // 按置顶和最后使用时间排序
    sorted.sort((a, b) {
      // 置顶优先
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // 然后按最后使用时间
      if (a.lastUsedAt != null && b.lastUsedAt != null) {
        return b.lastUsedAt!.compareTo(a.lastUsedAt!);
      }
      if (a.lastUsedAt != null) return -1;
      if (b.lastUsedAt != null) return 1;

      return a.sortOrder.compareTo(b.sortOrder);
    });

    return sorted;
  }

  /// 创建默认配置
  List<ToolConfig> _createDefaultConfigs() {
    final tools = ToolRegistry.getAll();
    return tools.map((tool) => ToolConfig(
      id: tool.id,
      name: tool.name,
      category: tool.category.name,
      sortOrder: 0,
      gridSize: tool.gridSize,
    )).toList();
  }
}
```

- [ ] **Step 2: 创建格子页**

Create: `app/lib/pages/grid_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/tool_config.dart';
import '../core/services/tool_registry.dart';
import '../core/services/usage_service.dart';
import '../core/ui/app_colors.dart';
import '../providers/app_provider.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: 打开抽屉
          },
        ),
        title: const Text('小方格'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tools = provider.getSortedTools();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final config = tools[index];
                      return _ToolGridItem(config: config);
                    },
                    childCount: tools.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolGridItem extends StatelessWidget {
  final ToolConfig config;

  const _ToolGridItem({required this.config});

  @override
  Widget build(BuildContext context) {
    final tool = ToolRegistry.get(config.id);
    if (tool == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openTool(context, tool),
      onLongPress: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              size: 36,
              color: _getCategoryColor(tool.category),
            ),
            const SizedBox(height: 8),
            Text(
              tool.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (config.isPinned)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.push_pin,
                  size: 12,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openTool(BuildContext context, ToolModule tool) {
    UsageService.recordEnter(tool.id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => tool.buildPage(context)),
    ).then((_) {
      UsageService.recordExit(tool.id);
      context.read<AppProvider>().recordToolUse(tool.id);
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                config.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(config.isPinned ? '取消置顶' : '置顶'),
              onTap: () {
                context.read<AppProvider>().togglePin(config.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ToolCategory category) {
    switch (category) {
      case ToolCategory.life:
        return AppColors.categoryLife;
      case ToolCategory.game:
        return AppColors.categoryGame;
      case ToolCategory.calc:
        return AppColors.categoryCalc;
    }
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/pages/grid_page.dart app/lib/providers/app_provider.dart
git commit -m "feat: add grid page with tool items"
```

---

### Task 12: 创建主入口和底部导航

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 更新 main.dart**

Replace: `app/lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/tool_registry.dart';
import 'core/ui/theme.dart';
import 'pages/grid_page.dart';
import 'pages/profile_page.dart';
import 'providers/app_provider.dart';
import 'tools/coin/coin_tool.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册工具
  ToolRegistry.register(CoinTool());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: '小方格',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final _pages = const [
    GridPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化工具配置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().initTools();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: '格子',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 创建占位我的页面**

Create: `app/lib/pages/profile_page.dart`

```dart
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: const Center(
        child: Text('我的页面'),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/main.dart app/lib/pages/profile_page.dart
git commit -m "feat: add main app entry with bottom navigation"
```

---

## Chunk 6: 添加更多工具

### Task 13: 添加骰子工具

**Files:**
- Create: `app/lib/tools/dice/dice_tool.dart`
- Create: `app/lib/tools/dice/dice_page.dart`

- [ ] **Step 1: 创建骰子页面**

Create: `app/lib/tools/dice/dice_page.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  final Random _random = Random();
  List<int> _diceValues = [1];
  int _diceCount = 1;
  bool _isRolling = false;

  void _rollDice() {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
    });

    // 模拟滚动动画
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _diceValues = List.generate(
          _diceCount,
          (_) => _random.nextInt(6) + 1,
        );
        _isRolling = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('骰子'),
      ),
      body: Column(
        children: [
          // 骰子数量选择
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('骰子数量:'),
                const SizedBox(width: 16),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 1, label: Text('1')),
                    ButtonSegment(value: 2, label: Text('2')),
                    ButtonSegment(value: 3, label: Text('3')),
                  ],
                  selected: {_diceCount},
                  onSelectionChanged: (value) {
                    setState(() {
                      _diceCount = value.first;
                      _diceValues = List.filled(_diceCount, 1);
                    });
                  },
                ),
              ],
            ),
          ),

          // 骰子显示区
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: _diceValues.map((value) {
                  return _DiceWidget(
                    value: value,
                    isRolling: _isRolling,
                  );
                }).toList(),
              ),
            ),
          ),

          // 点数总和
          if (_diceValues.length > 1 && !_isRolling)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '总和: ${_diceValues.reduce((a, b) => a + b)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().scale(),
            ),

          // 投掷按钮
          Padding(
            padding: const EdgeInsets.all(32),
            child: ElevatedButton.icon(
              onPressed: _isRolling ? null : _rollDice,
              icon: const Icon(Icons.casino),
              label: const Text('投掷'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiceWidget extends StatelessWidget {
  final int value;
  final bool isRolling;

  const _DiceWidget({required this.value, required this.isRolling});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: isRolling
          ? const Center(child: CircularProgressIndicator())
          : _buildDots(value),
    ).animate(target: isRolling ? 1 : 0).shake();
  }

  Widget _buildDots(int value) {
    final dotColor = Colors.red.shade600;
    final dotSize = 12.0;

    Widget dot() => Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        );

    switch (value) {
      case 1:
        return Center(child: dot());
      case 2:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [dot(), const Spacer(), dot()],
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [dot(), Center(child: dot()), dot()],
          ),
        );
      case 4:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
            ],
          ),
        );
      case 5:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Center(child: dot()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
            ],
          ),
        );
      case 6:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
            ],
          ),
        );
      default:
        return Center(child: dot());
    }
  }
}
```

- [ ] **Step 2: 创建骰子工具模块**

Create: `app/lib/tools/dice/dice_tool.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'dice_page.dart';

class DiceTool implements ToolModule {
  @override
  String get id => 'dice';

  @override
  String get name => '骰子';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.casino;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const DicePage();
  }

  @override
  ToolSettings? get settings => null;
}
```

- [ ] **Step 3: 在 main.dart 注册骰子工具**

Modify: `app/lib/main.dart`

Add import:
```dart
import 'tools/dice/dice_tool.dart';
```

Add registration before runApp:
```dart
ToolRegistry.register(DiceTool());
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/tools/dice/ app/lib/main.dart
git commit -m "feat: add dice tool"
```

---

### Task 14: 添加翻扑克牌工具

**Files:**
- Create: `app/lib/tools/card/card_tool.dart`
- Create: `app/lib/tools/card/card_page.dart`

- [ ] **Step 1: 创建翻扑克牌页面**

Create: `app/lib/tools/card/card_page.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final Random _random = Random();
  PlayingCard? _currentCard;
  bool _isFlipping = false;

  final List<String> _suits = ['♠', '♥', '♣', '♦'];
  final List<String> _ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

  void _drawCard() {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentCard = PlayingCard(
          suit: _suits[_random.nextInt(_suits.length)],
          rank: _ranks[_random.nextInt(_ranks.length)],
        );
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('翻扑克牌'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 扑克牌
            GestureDetector(
              onTap: _drawCard,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 160,
                height: 240,
                decoration: BoxDecoration(
                  color: _currentCard == null ? Colors.blue.shade700 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _isFlipping
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _currentCard == null
                        ? Center(
                            child: Icon(
                              Icons.style,
                              size: 64,
                              color: Colors.blue.shade900,
                            ),
                          )
                        : _buildCardFace(_currentCard!),
              ),
            ),

            const SizedBox(height: 48),

            // 翻牌按钮
            ElevatedButton.icon(
              onPressed: _isFlipping ? null : _drawCard,
              icon: const Icon(Icons.style),
              label: const Text('翻牌'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace(PlayingCard card) {
    final isRed = card.suit == '♥' || card.suit == '♦';
    final color = isRed ? Colors.red : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 左上角
          Row(
            children: [
              Text(
                card.rank,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                card.suit,
                style: TextStyle(
                  fontSize: 20,
                  color: color,
                ),
              ),
            ],
          ),

          // 中间
          Expanded(
            child: Center(
              child: Text(
                card.suit,
                style: TextStyle(
                  fontSize: 64,
                  color: color,
                ),
              ),
            ),
          ),

          // 右下角（旋转180度）
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.rotate(
                angle: 3.14159,
                child: Row(
                  children: [
                    Text(
                      card.rank,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      card.suit,
                      style: TextStyle(
                        fontSize: 20,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlayingCard {
  final String suit;
  final String rank;

  PlayingCard({required this.suit, required this.rank});
}
```

- [ ] **Step 2: 创建翻扑克牌工具模块**

Create: `app/lib/tools/card/card_tool.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'card_page.dart';

class CardTool implements ToolModule {
  @override
  String get id => 'card';

  @override
  String get name => '翻扑克牌';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.style;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const CardPage();
  }

  @override
  ToolSettings? get settings => null;
}
```

- [ ] **Step 3: 注册工具并 Commit**

```bash
git add app/lib/tools/card/ app/lib/main.dart
git commit -m "feat: add card flip tool"
```

---

## Chunk 7: 待办清单工具

### Task 15: 创建待办清单数据层

**Files:**
- Create: `app/lib/tools/todo/todo_models.dart`
- Create: `app/lib/tools/todo/todo_service.dart`

- [ ] **Step 1: 创建待办模型**

Create: `app/lib/tools/todo/todo_models.dart`

```dart
enum TodoPriority { low, medium, high }

class TodoItem {
  final int? id;
  final String title;
  final bool isCompleted;
  final TodoPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  TodoItem({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = TodoPriority.medium,
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'priority': priority.index,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      priority: TodoPriority.values[map['priority'] as int],
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      notes: map['notes'] as String?,
    );
  }

  TodoItem copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    TodoPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}
```

- [ ] **Step 2: 创建待办服务**

Create: `app/lib/tools/todo/todo_service.dart`

```dart
import 'package:sqflite/sqflite.dart';
import '../../core/services/database_service.dart';
import 'todo_models.dart';

class TodoService {
  static Future<int> addTodo(TodoItem todo) async {
    final db = await DatabaseService.database;
    return await db.insert('todo_items', todo.toMap());
  }

  static Future<List<TodoItem>> getTodos({bool? isCompleted}) async {
    final db = await DatabaseService.database;

    String? where;
    List<dynamic>? whereArgs;

    if (isCompleted != null) {
      where = 'is_completed = ?';
      whereArgs = [isCompleted ? 1 : 0];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'todo_items',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'priority DESC, created_at DESC',
    );

    return maps.map((map) => TodoItem.fromMap(map)).toList();
  }

  static Future<void> updateTodo(TodoItem todo) async {
    final db = await DatabaseService.database;
    await db.update(
      'todo_items',
      todo.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  static Future<void> toggleComplete(int id, bool isCompleted) async {
    final db = await DatabaseService.database;
    await db.update(
      'todo_items',
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteTodo(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/todo/todo_models.dart app/lib/tools/todo/todo_service.dart
git commit -m "feat: add todo models and service"
```

---

### Task 16: 创建待办清单页面

**Files:**
- Create: `app/lib/tools/todo/todo_page.dart`
- Create: `app/lib/tools/todo/todo_tool.dart`

- [ ] **Step 1: 创建待办页面**

Create: `app/lib/tools/todo/todo_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';
import 'todo_models.dart';
import 'todo_service.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<TodoItem> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    final todos = await TodoService.getTodos();
    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todos.where((t) => t.isCompleted).length;
    final pendingCount = _todos.length - completedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('待办清单'),
        actions: [
          if (_todos.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '$pendingCount 待办 / $completedCount 完成',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _todos.isEmpty
              ? _buildEmptyState()
              : _buildTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
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
            Icons.check_circle_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无待办事项',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return _TodoItemCard(
          todo: todo,
          onToggle: () => _toggleComplete(todo),
          onEdit: () => _showEditDialog(todo),
          onDelete: () => _deleteTodo(todo),
        );
      },
    );
  }

  Future<void> _toggleComplete(TodoItem todo) async {
    await TodoService.toggleComplete(todo.id!, !todo.isCompleted);
    _loadTodos();
  }

  Future<void> _deleteTodo(TodoItem todo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${todo.title}" 吗？'),
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
      await TodoService.deleteTodo(todo.id!);
      _loadTodos();
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _TodoDialog(
        onSave: (title, priority, dueDate) async {
          final todo = TodoItem(
            title: title,
            priority: priority,
            dueDate: dueDate,
          );
          await TodoService.addTodo(todo);
          _loadTodos();
        },
      ),
    );
  }

  void _showEditDialog(TodoItem todo) {
    showDialog(
      context: context,
      builder: (context) => _TodoDialog(
        todo: todo,
        onSave: (title, priority, dueDate) async {
          final updated = todo.copyWith(
            title: title,
            priority: priority,
            dueDate: dueDate,
          );
          await TodoService.updateTodo(updated);
          _loadTodos();
        },
      ),
    );
  }
}

class _TodoItemCard extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TodoItemCard({
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: todo.dueDate != null
            ? Text(
                '截止: ${_formatDate(todo.dueDate!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: _isOverdue(todo.dueDate!) ? Colors.red : Colors.grey,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriorityIndicator(todo.priority),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(TodoPriority priority) {
    Color color;
    switch (priority) {
      case TodoPriority.high:
        color = Colors.red;
        break;
      case TodoPriority.medium:
        color = Colors.orange;
        break;
      case TodoPriority.low:
        color = Colors.green;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  bool _isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now()) &&
        !todo.isCompleted;
  }
}

class _TodoDialog extends StatefulWidget {
  final TodoItem? todo;
  final Function(String title, TodoPriority priority, DateTime? dueDate) onSave;

  const _TodoDialog({this.todo, required this.onSave});

  @override
  State<_TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<_TodoDialog> {
  late TextEditingController _titleController;
  late TodoPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _priority = widget.todo?.priority ?? TodoPriority.medium;
    _dueDate = widget.todo?.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.todo == null ? '添加待办' : '编辑待办'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题',
                hintText: '输入待办事项',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TodoPriority>(
              value: _priority,
              decoration: const InputDecoration(labelText: '优先级'),
              items: TodoPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_priorityText(priority)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('截止日期'),
              subtitle: Text(_dueDate != null
                  ? '${_dueDate!.year}/${_dueDate!.month}/${_dueDate!.day}'
                  : '未设置'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_dueDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
                }
              },
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
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              widget.onSave(
                _titleController.text.trim(),
                _priority,
                _dueDate,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  String _priorityText(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return '高';
      case TodoPriority.medium:
        return '中';
      case TodoPriority.low:
        return '低';
    }
  }
}
```

- [ ] **Step 2: 创建待办工具模块**

Create: `app/lib/tools/todo/todo_tool.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'todo_page.dart';

class TodoTool implements ToolModule {
  @override
  String get id => 'todo';

  @override
  String get name => '待办清单';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.check_circle;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const TodoPage();
  }

  @override
  ToolSettings? get settings => null;
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/todo/todo_page.dart app/lib/tools/todo/todo_tool.dart app/lib/main.dart
git commit -m "feat: add todo list tool"
```

---

## Chunk 8: 我的页面与设置

### Task 17: 创建我的页面

**Files:**
- Modify: `app/lib/pages/profile_page.dart`

- [ ] **Step 1: 更新我的页面**

Replace: `app/lib/pages/profile_page.dart`

```dart
import 'package:flutter/material.dart';
import '../core/ui/app_colors.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nickname = '用户';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          // 用户信息卡片
          _buildUserCard(),

          const Divider(height: 32),

          // 功能列表
          _buildMenuItem(
            icon: Icons.settings,
            title: '设置',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.bar_chart,
            title: '使用统计',
            onTap: () {
              // TODO: 使用统计
            },
          ),
          _buildMenuItem(
            icon: Icons.feedback,
            title: '反馈建议',
            onTap: () {
              // TODO: 反馈
            },
          ),
          _buildMenuItem(
            icon: Icons.info,
            title: '关于我们',
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像
          GestureDetector(
            onTap: () {
              // TODO: 更换头像
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.person,
                size: 48,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 昵称
          GestureDetector(
            onTap: _editNickname,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _nickname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _editNickname() async {
    final controller = TextEditingController(text: _nickname);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '昵称',
            hintText: '输入新昵称',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() => _nickname = newName);
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '小方格',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.grid_view,
          size: 40,
          color: Colors.white,
        ),
      ),
      applicationLegalese: '© 2025 LittleGrid',
      children: [
        const SizedBox(height: 16),
        const Text('实用小工具的集合应用'),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/pages/profile_page.dart
git commit -m "feat: add profile page with user info"
```

---

### Task 18: 创建设置页面

**Files:**
- Create: `app/lib/pages/settings_page.dart`

- [ ] **Step 1: 创建设置页面**

Create: `app/lib/pages/settings_page.dart`

```dart
import 'package:flutter/material.dart';
import '../core/ui/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  String _language = '简体中文';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 外观设置
          _buildSectionHeader('外观'),
          _buildSwitchItem(
            icon: Icons.dark_mode,
            title: '深色模式',
            subtitle: '跟随系统',
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
            },
          ),
          _buildMenuItem(
            icon: Icons.language,
            title: '语言',
            subtitle: _language,
            onTap: () => _showLanguageDialog(),
          ),

          const Divider(),

          // 通知设置
          _buildSectionHeader('通知'),
          _buildSwitchItem(
            icon: Icons.notifications,
            title: '推送通知',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),

          const Divider(),

          // 数据管理
          _buildSectionHeader('数据'),
          _buildMenuItem(
            icon: Icons.download,
            title: '导出数据',
            onTap: () {
              // TODO: 导出数据
            },
          ),
          _buildMenuItem(
            icon: Icons.delete_outline,
            title: '清除缓存',
            subtitle: '12.5 MB',
            onTap: () => _showClearCacheDialog(),
          ),

          const Divider(),

          // 其他
          _buildSectionHeader('其他'),
          _buildMenuItem(
            icon: Icons.update,
            title: '检查更新',
            onTap: () {
              // TODO: 检查更新
            },
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip,
            title: '隐私政策',
            onTap: () {
              // TODO: 显示隐私政策
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    final languages = ['简体中文', '繁體中文', 'English'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _language = value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 清除缓存
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/pages/settings_page.dart
git commit -m "feat: add settings page"
```

---

## Chunk 9: 测试与完善

### Task 19: 创建单元测试

**Files:**
- Create: `app/test/core/models/tool_config_test.dart`
- Create: `app/test/tools/todo/todo_models_test.dart`

- [ ] **Step 1: 创建 ToolConfig 测试**

Create: `app/test/core/models/tool_config_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/core/models/tool_config.dart';

void main() {
  group('ToolConfig', () {
    test('should create ToolConfig with default values', () {
      final config = ToolConfig(
        id: 'test',
        name: 'Test Tool',
        category: 'game',
      );

      expect(config.id, 'test');
      expect(config.name, 'Test Tool');
      expect(config.category, 'game');
      expect(config.isPinned, false);
      expect(config.useCount, 0);
      expect(config.gridSize, 1);
    });

    test('should convert to and from map', () {
      final config = ToolConfig(
        id: 'test',
        name: 'Test Tool',
        category: 'game',
        isPinned: true,
        useCount: 5,
        gridSize: 2,
      );

      final map = config.toMap();
      final restored = ToolConfig.fromMap(map);

      expect(restored.id, config.id);
      expect(restored.name, config.name);
      expect(restored.isPinned, config.isPinned);
      expect(restored.useCount, config.useCount);
    });

    test('copyWith should work correctly', () {
      final config = ToolConfig(
        id: 'test',
        name: 'Test Tool',
        category: 'game',
      );

      final updated = config.copyWith(useCount: 10, isPinned: true);

      expect(updated.useCount, 10);
      expect(updated.isPinned, true);
      expect(updated.id, config.id); // unchanged
      expect(updated.name, config.name); // unchanged
    });
  });
}
```

- [ ] **Step 2: 创建 Todo 模型测试**

Create: `app/test/tools/todo/todo_models_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/todo/todo_models.dart';

void main() {
  group('TodoItem', () {
    test('should create TodoItem with default values', () {
      final todo = TodoItem(title: 'Test Todo');

      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
      expect(todo.priority, TodoPriority.medium);
    });

    test('should convert to and from map', () {
      final todo = TodoItem(
        id: 1,
        title: 'Test Todo',
        isCompleted: true,
        priority: TodoPriority.high,
        notes: 'Test notes',
      );

      final map = todo.toMap();
      final restored = TodoItem.fromMap(map);

      expect(restored.id, todo.id);
      expect(restored.title, todo.title);
      expect(restored.isCompleted, todo.isCompleted);
      expect(restored.priority, todo.priority);
      expect(restored.notes, todo.notes);
    });
  });
}
```

- [ ] **Step 3: 运行测试**

```bash
cd app
flutter test
```

Expected: 所有测试通过

- [ ] **Step 4: Commit**

```bash
git add app/test/
git commit -m "test: add unit tests for models"
```

---

### Task 20: 运行应用验证

**Files:**
- None (verification only)

- [ ] **Step 1: 检查代码格式**

```bash
cd app
flutter analyze
```

Expected: 无错误或警告

- [ ] **Step 2: 构建 APK 验证**

```bash
cd app
flutter build apk --debug
```

Expected: 构建成功

- [ ] **Step 3: 最终 Commit**

```bash
git add -A
git commit -m "chore: final verification and cleanup"
```

---

## 总结

此实现计划涵盖了小方格 APP 的核心功能：

1. ✅ 项目框架搭建（Flutter + Provider + SQLite）
2. ✅ 工具模块化架构（ToolModule 接口 + ToolRegistry）
3. ✅ 投硬币、骰子、翻扑克牌（趣味工具）
4. ✅ 待办清单（完整 CRUD）
5. ✅ 格子页布局（瀑布流 + 置顶功能）
6. ✅ 我的页面 + 设置页面
7. ✅ 单元测试

**后续可添加的工具：**
- 记账本（ledger）
- 房贷计算器（calculator）
- 大转盘（wheel）
- 科学计算器（WebView）

**执行命令：**
```bash
cd /Users/nano/claude/littlegrid
# 使用 subagent-driven-development 执行此计划
```
