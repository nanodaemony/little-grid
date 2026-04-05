# 番茄钟功能设计文档

## 概述

开发一个新的工具模块——番茄钟，支持完整的番茄工作法功能，包括计时、休息管理、数据统计等。

## 功能需求

### 核心功能

1. **番茄计时**：默认 25 分钟工作时间
2. **休息管理**：
   - 短休息（默认 5 分钟）
   - 长休息（默认 15 分钟，每 4 个番茄后）
   - 支持独立开关控制
3. **数据统计**：
   - 今日/本周/本月番茄数和专注时长
   - 每日趋势图
   - 最长连续天数
   - 平均每日番茄数
   - 历史记录列表

### 设置项

| 设置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| 番茄时长 | int (分钟) | 25 | 单个番茄的工作时长 |
| 短休息 | bool | true | 是否启用短休息 |
| 短休息时长 | int (分钟) | 5 | 仅开关打开时生效 |
| 长休息 | bool | true | 是否启用长休息 |
| 长休息时长 | int (分钟) | 15 | 仅开关打开时生效 |
| 长休息间隔 | int (个) | 4 | 每几个番茄后进入长休息 |
| 显示样式 | enum | mixed | 计时器形态/独立元素/混合形态 |
| 完成行为 | enum | waitConfirm | 自动进入休息/等待用户确认 |
| 振动提醒 | bool | true | 计时结束时振动 |
| 提示音 | bool | true | 计时结束时播放提示音 |

## 模块结构

```
lib/tools/pomodoro/
├── pomodoro_tool.dart              # 工具入口，实现 ToolModule
├── pomodoro_page.dart              # 主页面
├── models/
│   ├── pomodoro_state.dart         # 计时器状态枚举和模型
│   ├── pomodoro_record.dart        # 单次番茄记录数据模型
│   └── pomodoro_settings.dart      # 设置项数据模型
├── services/
│   ├── pomodoro_service.dart       # 计时器核心逻辑
│   └── pomodoro_stats_service.dart # 统计数据存取
├── widgets/
│   ├── timer_display.dart          # 计时器显示组件
│   ├── progress_ring.dart          # 进度环组件
│   └── stats_summary_card.dart     # 今日统计卡片
└── pages/
    ├── settings_page.dart          # 设置页面
    └── stats_page.dart             # 统计页面
```

## 数据模型

### PomodoroState

```dart
enum PomodoroStatus {
  idle,           // 初始状态
  running,        // 番茄计时中
  paused,         // 暂停
  completed,      // 番茄完成
  waiting,        // 等待用户确认
  breakRunning,   // 休息计时中
  breakCompleted, // 休息结束
}

class PomodoroState {
  final PomodoroStatus status;
  final int remainingSeconds;     // 剩余秒数
  final int totalSeconds;         // 总时长
  final int completedCount;       // 今日已完成番茄数
  final int currentStreak;        // 当前连续番茄数（用于判断长休息）
  final bool isBreak;             // 当前是否为休息状态
}
```

### PomodoroRecord

```dart
enum PomodoroType { work, shortBreak, longBreak }

class PomodoroRecord {
  final int? id;
  final DateTime startedAt;       // 开始时间
  final int durationSeconds;      // 实际时长（秒）
  final PomodoroType type;        // 类型
  final bool completed;           // 是否完成（未被中断）
}
```

### PomodoroSettings

```dart
enum DisplayStyle { timer, independent, mixed }
enum CompleteAction { autoProceed, waitConfirm }

class PomodoroSettings {
  final int workDuration;         // 番茄时长（分钟）
  final bool shortBreakEnabled;   // 短休息开关
  final int shortBreakDuration;   // 短休息时长
  final bool longBreakEnabled;    // 长休息开关
  final int longBreakDuration;    // 长休息时长
  final int longBreakInterval;    // 长休息间隔
  final DisplayStyle displayStyle;
  final CompleteAction completeAction;
  final bool vibrationEnabled;
  final bool soundEnabled;
}
```

## 状态流转

```
idle ──start()──> running ──pause()──> paused
                     │                    │
                     │<────resume()───────┘
                     │
                     ↓ (计时结束)
                completed
                     │
                     ↓ (记录数据)
                waiting ◀─────────────────┐
                     │                     │
        ┌────────────┴────────────┐        │
        ↓                         ↓        │
   (无休息)                   (有休息)      │
        │                         │        │
        │                 breakRunning ────┘
        │                         │
        │                         ↓ (休息结束)
        │                    breakCompleted
        │                         │
        └─────────────────────────┘
                     │
                     ↓
                waiting (开始下一个番茄)
```

## 页面设计

### 主页面布局

