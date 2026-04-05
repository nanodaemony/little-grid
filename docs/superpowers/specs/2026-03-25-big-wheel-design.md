# 大转盘功能设计文档

**创建日期**: 2026-03-25
**功能名称**: Big Wheel (大转盘)
**工具ID**: `big_wheel`
**分类**: game (趣味随机)

---

## 1. 功能概述

大转盘是一个趣味随机选择工具，用户可以创建多个转盘集合，每个集合包含多个选项。通过转动转盘随机选择一个选项，适用于"今天吃什么"、"YES/NO决策"等场景。

### 核心功能
- 左右滑动切换不同转盘集合
- 点击转动，物理模拟动画效果
- 结果弹窗展示
- 转盘集合和选项的增删改查

---

## 2. 需求确认

| 需求项 | 决策 |
|--------|------|
| 转盘集合来源 | 预设 + 用户创建 |
| 选项概率 | 默认平均分配，支持自定义权重 |
| 图标类型 | 系统图标 + Emoji |
| 动画效果 | 物理模拟（加速、减速） |
| 切换方式 | 左右滑动切换转盘 |
| 结果展示 | 弹出对话框 |
| 数据存储 | SQLite 本地存储 |

---

## 3. 数据库设计

### 3.1 数据库版本说明

**当前数据库版本**: 6 (AppConstants.dbVersion = 6)
**升级后版本**: 7

> ⚠️ **注意**: 项目中已存在一个旧的 `wheel_options` 表（用于其他功能），新表与此冲突。解决方案：
> 1. 在版本7升级时，先删除旧表 `DROP TABLE IF EXISTS wheel_options`
> 2. 创建新的表结构（包含 `collection_id` 外键关系）
> 3. 旧的 `wheel_options` 数据将被清除（该功能未实际使用）

### 3.2 转盘集合表 (wheel_collections)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | 自增ID |
| name | TEXT NOT NULL | 转盘名称 |
| icon_type | INTEGER DEFAULT 0 | 0=emoji, 1=material icon |
| icon | TEXT NOT NULL | 图标代码或Emoji |
| is_preset | INTEGER DEFAULT 0 | 是否预设转盘 |
| sort_order | INTEGER DEFAULT 0 | 排序顺序 |
| created_at | INTEGER NOT NULL | 创建时间戳 |
| updated_at | INTEGER NOT NULL | 更新时间戳 |

### 3.3 转盘选项表 (wheel_options)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | 自增ID |
| collection_id | INTEGER NOT NULL | 所属转盘集合ID |
| name | TEXT NOT NULL | 选项名称 |
| icon_type | INTEGER DEFAULT 0 | 0=emoji, 1=material icon (与项目其他功能保持一致) |
| icon | TEXT | 图标（可选） |
| weight | REAL DEFAULT 1.0 | 权重，默认1.0 |
| color | TEXT | 扇形颜色（HEX格式） |
| sort_order | INTEGER DEFAULT 0 | 排序顺序 |
| created_at | INTEGER NOT NULL | 创建时间戳 |
| updated_at | INTEGER NOT NULL | 更新时间戳 |

### 3.4 数据库约束

```sql
-- 外键约束：删除转盘集合时级联删除其选项
FOREIGN KEY (collection_id) REFERENCES wheel_collections(id) ON DELETE CASCADE

-- 索引：加速按集合查询选项
CREATE INDEX idx_wheel_options_collection ON wheel_options(collection_id)
```

---

## 4. 数据模型

### 4.1 WheelCollection 模型

```dart
class WheelCollection {
  final int? id;
  final String name;
  final int iconType;  // 0=emoji, 1=material icon
  final String icon;
  final bool isPreset;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 转换方法
  Map<String, dynamic> toMap();
  factory WheelCollection.fromMap(Map<String, dynamic> map);
}
```

### 4.2 WheelOption 模型

```dart
class WheelOption {
  final int? id;
  final int collectionId;
  final String name;
  final int iconType;
  final String? icon;
  final double weight;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 转换方法
  Map<String, dynamic> toMap();
  factory WheelOption.fromMap(Map<String, dynamic> map);
}
```

---

## 5. 页面结构与导航

### 5.1 导航流程

```
BigWheelPage (主页面 - 左右滑动查看转盘)
    │
    ├── 点击 AppBar "管理" 按钮 ────────→ CollectionListPage (转盘管理)
    │                                          │
    │   ┌──────────────────────────────────────┘
    │   │
    │   ├── 点击 "+" 按钮 ────────────────→ CollectionEditPage (新建转盘)
    │   │
    │   ├── 点击转盘卡片 ────────────────→ CollectionEditPage (编辑转盘)
    │   │                                      │
    │   │                                      ├── 点击 "管理选项" ─→ OptionListPage
    │   │                                      │                           │
    │   │                                      │                           ├── 点击 "+" ─→ OptionEditPage (新建)
    │   │                                      │                           ├── 点击选项 ─→ OptionEditPage (编辑)
    │   │                                      │                           └── 返回 ───────→ CollectionEditPage
    │   │                                      │
    │   │                                      └── 返回 ────────────────→ CollectionListPage
    │   │
    │   └── 返回 ─────────────────────────→ BigWheelPage
    │
    └── 点击 "开始" 转动 ────────────────→ ResultDialog (显示结果)
```

