# 小方格工具开发规范

本文档定义了新增功能格子时需要遵循的规范，确保代码风格统一、可维护性强。

## 目录

- [代码结构](#代码结构)
- [工具注册](#工具注册)
- [UI 样式规范](#ui-样式规范)
- [数据持久化](#数据持久化)
- [代码规范](#代码规范)
- [命名规范](#命名规范)
- [国际化](#国际化)

---

## 代码结构

### 目录结构

每个工具放在独立目录下：`app/lib/tools/<tool_name>/`

```
app/lib/tools/<tool_name>/
├── <tool_name>_tool.dart      # 必须 - 工具注册，实现 ToolModule 接口
├── <tool_name>_page.dart      # 必须 - 主页面 UI
├── <tool_name>_models.dart    # 可选 - 数据模型
├── <tool_name>_service.dart   # 可选 - 业务逻辑/数据服务
├── widgets/                   # 可选 - 页面子组件（复杂工具）
│   └── *.dart
├── models/                    # 可选 - 多个数据模型（复杂工具）
│   └── *.dart
└── services/                  # 可选 - 多个服务（复杂工具）
    └── *.dart
```

### 文件职责

| 文件 | 职责 |
|------|------|
| `*_tool.dart` | 工具元数据（id、名称、图标、分类），实现 `ToolModule` 接口 |
| `*_page.dart` | UI 层，处理用户交互，调用 Service |
| `*_models.dart` | 数据模型定义，包含 `toMap()` 和 `fromMap()` 方法 |
| `*_service.dart` | 业务逻辑、数据持久化，与数据库交互 |

---

## 工具注册

### 实现 ToolModule 接口

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'xxx_page.dart';

class XxxTool implements ToolModule {
  @override
  String get id => 'xxx';  // 唯一标识，小写下划线

  @override
  String get name => '工具名称';  // 中文显示名称

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.xxx;  // Material Icons

  @override
  ToolCategory get category => ToolCategory.life;  // life/game/calc

  @override
  int get gridSize => 1;  // 1=小格子，2=大格子

  @override
  Widget buildPage(BuildContext context) => const XxxPage();

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

### 分类说明

| 分类 | 枚举值 | 适用场景 |
|------|--------|----------|
| 生活 | `ToolCategory.life` | 日历、待办、记账等实用工具 |
| 趣味 | `ToolCategory.game` | 骰子、硬币、扑克等随机游戏 |
| 计算 | `ToolCategory.calc` | 计算器、单位转换等计算工具 |

### 在 main.dart 注册

```dart
import 'tools/xxx/xxx_tool.dart';

// 在 main() 中添加
ToolRegistry.register(XxxTool());
```

---

## UI 样式规范

### 页面结构

```dart
class XxxPage extends StatefulWidget {
  const XxxPage({super.key});

  @override
  State<XxxPage> createState() => _XxxPageState();
}

class _XxxPageState extends State<XxxPage> {
  // ...
}
```

### 基础布局

使用 `Scaffold` + `AppBar` 结构：

```dart
return Scaffold(
  appBar: AppBar(
    title: const Text('工具名称'),
  ),
  body: _buildBody(),
  floatingActionButton: FloatingActionButton(
    onPressed: _onAdd,
    child: const Icon(Icons.add),
  ),
);
```

### 颜色使用

使用 `AppColors` 中定义的颜色常量：

```dart
import '../../core/ui/app_colors.dart';

// 主色调
AppColors.primary          // 主色 #5B9BD5
AppColors.primaryLight     // 浅主色
AppColors.primaryDark      // 深主色

// 文字颜色
AppColors.textPrimary      // 主文字 #333333
AppColors.textSecondary    // 次要文字 #666666
AppColors.textTertiary     // 辅助文字 #999999

// 功能色
AppColors.success          // 成功绿色
AppColors.warning          // 警告橙色
AppColors.error            // 错误红色
AppColors.info             // 信息蓝色
```

**不要硬编码颜色值**，如 `Colors.red`、`Color(0xFF000000)`。

### 空状态设计

```dart
Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.xxx,
          size: 80,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        Text(
          '暂无数据',
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
```

### 列表项设计

使用 `Card` 组件：

```dart
ListView.builder(
  padding: const EdgeInsets.all(8),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(item.title),
        subtitle: Text(item.subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteItem(item),
        ),
      ),
    );
  },
);
```

### 弹窗设计

使用 `AlertDialog`：

```dart
final result = await showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('确认删除'),
    content: const Text('确定要删除吗？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('取消'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('确定'),
      ),
    ],
  ),
);
```

### 按钮样式

主要操作按钮：

```dart
ElevatedButton.icon(
  onPressed: _isLoading ? null : _onSubmit,
  icon: const Icon(Icons.check),
  label: const Text('提交'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(
      horizontal: 48,
      vertical: 16,
    ),
    textStyle: const TextStyle(fontSize: 18),
  ),
),
```

---

## 数据持久化

### 新增数据表

1. **升级数据库版本**（`app_constants.dart`）：

```dart
static const int dbVersion = 2;  // 递增
```

2. **添加建表语句**（`database_service.dart` 的 `_onCreate`）：

```dart
await db.execute('''
  CREATE TABLE xxx_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    field1 TEXT NOT NULL,
    field2 INTEGER DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
  )
''');
```

3. **添加升级逻辑**（`database_service.dart` 的 `_onUpgrade`）：

```dart
if (oldVersion < 2) {
  await db.execute('''
    CREATE TABLE xxx_items (...)
  ''');
}
```

### Service 层规范

```dart
import '../../core/services/database_service.dart';
import 'xxx_models.dart';

class XxxService {
  /// 添加
  static Future<int> add(XxxItem item) async {
    final db = await DatabaseService.database;
    return await db.insert('xxx_items', item.toMap());
  }

  /// 查询列表
  static Future<List<XxxItem>> getAll() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'xxx_items',
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => XxxItem.fromMap(m)).toList();
  }

  /// 更新
  static Future<void> update(XxxItem item) async {
    final db = await DatabaseService.database;
    await db.update(
      'xxx_items',
      item.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// 删除
  static Future<void> delete(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'xxx_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### Model 层规范

```dart
class XxxItem {
  final int? id;
  final String field1;
  final DateTime createdAt;
  final DateTime updatedAt;

  XxxItem({
    this.id,
    required this.field1,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'field1': field1,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory XxxItem.fromMap(Map<String, dynamic> map) {
    return XxxItem(
      id: map['id'],
      field1: map['field1'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  XxxItem copyWith({
    int? id,
    String? field1,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return XxxItem(
      id: id ?? this.id,
      field1: field1 ?? this.field1,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

---

## 代码规范

### 异步操作

```dart
// 加载数据
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    final data = await XxxService.getAll();
    setState(() {
      _items = data;
      _isLoading = false;
    });
  } catch (e) {
    // 错误处理
    setState(() => _isLoading = false);
  }
}

// 删除操作（需确认）
Future<void> _deleteItem(XxxItem item) async {
  final confirmed = await showDialog<bool>(...);
  if (confirmed == true && item.id != null) {
    await XxxService.delete(item.id!);
    _loadData();
  }
}
```

### 状态管理

- 使用 `setState` 管理本地状态
- 加载状态用 `_isLoading` 标志
- 数据为空时显示空状态组件

### 组件拆分

当页面代码超过 300 行时，考虑拆分：

- 提取可复用组件到 `widgets/` 目录
- 提取独立功能组件（如 `_XxxCard`、`_XxxDialog`）

---

## 命名规范

### 文件命名

- 小写 + 下划线：`xxx_tool.dart`、`xxx_page.dart`
- 组件文件：`xxx_card.dart`、`xxx_dialog.dart`

### 类命名

- 大驼峰：`XxxTool`、`XxxPage`、`XxxItem`
- 私有组件：`_XxxCard`、`_XxxDialog`

### 变量命名

- 小驼峰：`_items`、`_isLoading`、`_selectedItem`
- 常量：`kDefaultValue` 或直接使用 `const`

### 方法命名

- 动词开头：`_loadData()`、`_deleteItem()`、`_showDialog()`
- 构建方法：`_buildBody()`、`_buildEmptyState()`

---

## 国际化

### 界面文字

- 界面统一使用中文
- 按钮文字：添加、保存、取消、删除、确定、编辑
- 空状态提示：暂无数据、点击添加

### 日期格式

- 显示格式：`年/月/日` 或 `月/日`
- 数据存储：ISO 格式 `yyyy-MM-dd` 或时间戳

---

## 检查清单

新增工具时，确认以下事项：

- [ ] 文件结构符合规范
- [ ] 实现了 `ToolModule` 接口
- [ ] 在 `main.dart` 中注册
- [ ] 使用 `AppColors` 颜色常量
- [ ] 空状态有友好提示
- [ ] 删除操作有确认弹窗
- [ ] 数据库表已正确创建和升级
- [ ] Model 包含 `toMap()`、`fromMap()`、`copyWith()` 方法
- [ ] 界面文字使用中文