```
┌─────────────────────────────┐
│  番茄钟              [设置] │  AppBar
├─────────────────────────────┤
│                             │
│        ┌─────────┐          │
│        │  番茄   │          │  计时器显示区
│        │  25:00  │          │  支持三种样式切换
│        │ (进度环)│          │
│        └─────────┘          │
│                             │
│      [开始] [重置]          │  控制按钮
│                             │
│    今日已完成：3 个番茄      │  今日统计卡片
│                             │
├─────────────────────────────┤
│  📊 查看统计记录            │  统计页入口
└─────────────────────────────┘
```

### 设置页面布局

```
┌─────────────────────────────┐
│  ← 设置                     │
├─────────────────────────────┤
│  计时设置                   │
│  ─────────────────────────  │
│  番茄时长           25 分钟 │
│  短休息            [开关]   │
│  └ 休息时长          5 分钟 │
│  长休息            [开关]   │
│  └ 休息时长         15 分钟 │
│  └ 长休息间隔         4 个  │
├─────────────────────────────┤
│  显示设置                   │
│  ─────────────────────────  │
│  显示样式           [混合]  │
├─────────────────────────────┤
│  提醒设置                   │
│  ─────────────────────────  │
│  完成行为       [等待确认]  │
│  振动提醒          [开关]   │
│  提示音            [开关]   │
└─────────────────────────────┘
```

### 统计页面布局

```
┌─────────────────────────────┐
│  ← 统计                     │
├─────────────────────────────┤
│  ┌───────┐ ┌───────┐ ┌───────┐
│  │今日   │ │本周   │ │本月   │
│  │ 5个   │ │ 23个  │ │ 89个  │
│  │ 2h5m  │ │ 9h35m │ │37h15m │
│  └───────┘ └───────┘ └───────┘
├─────────────────────────────┤
│  每日趋势                   │
│  ▁▂▃▅▇▅▃▂▁                 │  简易柱状图
│  一 二 三 四 五 六 日        │
├─────────────────────────────┤
│  最长连续：12 天            │
│  平均每日：3.2 个           │
├─────────────────────────────┤
│  历史记录                   │
│  ─────────────────────────  │
│  今天 14:30  25分钟 ✓       │
│  今天 13:00  25分钟 ✓       │
│  昨天 20:15  25分钟 ✓       │
└─────────────────────────────┘
```

## UI 风格

### 配色

- 主色：`AppColors.primary`（淡蓝色 #5B9BD5）
- 番茄元素：淡红色 `#FF8A80`
- 休息状态：淡绿色 `AppColors.success`（#52C41A）
- 背景：`AppColors.background`（#F5F5F5）
- 文字：`AppColors.textPrimary/Secondary/Tertiary`

### 设计特点

- 扁平设计，无立体感
- 卡片圆角 12-16px，阴影 elevation: 2
- 进度环：细线、淡色、无渐变
- 图标：线性风格，简洁
- 分隔线：使用 `AppColors.divider`

### 计时器三种显示样式

| 样式 | 描述 |
|------|------|
| 计时器形态 | 圆环进度 + 内部时间数字，圆环随进度填充 |
| 独立元素 | 圆形淡红色色块 + 旁边独立的时间数字显示 |
| 混合形态 | 圆形淡红色色块 + 内部时间数字 + 外圈细进度环 |

初始使用圆形代替番茄图标，后续可替换为番茄图片素材。

## 数据存储

### SQLite 表结构

```sql
CREATE TABLE pomodoro_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  started_at INTEGER NOT NULL,      -- 毫秒时间戳
  duration_seconds INTEGER NOT NULL,
  type TEXT NOT NULL,               -- 'work', 'short_break', 'long_break'
  completed INTEGER NOT NULL DEFAULT 1
);
```

### 设置存储

使用 `SharedPreferences` 存储用户设置，JSON 格式序列化。

## 技术要点

### 计时器实现

- 使用 `Timer.periodic(Duration(seconds: 1), ...)` 实现倒计时
- 参考现有 `TimerService` 模式
- 使用 `ChangeNotifier` 管理状态

### 提醒功能

- 振动：使用 `vibration` 包
- 提示音：使用 `audioplayers` 包或系统默认音

### 数据库

- 复用现有 `DatabaseService`
- 新增 `pomodoro_records` 表

### 状态管理

- `PomodoroService` 继承 `ChangeNotifier`
- 使用 `Consumer<PomodoroService>` 监听状态变化

## 工具注册

在 `main.dart` 中注册：

```dart
ToolRegistry.register(PomodoroTool());
```

工具分类：`ToolCategory.life`（生活实用）
格子大小：`gridSize: 1`

## 验收标准

1. 番茄计时功能正常，支持开始、暂停、继续、重置
2. 休息计时功能正常，支持短休息和长休息
3. 三种显示样式可正常切换
4. 设置项可正常保存和读取
5. 计时结束时有振动和/或提示音提醒
6. 统计页显示今日/本周/本月数据
7. 历史记录可正常查看
8. 番茄记录数据正确持久化