### 5.2 主页面层级

```
BigWheelPage (主页面)
├── PageView.builder (左右滑动容器)
│   └── BigWheelView (单个转盘视图)
│       ├── AppBar (转盘名称 + 编辑按钮)
│       ├── 转盘动画区域
│       │   ├── CustomPaint (WheelPainter 绘制扇形)
│       │   └── WheelPointer (中心固定指针)
│       └── 底部操作区
│           ├── 开始/停止按钮
│           └── 管理选项入口
├── FloatingActionButton (添加新转盘)
└── BottomNavigation (快速切换到管理页)
```

### 5.2 子页面

| 页面 | 路由 | 功能 |
|------|------|------|
| CollectionListPage | /list | 转盘集合管理列表 |
| CollectionEditPage | /edit/:id | 编辑转盘集合（名称、图标） |
| OptionListPage | /options/:collectionId | 选项列表管理 |
| OptionEditPage | /option/edit/:id | 编辑单个选项 |

---

## 6. 核心组件

### 6.1 组件列表

| 组件名 | 文件 | 职责 |
|--------|------|------|
| WheelPainter | wheel_painter.dart | CustomPainter，绘制转盘扇形区域，根据权重计算角度 |
| WheelPointer | wheel_pointer.dart | 固定在顶部的指针Widget，带装饰效果 |
| WheelAnimationController | wheel_animation_controller.dart | 管理动画状态，控制转动/停止 |
| WheelPhysics | wheel_physics.dart | 物理计算：目标角度、速度曲线、停止位置 |
| ResultDialog | result_dialog.dart | 结果展示弹窗，显示选中的选项 |
| CollectionCard | collection_card.dart | 转盘集合卡片（列表页用） |
| OptionListItem | option_list_item.dart | 选项列表项，支持拖拽排序 |

### 6.2 动画参数

```dart
class WheelAnimationConfig {
  static const double minSpins = 3.0;      // 最小旋转圈数
  static const double maxSpins = 8.0;      // 最大旋转圈数
  static const Duration minDuration = Duration(seconds: 3);
  static const Duration maxDuration = Duration(seconds: 5);
  static const Curve curve = Curves.decelerate;  // 减速曲线
}
```

---

## 7. 交互流程

### 7.1 转动转盘流程

```
1. 用户点击"开始"按钮
   ↓
2. WheelPhysics.calculateTargetAngle()
   - 根据权重随机选择目标选项
   - 计算需要旋转的总角度
   ↓
3. WheelAnimationController.start()
   - 创建 AnimationController
   - 使用 Tween 从当前角度到目标角度
   - 应用 Curves.decelerate 缓动
   ↓
4. 动画执行中
   - WheelPainter 根据动画值重绘转盘
   - 扇形随角度旋转
   ↓
5. 动画结束
   - 计算指针指向的选项
   - 触发 onResult 回调
   - 显示 ResultDialog
```

### 7.2 管理转盘流程

```
1. 点击"管理"按钮进入 CollectionListPage
   ↓
2. 展示所有转盘集合列表
   - 长按拖拽排序
   - 左滑删除（预设不可删）
   - 点击进入编辑
   ↓
3. 编辑转盘
   - 修改名称、图标
   - 进入选项管理
   ↓
4. 选项管理
   - 添加/删除/修改选项
   - 设置权重
   - 拖拽排序
```

---

## 8. 预设内容

### 8.1 预设转盘列表

| 名称 | 图标 | 选项 |
|------|------|------|
| 今天吃什么 | 🍽️ | 火锅、烧烤、日料、川菜、粤菜、西餐、韩料、小吃 |
| YES or NO | ❓ | YES、NO、再想想 |
| 周末活动 | 🎉 | 看电影、逛街、宅家、运动、爬山、探店 |

### 8.2 预设颜色方案

转盘扇形颜色使用预设配色循环：
```dart
static const List<Color> wheelColors = [
  Color(0xFFFF6B6B),  // 红色
  Color(0xFF4ECDC4),  // 青色
  Color(0xFFFFE66D),  // 黄色
  Color(0xFF95E1D3),  // 绿色
  Color(0xFFF38181),  // 粉色
  Color(0xFFAA96DA),  // 紫色
  Color(0xFFFFD93D),  // 橙色
  Color(0xFF6BCB77),  // 深绿
];
```

---

## 9. 文件结构

