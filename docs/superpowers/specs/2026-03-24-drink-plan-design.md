# 奶茶计划功能设计文档

**创建日期：** 2026-03-24
**功能名称：** 奶茶计划 (Drink Plan)
**工具ID：** `drink_plan`

---

## 1. 功能概述

奶茶计划是一个帮助用户追踪含糖饮料摄入习惯的日历工具。用户可以在日历上标记喝奶茶、咖啡、可乐等饮料的日子，通过可视化的方式感知自己的饮食习惯，并收到随机的健康提醒。

### 1.1 核心功能

- **月视图**：显示当月30天，左右滑动切换月份，标记的日期显示背景图
- **年视图**：显示12个月，点击月份跳转到对应月视图
- **日详情**：查看具体日期信息，添加/删除标记
- **健康提示**：页面顶部随机展示带Emoji的健康提醒文案
- **设置**：调整背景图透明度

---

## 2. 数据模型

### 2.1 DrinkRecord（饮料记录）

```dart
class DrinkRecord {
  final int? id;               // 主键，自动递增
  final String date;           // 格式: yyyy-MM-dd
  final String mark;           // Emoji或图片标识符
  final DateTime createdAt;    // 创建时间
  final DateTime updatedAt;    // 更新时间

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'mark': mark,
    'created_at': createdAt.millisecondsSinceEpoch,
    'updated_at': updatedAt.millisecondsSinceEpoch,
  };

  factory DrinkRecord.fromMap(Map<String, dynamic> map) => DrinkRecord(
    id: map['id'],
    date: map['date'],
    mark: map['mark'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
  );
}
```

### 2.2 DrinkPlanSettings（用户设置）

```dart
class DrinkPlanSettings {
  final double backgroundOpacity;  // 背景透明度 0.0-1.0，默认 0.3
}
```

### 2.3 HealthTip（健康提示）

```dart
class HealthTip {
  final String text;  // 提示文案，可包含Emoji
}
```

---

## 3. 数据库设计

### 3.1 drink_records 表

| 字段名 | 类型 | 说明 |
|--------|------|------|
| id | INTEGER PRIMARY KEY AUTOINCREMENT | 主键 |
| date | TEXT NOT NULL UNIQUE | 日期 yyyy-MM-dd，唯一约束 |
| mark | TEXT NOT NULL | 标识符 |
| created_at | INTEGER NOT NULL | 创建时间戳 |
| updated_at | INTEGER NOT NULL | 更新时间戳 |

**索引：** `idx_drink_records_date ON drink_records(date)`

### 3.2 drink_plan_settings 表

| 字段名 | 类型 | 说明 |
|--------|------|------|
| key | TEXT PRIMARY KEY | 设置键 |
| value | TEXT | 设置值 |

---

## 4. 页面结构

```
DrinkPlanTool (implements ToolModule)
├── DrinkPlanPage (主页面)
│   ├── AppBar
│   │   ├── 标题：奶茶计划
│   │   ├── 视图切换按钮：[月视图 | 年视图]
│   │   └── 设置按钮 (右上角)
│   ├── HealthTipBanner (健康提示横幅)
│   ├── ViewContainer (视图容器)
│   │   ├── MonthView (月视图) - PageView.builder
│   │   └── YearView (年视图) - GridView
│   └── FloatingActionButton (可选：快速回到今天)
├── DayDetailPage (日详情页)
│   ├── DateInfoCard (日期信息卡片：公历、星期、农历)
│   ├── MonthlyStatsCard (本月统计：累计天数)
│   ├── MarkSelector (标记选择区：Emoji/图片)
│   └── DeleteButton (删除按钮，仅已标记时显示)
└── DrinkPlanSettingsPage (设置页)
    └── OpacitySelector (透明度选项)
```

---

## 5. 交互流程

### 5.1 添加标记

1. 在月视图中点击某天
2. 进入日详情页
3. 选择 Emoji 或图片
4. 自动保存并返回月视图
5. 月视图中该日期显示背景图

