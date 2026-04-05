# Debug TAB 功能设计文档

**Date:** 2026-04-05  
**Status:** Approved  
**Base Commit:** d0fcc66f05075e69b3f513066fe9042ba3c9c4f5

## 概述

在 APP 底部导航栏新增一个 "debug" TAB，用于开发调试。该页面包含六个功能入口按钮和一个实时日志展示区域。

## 需求

1. **新增 TAB**: 在现有 "格子" 和 "我的" 两个 TAB 之间（或之后）添加第三个 TAB "debug"
2. **六个按钮**: 页面顶部显示六个按钮，标签为 "页面1" 到 "页面6"，点击后进入对应页面（先不实现具体页面）
3. **日志展示**: 按钮下方是一个文本展示框，实时显示 APP 运行时产生的日志
4. **清空功能**: 可以清空日志展示框中的内容

## 架构设计

### 1. Debug 页面结构 (DebugPage)

**布局:** 垂直 Column 布局

```
┌─────────────────────────────┐
│  [页面1] [页面2] [页面3]    │  <- 第一行按钮 (Wrap 或 Grid)
│  [页面4] [页面5] [页面6]    │  <- 第二行按钮
├─────────────────────────────┤
│                             │
│      日志展示区域            │  <- Expanded 占据剩余空间
│   (ListView.builder)        │
│                             │
├─────────────────────────────┤
│       [清空日志]            │  <- 底部按钮
└─────────────────────────────┘
```

**组件:**
- 按钮区域：使用 `Wrap` 或 `GridView` 实现 2行3列布局
- 日志区域：`ListView.builder` 展示日志条目，带滚动功能
- 清空按钮：`ElevatedButton` 或 `TextButton`

**样式:**
- 遵循 Material Design 3 设计规范
- 与现有 APP 主题保持一致
- 日志条目根据级别显示不同颜色（debug=灰色, info=蓝色, warning=橙色, error=红色）

### 2. 内存日志服务 (DebugLogService)

**类定义:**

```dart
class LogEntry {
  final DateTime timestamp;
  final String level;  // 'DEBUG', 'INFO', 'WARNING', 'ERROR'
  final String message;

  LogEntry({required this.timestamp, required this.level, required this.message});
}

class DebugLogService extends ChangeNotifier {
  static final DebugLogService _instance = DebugLogService._internal();
  factory DebugLogService() => _instance;
  DebugLogService._internal();

  final List<LogEntry> _logs = [];

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void addLog(String level, String message) {
    _logs.add(LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    ));
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
```

**特点:**
- 单例模式，全局唯一实例
- 继承 `ChangeNotifier`，支持 Provider 状态管理
- 日志存储在内存中，APP 重启后清空

### 3. 日志集成方案

**修改 AppLogger:**

```dart
class AppLogger {
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('DEBUG', message);
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('INFO', message);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('WARNING', message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('ERROR', message);
  }
}
```

**集成效果:**
- 所有使用 `AppLogger` 的地方自动在 debug 页面显示
- 不影响现有控制台输出功能
- 无侵入性，业务代码无需修改

### 4. MainPage 修改

**修改内容:**

```dart
// main.dart 中的 MainPage 类

final _pages = const [
  GridPage(),
  ProfilePage(),
  DebugPage(),  // 新增
];

// ...

BottomNavigationBar(
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.grid_view),
      label: '格子',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '我的',
    ),
    BottomNavigationBarItem(  // 新增
      icon: Icon(Icons.construction),  // 或 Icons.bug_report
      label: 'debug',
    ),
  ],
)
```

**Provider 注册:**

```dart
// 在 MyApp 的 MultiProvider 中添加
ChangeNotifierProvider(create: (_) => DebugLogService()),
```

## 文件变更

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `lib/core/services/debug_log_service.dart` | 新增 | 日志服务 |
| `lib/pages/debug_page.dart` | 新增 | Debug 页面 |
| `lib/core/utils/logger.dart` | 修改 | 集成 DebugLogService |
| `lib/main.dart` | 修改 | 添加 TAB 和 Provider |

## 依赖

- 使用现有 `provider` 包进行状态管理
- 使用现有 `logger` 包进行控制台输出
- 无需新增依赖

## 测试考虑

1. 验证日志是否正确显示在 debug 页面
2. 验证清空按钮功能正常
3. 验证页面切换后日志仍然保留（内存中）
4. 验证大量日志时滚动性能

## 后续扩展

- 六个按钮对应的具体页面实现
- 日志导出到文件功能
- 日志级别过滤
- 日志搜索功能