```
lib/tools/big_wheel/
├── big_wheel_tool.dart              # ToolModule 实现
├── big_wheel_page.dart              # 主页面
├── big_wheel_view.dart              # 单个转盘视图
├── models/
│   ├── wheel_collection.dart        # 转盘集合模型
│   └── wheel_option.dart            # 转盘选项模型
├── services/
│   └── big_wheel_service.dart       # 数据库操作服务
├── widgets/
│   ├── wheel_painter.dart           # 转盘绘制
│   ├── wheel_pointer.dart           # 中心指针
│   ├── wheel_animation_controller.dart  # 动画控制器
│   ├── result_dialog.dart           # 结果弹窗
│   ├── collection_card.dart         # 集合卡片
│   └── option_list_item.dart        # 选项列表项
└── pages/
    ├── collection_list_page.dart    # 转盘管理列表
    ├── collection_edit_page.dart    # 转盘编辑页
    ├── option_list_page.dart        # 选项列表页
    └── option_edit_page.dart        # 选项编辑页
```

---

## 13. 技术要点

### 13.1 权重计算算法

```dart
// 1. 计算总权重
double totalWeight = options.fold(0, (sum, o) => sum + o.weight);

// 2. 生成随机数 (0, totalWeight)
double random = Random().nextDouble() * totalWeight;

// 3. 根据权重选择选项
double currentWeight = 0;
for (var option in options) {
  currentWeight += option.weight;
  if (random <= currentWeight) return option;
}
```

### 13.2 角度计算

```dart
// 每个选项的角度范围 = (option.weight / totalWeight) * 360°
double calculateAngleForOption(WheelOption option) {
  return (option.weight / totalWeight) * 360.0;
}

// 目标角度 = 当前角度 + 圈数×360 + 目标选项中心偏移
```

### 13.3 数据库升级

在 `DatabaseService._onUpgrade` 中添加，同时更新 `AppConstants.dbVersion = 7`：

```dart
if (oldVersion < 7) {
  // 删除旧的 wheel_options 表（如果存在），因为与新表结构冲突
  await db.execute('DROP TABLE IF EXISTS wheel_options');
  AppLogger.i('Dropped old wheel_options table');

  // 创建转盘集合表
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

  // 创建转盘选项表
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

---

## 10. ToolModule 实现

### 10.1 BigWheelTool

```dart
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
  int get gridSize => 2;  // 大格子，因为转盘需要更多空间

  @override
  Widget buildPage(BuildContext context) {
    return const BigWheelPage();
  }

  @override
  ToolSettings? get settings => null;  // 管理功能集成在页面内

  @override
  Future<void> onInit() async {
    // 初始化预设转盘数据
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

### 10.2 注册工具

在 `main.dart` 中添加：

```dart
import 'tools/big_wheel/big_wheel_tool.dart';

void main() {
  // ... 其他注册
  ToolRegistry.register(BigWheelTool());
  // ...
}
```

---

## 11. 错误处理与边界情况

### 11.1 空状态处理

当转盘没有选项时：
- 显示占位文字："暂无选项，点击管理添加"
- 禁用"开始"按钮
- 显示添加选项的引导按钮

### 11.2 数据验证规则

| 字段 | 验证规则 | 错误提示 |
|------|----------|----------|
| 转盘名称 | 必填，1-20字符 | "请输入转盘名称" |
| 选项名称 | 必填，1-30字符 | "请输入选项名称" |
| 权重 | > 0 | "权重必须大于0" |
| 选项数量 | 最少2个才能转动 | "至少需要2个选项" |

### 11.3 异常处理

```dart
// 数据库异常
try {
  await BigWheelService.saveCollection(collection);
} catch (e) {
  // 显示错误提示：Toast 或 SnackBar
  showToast('保存失败，请重试');
}

// 动画异常（防止快速连续点击）
if (_isSpinning) return;  // 忽略点击
```

### 11.4 性能优化

- 使用 `RepaintBoundary` 包裹转盘，减少重绘区域
- 选项数量超过20个时，简化扇形绘制（减少细节）
- 使用 `const` 构造函数优化widget重建

---

## 12. 测试要点

- [ ] 转盘动画流畅，无卡顿
- [ ] 权重计算正确，高权重选项被选中概率更高
- [ ] 左右滑动切换转盘正常
- [ ] 结果弹窗正确显示
- [ ] 增删改查功能正常
- [ ] 预设转盘初始化正确
- [ ] 空转盘处理（提示添加选项）
- [ ] 大量选项时性能正常（>20个选项）

---

## 14. 后续可扩展功能

1. 历史记录 - 记录每次转动结果
2. 音效 - 转动和停止时播放音效
3. 分享 - 分享转盘结果到社交媒体
4. 导入/导出 - 导入他人分享的转盘配置
5. 主题 - 支持自定义转盘颜色和样式

---

**设计确认**: ✅ 已通过用户审核
**修订记录**:
- 2026-03-25: 初始版本
- 2026-03-25: 修复数据库冲突说明、添加导航流程图、添加ToolModule实现、添加错误处理章节

**下一步**: 编写实现计划 (writing-plans)
