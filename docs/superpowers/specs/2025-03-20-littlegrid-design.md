# 小方格 (LittleGrid) APP 设计文档

## 1. 项目概述

| 属性 | 内容 |
|------|------|
| **APP名称** | 小方格 (LittleGrid) |
| **定位** | 实用小工具的集合应用 |
| **技术栈** | Flutter + SQLite + WebView（部分复杂工具） |
| **目标平台** | iOS、Android |

### 1.1 技术选型明细

| 组件 | 选型 | 说明 |
|------|------|------|
| **状态管理** | Provider | 全局状态管理，轻量且Flutter团队推荐 |
| **路由** | Navigator 2.0 | Flutter官方路由，支持深链接 |
| **本地存储** | sqflite | SQLite Flutter插件，稳定可靠 |
| **图表** | fl_chart | Flutter图表库，支持饼图、柱状图等 |
| **图片选择** | image_picker | 官方插件，选择头像 |
| **WebView** | webview_flutter | 官方WebView插件 |
| **国际化** | flutter_localizations + intl | 官方国际化方案 |

## 2. 项目目录结构

```
littlegrid/                     # 项目根目录
├── app/                        # Flutter APP 项目
│   ├── lib/
│   │   ├── core/               # 核心框架
│   │   │   ├── models/         # 通用数据模型
│   │   │   ├── services/       # 存储、配置、统计服务
│   │   │   ├── ui/             # 通用UI组件、主题
│   │   │   └── utils/          # 工具类
│   │   ├── tools/              # 工具模块（严格隔离）
│   │   │   ├── coin/           # 投硬币
│   │   │   ├── dice/           # 骰子
│   │   │   ├── todo/           # 待办清单
│   │   │   ├── ledger/         # 记账本
│   │   │   ├── wheel/          # 大转盘
│   │   │   ├── card/           # 翻扑克牌
│   │   │   ├── calculator/     # 房贷计算器
│   │   │   └── scientific_calc/# 科学计算器（WebView）
│   │   ├── pages/              # 主页面
│   │   │   ├── grid_page.dart  # 格子页（首页）
│   │   │   ├── profile_page.dart# 我的页面
│   │   │   └── settings_page.dart# 设置页
│   │   └── main.dart
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
├── backend/                    # 后端项目（预留）
└── doc/                        # 文档
    ├── specs/                  # 设计文档
    └── api/                    # API文档
```

## 3. 功能模块规划（第一阶段 - MVP）

| 分类 | 工具 | 复杂度 | 存储需求 | 备注 |
|------|------|--------|----------|------|
| **趣味随机** | 投硬币 | ⭐ 低 | 无 | 简单动画、正反面 |
| | 骰子 | ⭐ 低 | 使用频次 | 1-6点、可多骰 |
| | 翻扑克牌 | ⭐ 低 | 无 | 抽一张随机牌 |
| | 大转盘 | ⭐⭐ 中 | 自定义选项 | 自定义选项、旋转动画 |
| **生活实用** | 待办清单 | ⭐⭐ 中 | 任务数据 | 增删改查、优先级 |
| | 记账本 | ⭐⭐⭐ 高 | 收支记录 | 分类、统计图表 |
| | 房贷计算器 | ⭐ 低 | 历史记录 | 等额本息/本金 |

**科学计算器**：考虑使用 WebView 集成现有开源实现。

## 4. 核心架构设计

### 4.1 工具模块接口（严格隔离）

每个工具必须实现以下接口：