### 5.2 删除标记

**方式一**：在日详情页点击"删除"按钮，确认后删除
**方式二**：在月视图中长按已标记日期，弹出确认对话框删除

### 5.3 切换视图

- 点击顶部"月视图/年视图"按钮切换
- 月视图左右滑动切换月份（PageView动画）
- 年视图左右滑动切换年份
- 年视图中点击某月份，跳转到该月月视图

### 5.4 调整透明度

1. 点击右上角设置按钮
2. 选择透明度：100% / 75% / 50% / 25%
3. 实时生效

---

## 6. UI设计规范

### 6.1 月视图

- 7列网格（周一至周日）
- 星期标题行固定在顶部
- 日期单元格为正方形
- 标记的日期：背景图铺满整个单元格，日期数字居中显示
- 当前日期：边框高亮
- 选中日期：背景色高亮

### 6.2 年视图

- 3x4 网格显示12个月
- 每个月显示为简化的小日历
- 显示月份名称和该月标记天数统计
- 点击月份跳转对应月视图

### 6.3 日详情页

- 顶部大字体显示日期
- 显示星期、农历信息
- 本月累计天数统计
- Emoji/图片选择网格（可横向滑动或分页）

### 6.4 健康提示横幅

- 位于视图切换按钮下方
- 每次进入页面随机显示一条
- 文案可包含Emoji
- 样式：柔和背景色，居中对齐

---

## 7. 内置资源

### 7.1 Emoji 预设

```
🧋 奶茶
☕ 咖啡
🥤 可乐/碳酸饮料
🍵 茶
🍺 啤酒
🍷 红酒
🥃 烈酒
🧃 果汁
🥛 牛奶
💧 水（用于标记"今天没喝"）
```

### 7.2 健康提示文案

```
🥤 你看看你现在多少斤了，还在喝？
☕ 今天的咖啡因摄入已超标，小心失眠哦
🧋 奶茶虽好，可不要贪杯哦
🍬 这杯糖的甜度，够你跑3公里了
💪 放下饮料，拿起水杯，你可以的！
🦷 想想你的牙齿，它们正在哭泣
💰 这杯奶茶钱，够买两斤水果了
🏃‍♀️ 喝前想一想，今天的运动白做了吗？
🍎 不如来杯鲜榨果汁？
😴 糖分会让你更疲惫，真的需要吗？
🌊 多喝水，皮肤会更好哦
🎯 小目标：今天只喝一杯！
```

### 7.3 图片资源

图片资源存放于 `assets/drink_plan/`，包含自定义饮料图标（用户提供）。

---

## 8. 技术实现

### 8.1 依赖

- `lunar`：农历计算（复用现有日历）
- `sqflite`：数据存储
- `flutter_slidable`（可选）：滑动删除

### 8.2 关键组件

- **MonthView**：使用 `PageView.builder` 实现无限滑动，参考现有日历实现
- **YearView**：使用 `GridView` 显示12个月份
- **DayCell**：自定义日期单元格，支持背景图和透明度
- **MarkSelector**：Emoji/图片选择器

### 8.3 服务层

```dart
class DrinkPlanService {
  // 获取指定月份的所有记录
  static Future<List<DrinkRecord>> getRecordsByMonth(int year, int month);

  // 获取单条记录
  static Future<DrinkRecord?> getRecordByDate(String date);

  // 添加记录
  static Future<void> addRecord(DrinkRecord record);

  // 删除记录
  static Future<void> deleteRecord(String date);

  // 获取指定年月已标记的日期列表
  static Future<Set<String>> getMarkedDates(int year, int month);

  // 获取设置
  static Future<DrinkPlanSettings> getSettings();

  // 保存设置
  static Future<void> saveSettings(DrinkPlanSettings settings);
}
```

---

## 9. 测试要点

### 9.1 功能测试