```dart
abstract class ToolModule {
  String get id;                    // 唯一标识（如：coin, dice）
  String get name;                  // 显示名称（如：投硬币）
  String get version;               // 版本号（如：1.0.0）
  IconData get icon;                // 图标
  ToolCategory get category;        // 分类（game/life/calc）
  int get gridSize;                 // 格子大小（1或2）
  Widget buildPage();               // 构建工具页面
  ToolSettings? get settings;       // 可选：工具设置页面

  // 生命周期方法
  Future<void> onInit();            // 初始化时调用
  Future<void> onDispose();         // 销毁时调用
  void onEnter();                   // 进入工具时调用
  void onExit();                    // 退出工具时调用
}

// 工具设置接口
abstract class ToolSettings {
  String get title;                 // 设置页面标题
  Widget buildSettingsPage();       // 构建设置页面
  Map<String, dynamic> toJson();    // 序列化设置
  void fromJson(Map<String, dynamic> json); // 反序列化
}

// 工具注册表
class ToolRegistry {
  static final Map<String, ToolModule> _tools = {};

  static void register(ToolModule tool) {
    _tools[tool.id] = tool;
  }

  static ToolModule? get(String id) => _tools[id];
  static List<ToolModule> getAll() => _tools.values.toList();
}
```

### 4.2 数据存储架构

| 数据类型 | 存储方案 | 说明 |
|----------|----------|------|
| APP级配置 | SharedPreferences | 主题、语言、通知设置 |
| 工具数据 | SQLite | 每个工具独立表 |
| 使用统计 | SQLite | 统一存储，用于排序 |

### 4.3 状态管理

- **全局状态**：Provider / Riverpod
- **工具内部**：自由选用（建议 Provider 保持一致性）

## 5. UI/UX 设计规范

### 5.1 整体风格

- **扁平化设计**
- **淡色系主题**：主色调待定（建议蓝/灰/绿系）
- **圆角卡片**：8-12dp 圆角
- **字体**：系统默认字体

### 5.2 格子页布局

- **布局方式**：瀑布流/错落布局
- **分页**：支持左右滑动分页
- **排序**：按使用频次动态排序
- **置顶**：长按可置顶常用工具
- **格子大小**：支持 1x1 小格子和 2x2 大格子

### 5.3 整体APP框架

```
┌─────────────────────────────────────┐
│  [≡]  小方格                    [🔍] │  ← AppBar（左侧抽屉按钮）
├─────────────────────────────────────┤
│                                     │
│    ┌──────┐  ┌────┐  ┌─────────┐  │
│    │      │  │    │  │         │  │  ← 格子区（可滑动分页）
│    │  大  │  │投币│  │ 记账本  │  │
│    │ 转盘 │  └────┘  │         │  │
│    └──────┘  ┌──────┐└─────────┘  │
│              │ 待办 │              │
│              └──────┘              │
│                                     │
├─────────────────────────────────────┤
│   [🏠 格子]        [👤 我的]       │  ← BottomTab（仅点击切换）
└─────────────────────────────────────┘
```

### 5.4 页面导航

| 页面 | 说明 |
|------|------|
| **格子页** | 首页，展示所有工具格子 |
| **我的页** | 用户头像、昵称、个人设置 |
| **设置页** | APP全局设置 |
| **功能详情页** | 各工具独立页面，右上角可能有设置按钮 |
| **抽屉页** | 左侧滑出，头像+昵称+设置入口 |

## 6. 全局设置项

| 分类 | 设置项 |
|------|--------|
| **外观** | 主题模式（跟随系统/浅色/深色） |
| **语言** | 简体中文 / 繁体中文 / English |
| **通知** | 开启推送 / 待办提醒时间 |
| **数据** | 导出数据 / 清除缓存 |
| **统计** | 显示各工具使用频次 |
| **反馈** | 问题反馈 / 功能建议 |
| **关于** | 版本号 / 检查更新 / 用户协议 / 隐私政策 |

## 7. 关键数据结构

### 7.1 工具配置表（tool_configs）

```sql
CREATE TABLE tool_configs (
  id TEXT PRIMARY KEY,          -- 工具ID（如：coin, dice, todo）
  name TEXT NOT NULL,           -- 显示名称
  category TEXT NOT NULL,       -- 分类（life, game, calc）
  sort_order INTEGER,           -- 排序权重
  is_pinned BOOLEAN DEFAULT 0,  -- 是否置顶
  use_count INTEGER DEFAULT 0,  -- 使用次数
  last_used_at INTEGER,         -- 最后使用时间（时间戳）
  grid_size INTEGER DEFAULT 1   -- 格子大小（1=小，2=大）
);
```

### 7.2 使用统计表（usage_stats）

```sql
CREATE TABLE usage_stats (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tool_id TEXT NOT NULL,        -- 工具ID
  used_at INTEGER NOT NULL,     -- 使用时间
  duration INTEGER              -- 使用时长（秒）
);
```

### 7.3 用户配置表（user_settings）

```sql
CREATE TABLE user_settings (
  key TEXT PRIMARY KEY,         -- 配置键
  value TEXT,                   -- 配置值
  type TEXT DEFAULT 'string'    -- 值类型：string/int/bool/double
);
```

## 8. 业务数据表结构

### 8.1 待办清单（todo_items）

```sql
CREATE TABLE todo_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,          -- 任务标题
  is_completed BOOLEAN DEFAULT 0, -- 是否完成
  priority INTEGER DEFAULT 1,   -- 优先级（1=低，2=中，3=高）
  due_date INTEGER,             -- 截止日期（时间戳，可选）
  created_at INTEGER NOT NULL,  -- 创建时间
  updated_at INTEGER NOT NULL,  -- 更新时间
  notes TEXT                    -- 备注
);
```

### 8.2 记账本（ledger_records）

```sql
CREATE TABLE ledger_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  type TEXT NOT NULL,           -- 类型：income/expense
  amount REAL NOT NULL,         -- 金额
  category TEXT NOT NULL,       -- 分类（餐饮/交通/购物/工资等）
  account TEXT,                 -- 账户（现金/支付宝/微信等）
  date INTEGER NOT NULL,        -- 日期
  description TEXT,             -- 描述
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- 记账分类表
CREATE TABLE ledger_categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,           -- 分类名称
  type TEXT NOT NULL,           -- income/expense
  icon TEXT,                    -- 图标标识
  color TEXT,                   -- 颜色代码
  sort_order INTEGER DEFAULT 0, -- 排序
  is_default BOOLEAN DEFAULT 0  -- 是否默认分类
);
```

### 8.3 大转盘选项（wheel_options）

```sql
CREATE TABLE wheel_options (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tool_id TEXT NOT NULL,        -- 固定为 'wheel'
  name TEXT NOT NULL,           -- 选项名称
  color TEXT,                   -- 选项颜色
  probability REAL DEFAULT 1.0, -- 权重概率
  sort_order INTEGER DEFAULT 0  -- 排序
);
```

### 8.4 房贷计算历史（mortgage_history）

```sql
CREATE TABLE mortgage_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  loan_amount REAL NOT NULL,    -- 贷款金额
  loan_years INTEGER NOT NULL,  -- 贷款年限
  interest_rate REAL NOT NULL,  -- 年利率
  repayment_type TEXT NOT NULL, -- 还款方式：equal_interest/equal_principal
  monthly_payment REAL,         -- 月供（等额本息）
  total_interest REAL,          -- 总利息
  total_amount REAL,            -- 还款总额
  calculated_at INTEGER NOT NULL -- 计算时间
);
```

## 9. WebView 集成方案

### 9.1 使用场景

科学计算器等复杂工具使用 WebView 加载本地 H5 或外部网页。

### 9.2 实现方案

```dart
class WebViewTool implements ToolModule {
  final String url;
  final bool isLocal;           // 是否本地资源

  @override
  Widget buildPage() {
    return WebViewPage(
      url: url,
      isLocal: isLocal,
      // 注入 Flutter 桥接
      javascriptChannels: {
        'flutter': (message) => handleMessage(message),
      },
    );
  }
}
```

### 9.3 安全措施

- 仅加载白名单内的 URL
- 禁止 JavaScript 自动弹出窗口
- 禁用文件访问（除本地资源外）
- 数据不缓存敏感信息

### 9.4 本地资源位置

```
assets/web/scientific_calc/
├── index.html
├── css/
└── js/
```

## 10. 国际化方案