- [ ] 月视图正确显示当月日期
- [ ] 月视图左右滑动切换月份
- [ ] 年视图正确显示12个月
- [ ] 年视图点击月份跳转月视图
- [ ] 添加标记后月视图显示背景图
- [ ] 透明度设置生效
- [ ] 长按删除标记
- [ ] 日详情页显示农历和统计
- [ ] 健康提示随机展示

### 9.2 边界测试

- [ ] 跨年月切换（2024年12月 → 2025年1月）
- [ ] 闰年2月显示
- [ ] 数据库存储大量记录性能

---

## 10. 数据库迁移

在 `DatabaseService._onUpgrade` 中添加：

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
}
```

---

## 11. 文件结构

```
lib/tools/drink_plan/
├── drink_plan_tool.dart           # ToolModule 实现
├── models/
│   └── drink_record.dart          # 数据模型
├── services/
│   └── drink_plan_service.dart    # 数据服务
├── pages/
│   ├── drink_plan_page.dart       # 主页面
│   ├── day_detail_page.dart       # 日详情页
│   └── settings_page.dart         # 设置页
├── widgets/
│   ├── month_view.dart            # 月视图组件
│   ├── year_view.dart             # 年视图组件
│   ├── day_cell.dart              # 日期单元格
│   ├── mark_selector.dart         # 标记选择器
│   └── health_tip_banner.dart     # 健康提示横幅
└── constants/
    └── health_tips.dart           # 健康提示文案
```

---

**设计确认：** 用户已确认本设计方案

---

## 12. 工具注册

在 `main.dart` 或工具初始化处注册：

```dart
import 'tools/drink_plan/drink_plan_tool.dart';

// 注册工具
ToolRegistry.register(DrinkPlanTool());
```

**ToolCategory:** `ToolCategory.life`（生活实用）

---

## 13. 补充说明

### 13.1 Mark 字段格式

`mark` 字段支持两种格式：

1. **Emoji 格式**：直接存储 Emoji 字符，如 `"🧋"`、`"☕"`
2. **图片资源格式**：以 `asset:` 为前缀，如 `"asset:milk_tea"`、`"asset:coffee"`

显示时根据前缀判断：
- 无前缀 → 显示为文本 Emoji
- `asset:` 前缀 → 从 `assets/drink_plan/` 加载图片

### 13.2 透明度设置作用对象

透明度作用于**日期单元格的背景图**：

- 未标记日期：无背景，透明度不生效
- 已标记日期：背景图（Emoji放大显示或图片）应用透明度
- 日期数字始终不透明，确保可读性

透明度选项：
- 100%（不透明）
- 75%（轻微透明）
- 50%（半透明，默认）
- 25%（高度透明）

### 13.3 农历计算

使用 `lunar` 库计算农历日期：

```dart
import 'package:lunar/lunar.dart';

// 获取农历信息
final lunar = Lunar.fromDate(date);
final lunarDay = lunar.getDayInChinese();  // 初一、初二...
final lunarMonth = lunar.getMonthInChinese();  // 正月、二月...
final solarTerm = lunar.getJieQi();  // 节气，如"立春"
final festival = lunar.getFestivals();  // 节日列表
```

### 13.4 边界情况处理

| 场景 | 处理方式 |
|------|----------|
| 同一天多次标记 | 不支持。`date` 字段添加 `UNIQUE` 约束，新标记覆盖旧标记 |
| 标记未来日期 | 允许。用户可能计划未来喝饮料 |
| 时区处理 | 使用设备本地时间，`DateTime.now()` |
| 长按删除 | 使用 `GestureDetector` 的 `onLongPress` 回调 |

### 13.5 健康提示存储

健康提示文案**硬编码**在 Dart 文件中（`constants/health_tips.dart`），每次进入页面时随机选择一条展示。

### 13.6 设置存储

使用独立的 `drink_plan_settings` 表存储设置（而非复用 `user_settings`），原因：
- 设置项可能较多（透明度、默认标记等）
- 避免污染全局设置表
- 功能解耦，便于维护