### 10.1 实现方式

使用 Flutter 官方 `flutter_localizations` 包。

### 10.2 语言文件

```
lib/
├── l10n/
│   ├── app_zh.arb      # 简体中文
│   ├── app_zh_TW.arb   # 繁体中文
│   └── app_en.arb      # 英文
```

### 10.3 每个工具独立国际化

每个工具模块包含自己的 `l10n/` 目录，在主应用启动时统一加载。

### 10.4 支持语言

- 简体中文（默认）
- 繁体中文
- English

## 11. 工具模块详细设计

### 11.1 投硬币（coin）

- **功能**：点击翻转硬币，显示正/反面结果
- **动画**：3D 翻转动画
- **数据**：无需持久化存储

### 11.2 骰子（dice）

- **功能**：1-6 点随机，支持多个骰子
- **交互**：摇一摇或点击投掷
- **数据**：使用频次统计

### 11.3 待办清单（todo）

- **功能**：增删改查任务
- **字段**：标题、完成状态、优先级、截止日期
- **数据**：SQLite 独立表

### 11.4 记账本（ledger）

- **功能**：记录收支、分类统计、月度报表
- **分类**：餐饮、交通、购物、收入等
- **图表**：柱状图/饼图展示（使用 fl_chart）

### 11.5 房贷计算器（calculator）

- **功能**：等额本息/等额本金计算
- **输入**：贷款金额、年限、利率
- **输出**：月供、总利息、还款计划表

### 11.6 大转盘（wheel）

- **功能**：自定义选项、旋转抽奖
- **设置**：可添加/删除选项
- **动画**：旋转减速动画

### 11.7 翻扑克牌（card）

- **功能**：从 52 张牌中随机抽取
- **展示**：显示牌面花色和数字
- **数据**：无需持久化

## 12. 错误处理规范

### 12.1 全局错误处理

```dart
class AppErrorHandler {
  static void initialize() {
    FlutterError.onError = (details) {
      // 记录到日志
      logger.e('Flutter Error', details.exception, details.stack);
      // 显示用户友好的错误提示
    };
  }
}
```

### 12.2 错误分类

| 错误类型 | 处理方式 |
|----------|----------|
| **网络错误** | 显示重试按钮 |
| **数据库错误** | 记录日志，显示"数据加载失败" |
| **未知错误** | 记录日志，显示"出错了，请重试" |

### 12.3 日志规范

使用 `logger` 包，分级记录：
- `d` - Debug 信息
- `i` - Info 信息
- `w` - Warning
- `e` - Error

## 13. 数据安全

### 13.1 敏感数据

- 用户头像、昵称存储在本地，不上传服务器（第一阶段）
- 记账数据本地存储，敏感操作需确认

### 13.2 数据备份

- 支持导出 SQLite 数据库文件
- 支持从备份文件恢复

### 13.3 数据加密

MVP 阶段不加密，后续考虑使用 `encrypt` 包加密敏感数据。

## 14. 开发顺序建议

1. **Phase 1**：项目框架搭建 + 投硬币（验证架构）
2. **Phase 2**：格子页布局 + 使用统计 + 排序
3. **Phase 3**：骰子 + 翻扑克牌（趣味工具）
4. **Phase 4**：待办清单（数据持久化）
5. **Phase 5**：房贷计算器
6. **Phase 6**：大转盘
7. **Phase 7**：记账本（最复杂）
8. **Phase 8**：我的页面 + 设置页
9. **Phase 9**：科学计算器（WebView）

## 15. 约束与约定

- **严格隔离**：各工具模块间不得直接依赖
- **统一入口**：所有工具通过 `ToolRegistry` 注册
- **状态管理**：全局用 Provider，工具内部可自选
- **主题统一**：所有页面必须使用 core/ui 中的主题
- **数据迁移**：预留服务器同步接口（第一阶段不实现）
- **代码规范**：遵循 Effective Dart 规范

---

**文档版本**：v1.1
**创建日期**：2025-03-20
**状态**：待实现计划
