# 番茄钟功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现番茄钟工具模块，支持计时、休息管理、数据统计功能

**Architecture:** 使用 Flutter + Provider 状态管理，SQLite 持久化数据，遵循项目现有工具模块结构

**Tech Stack:** Flutter, Provider, SQLite, SharedPreferences, vibration, audioplayers

---

## 文件结构

```
lib/tools/pomodoro/
├── pomodoro_tool.dart              # 工具入口
├── pomodoro_page.dart              # 主页面
├── models/
│   ├── pomodoro_state.dart         # 计时器状态
│   ├── pomodoro_record.dart        # 记录数据模型
│   └── pomodoro_settings.dart      # 设置数据模型
├── services/
│   ├── pomodoro_service.dart       # 计时器核心逻辑
│   └── pomodoro_stats_service.dart # 统计数据存取
├── widgets/
│   ├── timer_display.dart          # 计时器显示
│   ├── progress_ring.dart          # 进度环
│   └── stats_summary_card.dart     # 今日统计卡片
└── pages/
    ├── settings_page.dart          # 设置页面
    └── stats_page.dart             # 统计页面
```

**修改文件:**
- `lib/core/constants/app_constants.dart` - 数据库版本升级
- `lib/core/services/database_service.dart` - 添加番茄记录表
- `lib/main.dart` - 注册 PomodoroTool
- `pubspec.yaml` - 添加 vibration、audioplayers 依赖

---

## Task 1: 添加依赖

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 添加依赖**

在 `pubspec.yaml` 的 `dependencies` 部分添加：

```yaml
  # 振动
  vibration: ^2.0.0

  # 音频播放
  audioplayers: ^6.0.0

  # 本地存储
  shared_preferences: ^2.2.0
```

- [ ] **Step 2: 安装依赖**

Run: `cd app && flutter pub get`
Expected: 依赖安装成功

- [ ] **Step 3: Commit**

```bash
git add app/pubspec.yaml
git commit -m "chore(pomodoro): add vibration and audioplayers dependencies"
```

---

## Task 2: 更新数据库版本和表结构

**Files:**
- Modify: `lib/core/constants/app_constants.dart`
- Modify: `lib/core/services/database_service.dart`

- [ ] **Step 1: 更新数据库版本号**

修改 `lib/core/constants/app_constants.dart`:

```dart
static const int dbVersion = 4;
```

- [ ] **Step 2: 在 _onCreate 中添加番茄记录表**

在 `lib/core/services/database_service.dart` 的 `_onCreate` 方法中，在 `alarms` 表之后添加：

```dart
    // 番茄钟记录表
    await db.execute('''
      CREATE TABLE pomodoro_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        started_at INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        type TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 1
      )
    ''');
```

- [ ] **Step 3: 在 _onUpgrade 中添加迁移逻辑**

在 `_onUpgrade` 方法末尾添加：

```dart
    if (oldVersion < 4) {
      // 添加番茄钟记录表
      await db.execute('''
        CREATE TABLE pomodoro_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          started_at INTEGER NOT NULL,
          duration_seconds INTEGER NOT NULL,
          type TEXT NOT NULL,
          completed INTEGER NOT NULL DEFAULT 1
        )
      ''');
      AppLogger.i('Added pomodoro_records table');
    }
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/core/constants/app_constants.dart app/lib/core/services/database_service.dart
git commit -m "feat(pomodoro): add pomodoro_records table to database"
```

---

## Task 3: 创建数据模型

**Files:**
- Create: `lib/tools/pomodoro/models/pomodoro_state.dart`
- Create: `lib/tools/pomodoro/models/pomodoro_record.dart`
- Create: `lib/tools/pomodoro/models/pomodoro_settings.dart`

- [ ] **Step 1: 创建 pomodoro_state.dart**

```dart
enum PomodoroStatus {
  idle,
  running,
  paused,
  completed,
  waiting,
  breakRunning,
  breakCompleted,
}

class PomodoroState {
  final PomodoroStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedCount;
  final int currentStreak;
  final bool isBreak;
  final bool isLongBreak;

  const PomodoroState({
    this.status = PomodoroStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.completedCount = 0,
    this.currentStreak = 0,
    this.isBreak = false,
    this.isLongBreak = false,
  });

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  PomodoroState copyWith({
    PomodoroStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedCount,
    int? currentStreak,
    bool? isBreak,
    bool? isLongBreak,
  }) {
    return PomodoroState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedCount: completedCount ?? this.completedCount,
      currentStreak: currentStreak ?? this.currentStreak,
      isBreak: isBreak ?? this.isBreak,
      isLongBreak: isLongBreak ?? this.isLongBreak,
    );
  }
}
```

- [ ] **Step 2: 创建 pomodoro_record.dart**

```dart
enum PomodoroType { work, shortBreak, longBreak }

class PomodoroRecord {
  final int? id;
  final DateTime startedAt;
  final int durationSeconds;
  final PomodoroType type;
  final bool completed;

  const PomodoroRecord({
    this.id,
    required this.startedAt,
    required this.durationSeconds,
    required this.type,
    this.completed = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'started_at': startedAt.millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
      'type': type.name,
      'completed': completed ? 1 : 0,
    };
  }

  factory PomodoroRecord.fromMap(Map<String, dynamic> map) {
    return PomodoroRecord(
      id: map['id'] as int?,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      durationSeconds: map['duration_seconds'] as int,
      type: PomodoroType.values.firstWhere((e) => e.name == map['type']),
      completed: (map['completed'] as int) == 1,
    );
  }

  PomodoroRecord copyWith({
    int? id,
    DateTime? startedAt,
    int? durationSeconds,
    PomodoroType? type,
    bool? completed,
  }) {
    return PomodoroRecord(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      type: type ?? this.type,
      completed: completed ?? this.completed,
    );
  }
}
```

- [ ] **Step 3: 创建 pomodoro_settings.dart**

```dart
import 'dart:convert';

enum DisplayStyle { timer, independent, mixed }

enum CompleteAction { autoProceed, waitConfirm }

class PomodoroSettings {
  final int workDuration;
  final bool shortBreakEnabled;
  final int shortBreakDuration;
  final bool longBreakEnabled;
  final int longBreakDuration;
  final int longBreakInterval;
  final DisplayStyle displayStyle;
  final CompleteAction completeAction;
  final bool vibrationEnabled;
  final bool soundEnabled;

  const PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakEnabled = true,
    this.shortBreakDuration = 5,
    this.longBreakEnabled = true,
    this.longBreakDuration = 15,
    this.longBreakInterval = 4,
    this.displayStyle = DisplayStyle.mixed,
    this.completeAction = CompleteAction.waitConfirm,
    this.vibrationEnabled = true,
    this.soundEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'workDuration': workDuration,
      'shortBreakEnabled': shortBreakEnabled,
      'shortBreakDuration': shortBreakDuration,
      'longBreakEnabled': longBreakEnabled,
      'longBreakDuration': longBreakDuration,
      'longBreakInterval': longBreakInterval,
      'displayStyle': displayStyle.name,
      'completeAction': completeAction.name,
      'vibrationEnabled': vibrationEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory PomodoroSettings.fromMap(Map<String, dynamic> map) {
    return PomodoroSettings(
      workDuration: map['workDuration'] as int? ?? 25,
      shortBreakEnabled: map['shortBreakEnabled'] as bool? ?? true,
      shortBreakDuration: map['shortBreakDuration'] as int? ?? 5,
      longBreakEnabled: map['longBreakEnabled'] as bool? ?? true,
      longBreakDuration: map['longBreakDuration'] as int? ?? 15,
      longBreakInterval: map['longBreakInterval'] as int? ?? 4,
      displayStyle: map['displayStyle'] != null
          ? DisplayStyle.values.firstWhere((e) => e.name == map['displayStyle'])
          : DisplayStyle.mixed,
      completeAction: map['completeAction'] != null
          ? CompleteAction.values.firstWhere((e) => e.name == map['completeAction'])
          : CompleteAction.waitConfirm,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      soundEnabled: map['soundEnabled'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory PomodoroSettings.fromJson(String source) {
    return PomodoroSettings.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  PomodoroSettings copyWith({
    int? workDuration,
    bool? shortBreakEnabled,
    int? shortBreakDuration,
    bool? longBreakEnabled,
    int? longBreakDuration,
    int? longBreakInterval,
    DisplayStyle? displayStyle,
    CompleteAction? completeAction,
    bool? vibrationEnabled,
    bool? soundEnabled,
  }) {
    return PomodoroSettings(
      workDuration: workDuration ?? this.workDuration,
      shortBreakEnabled: shortBreakEnabled ?? this.shortBreakEnabled,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakEnabled: longBreakEnabled ?? this.longBreakEnabled,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      displayStyle: displayStyle ?? this.displayStyle,
      completeAction: completeAction ?? this.completeAction,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/tools/pomodoro/models/
git commit -m "feat(pomodoro): add data models (State, Record, Settings)"
```

---

## Task 4: 创建统计数据服务

**Files:**
- Create: `lib/tools/pomodoro/services/pomodoro_stats_service.dart`

- [ ] **Step 1: 创建 pomodoro_stats_service.dart**

```dart
import '../../../core/services/database_service.dart';
import '../models/pomodoro_record.dart';

class PomodoroStatsService {
  // 插入记录
  Future<void> insertRecord(PomodoroRecord record) async {
    final db = await DatabaseService.database;
    await db.insert('pomodoro_records', record.toMap());
  }

  // 获取今日记录
  Future<List<PomodoroRecord>> getTodayRecords() async {
    final db = await DatabaseService.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND type = ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, PomodoroType.work.name],
      orderBy: 'started_at DESC',
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }

  // 获取今日完成的番茄数
  Future<int> getTodayCount() async {
    final records = await getTodayRecords();
    return records.where((r) => r.completed).length;
  }

  // 获取今日总专注时长（分钟）
  Future<int> getTodayDuration() async {
    final records = await getTodayRecords();
    return records
        .where((r) => r.completed)
        .fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60;
  }

  // 获取本周记录
  Future<List<PomodoroRecord>> getWeekRecords() async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND type = ?',
      whereArgs: [start.millisecondsSinceEpoch, PomodoroType.work.name],
      orderBy: 'started_at DESC',
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }

  // 获取本月记录
  Future<List<PomodoroRecord>> getMonthRecords() async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final maps = await db.query(
      'pomodoro_records',
      where: 'started_at >= ? AND type = ?',
      whereArgs: [startOfMonth.millisecondsSinceEpoch, PomodoroType.work.name],
      orderBy: 'started_at DESC',
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }

  // 获取统计汇总
  Future<Map<String, dynamic>> getStatsSummary() async {
    final todayRecords = await getTodayRecords();
    final weekRecords = await getWeekRecords();
    final monthRecords = await getMonthRecords();

    final todayCompleted = todayRecords.where((r) => r.completed).toList();
    final weekCompleted = weekRecords.where((r) => r.completed).toList();
    final monthCompleted = monthRecords.where((r) => r.completed).toList();

    return {
      'todayCount': todayCompleted.length,
      'todayDuration': todayCompleted.fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60,
      'weekCount': weekCompleted.length,
      'weekDuration': weekCompleted.fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60,
      'monthCount': monthCompleted.length,
      'monthDuration': monthCompleted.fold(0, (sum, r) => sum + r.durationSeconds) ~/ 60,
    };
  }

  // 获取每日趋势（最近7天）
  Future<List<Map<String, dynamic>>> getDailyTrend({int days = 7}) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));

      final maps = await db.query(
        'pomodoro_records',
        where: 'started_at >= ? AND started_at < ? AND type = ? AND completed = ?',
        whereArgs: [
          start.millisecondsSinceEpoch,
          end.millisecondsSinceEpoch,
          PomodoroType.work.name,
          1,
        ],
      );

      result.add({
        'date': start,
        'count': maps.length,
      });
    }

    return result;
  }

  // 获取最长连续天数
  Future<int> getMaxStreak() async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'pomodoro_records',
      where: 'type = ? AND completed = ?',
      whereArgs: [PomodoroType.work.name, 1],
      orderBy: 'started_at DESC',
    );

    if (maps.isEmpty) return 0;

    final records = maps.map((m) => PomodoroRecord.fromMap(m)).toList();
    final dates = <DateTime>{};

    for (final r in records) {
      final d = DateTime(r.startedAt.year, r.startedAt.month, r.startedAt.day);
      dates.add(d);
    }

    final sortedDates = dates.toList()..sort((a, b) => b.compareTo(a));

    int maxStreak = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final date in sortedDates) {
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final diff = lastDate.difference(date).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          if (currentStreak > maxStreak) maxStreak = currentStreak;
          currentStreak = 1;
        }
      }
      lastDate = date;
    }

    if (currentStreak > maxStreak) maxStreak = currentStreak;
    return maxStreak;
  }

  // 获取平均每日番茄数（最近30天）
  Future<double> getAverageDailyCount() async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count, DATE(started_at / 1000, 'unixepoch') as date
      FROM pomodoro_records
      WHERE started_at >= ? AND type = ? AND completed = 1
      GROUP BY date
    ''', [start.millisecondsSinceEpoch, PomodoroType.work.name]);

    if (result.isEmpty) return 0;

    final total = result.fold<int>(0, (sum, r) => sum + (r['count'] as int));
    final days = result.length;

    return total / days;
  }

  // 获取历史记录（分页）
  Future<List<PomodoroRecord>> getHistoryRecords({
    int limit = 50,
    int offset = 0,
  }) async {
    final db = await DatabaseService.database;

    final maps = await db.query(
      'pomodoro_records',
      orderBy: 'started_at DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((m) => PomodoroRecord.fromMap(m)).toList();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/pomodoro/services/pomodoro_stats_service.dart
git commit -m "feat(pomodoro): add stats service for data queries"
```

---

## Task 5: 创建番茄钟核心服务

**Files:**
- Create: `lib/tools/pomodoro/services/pomodoro_service.dart`

- [ ] **Step 1: 创建 pomodoro_service.dart**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pomodoro_state.dart';
import '../models/pomodoro_settings.dart';
import '../models/pomodoro_record.dart';
import 'pomodoro_stats_service.dart';

class PomodoroService extends ChangeNotifier {
  PomodoroState _state = const PomodoroState();
  PomodoroSettings _settings = const PomodoroSettings();
  Timer? _timer;
  DateTime? _startedAt;
  final PomodoroStatsService _statsService = PomodoroStatsService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  PomodoroState get state => _state;
  PomodoroSettings get settings => _settings;

  // 加载设置
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('pomodoro_settings');
    if (settingsJson != null) {
      _settings = PomodoroSettings.fromJson(settingsJson);
    }
    await _loadTodayCount();
    notifyListeners();
  }

  // 保存设置
  Future<void> saveSettings(PomodoroSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pomodoro_settings', settings.toJson());
    notifyListeners();
  }

  // 加载今日已完成数
  Future<void> _loadTodayCount() async {
    final count = await _statsService.getTodayCount();
    _state = _state.copyWith(completedCount: count);
  }

  // 开始番茄计时
  void startWork() {
    _startedAt = DateTime.now();
    final duration = _settings.workDuration * 60;

    _state = _state.copyWith(
      status: PomodoroStatus.running,
      remainingSeconds: duration,
      totalSeconds: duration,
      isBreak: false,
      isLongBreak: false,
    );
    notifyListeners();

    _startTimer();
  }

  // 开始休息
  void startBreak({bool isLong = false}) {
    _startedAt = DateTime.now();
    final duration = isLong
        ? _settings.longBreakDuration * 60
        : _settings.shortBreakDuration * 60;

    _state = _state.copyWith(
      status: PomodoroStatus.breakRunning,
      remainingSeconds: duration,
      totalSeconds: duration,
      isBreak: true,
      isLongBreak: isLong,
    );
    notifyListeners();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.remainingSeconds <= 1) {
        _finishTimer();
      } else {
        _state = _state.copyWith(
          remainingSeconds: _state.remainingSeconds - 1,
        );
        notifyListeners();
      }
    });
  }

  void _finishTimer() {
    _timer?.cancel();

    if (_state.isBreak) {
      // 休息结束
      _state = _state.copyWith(
        status: PomodoroStatus.breakCompleted,
        remainingSeconds: 0,
      );
      notifyListeners();
      _notifyUser();
      _handleBreakComplete();
    } else {
      // 番茄结束
      _state = _state.copyWith(
        status: PomodoroStatus.completed,
        remainingSeconds: 0,
      );
      notifyListeners();
      _notifyUser();
      _handleWorkComplete();
    }
  }

  Future<void> _handleWorkComplete() async {
    // 保存记录
    if (_startedAt != null) {
      await _statsService.insertRecord(PomodoroRecord(
        startedAt: _startedAt!,
        durationSeconds: _state.totalSeconds,
        type: PomodoroType.work,
        completed: true,
      ));
    }

    // 更新计数
    final newStreak = _state.currentStreak + 1;
    _state = _state.copyWith(
      completedCount: _state.completedCount + 1,
      currentStreak: newStreak,
    );
    notifyListeners();

    // 根据设置决定下一步
    if (_settings.completeAction == CompleteAction.autoProceed) {
      _proceedToBreak();
    } else {
      _state = _state.copyWith(status: PomodoroStatus.waiting);
      notifyListeners();
    }
  }

  void _handleBreakComplete() {
    if (_settings.completeAction == CompleteAction.autoProceed) {
      startWork();
    } else {
      _state = _state.copyWith(status: PomodoroStatus.waiting);
      notifyListeners();
    }
  }

  void _proceedToBreak() {
    // 判断是否需要长休息
    final needLongBreak = _settings.longBreakEnabled &&
        _state.currentStreak > 0 &&
        _state.currentStreak % _settings.longBreakInterval == 0;

    if (needLongBreak) {
      startBreak(isLong: true);
    } else if (_settings.shortBreakEnabled) {
      startBreak(isLong: false);
    } else {
      startWork();
    }
  }

  // 用户确认进入下一步
  void proceed() {
    if (_state.status == PomodoroStatus.completed) {
      _proceedToBreak();
    } else if (_state.status == PomodoroStatus.breakCompleted) {
      startWork();
    }
  }

  // 暂停
  void pause() {
    if (_state.status != PomodoroStatus.running &&
        _state.status != PomodoroStatus.breakRunning) return;

    _timer?.cancel();
    _state = _state.copyWith(status: PomodoroStatus.paused);
    notifyListeners();
  }

  // 继续
  void resume() {
    if (_state.status != PomodoroStatus.paused) return;

    _state = _state.copyWith(
      status: _state.isBreak
          ? PomodoroStatus.breakRunning
          : PomodoroStatus.running,
    );
    notifyListeners();
    _startTimer();
  }

  // 重置
  void reset() {
    _timer?.cancel();
    _state = const PomodoroState();
    _startedAt = null;
    _loadTodayCount();
    notifyListeners();
  }

  // 提醒用户
  Future<void> _notifyUser() async {
    if (_settings.vibrationEnabled) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }
    }

    if (_settings.soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/pomodoro/services/pomodoro_service.dart
git commit -m "feat(pomodoro): add core timer service with state management"
```

---

## Task 6: 创建 UI 组件

**Files:**
- Create: `lib/tools/pomodoro/widgets/progress_ring.dart`
- Create: `lib/tools/pomodoro/widgets/timer_display.dart`
- Create: `lib/tools/pomodoro/widgets/stats_summary_card.dart`

- [ ] **Step 1: 创建 progress_ring.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress.clamp(0.0, 1.0),
          strokeWidth: strokeWidth,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 背景环
    final bgPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 进度环
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
```

- [ ] **Step 2: 创建 timer_display.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/pomodoro_state.dart';
import '../models/pomodoro_settings.dart';
import 'progress_ring.dart';

class TimerDisplay extends StatelessWidget {
  final PomodoroState state;
  final PomodoroSettings settings;

  const TimerDisplay({
    super.key,
    required this.state,
    required this.settings,
  });

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _backgroundColor {
    if (state.isBreak) {
      return AppColors.success.withAlpha((0.2 * 255).round());
    }
    return const Color(0xFFFF8A80).withAlpha((0.3 * 255).round());
  }

  Color get _ringColor {
    if (state.isBreak) {
      return AppColors.success;
    }
    return const Color(0xFFFF8A80);
  }

  @override
  Widget build(BuildContext context) {
    switch (settings.displayStyle) {
      case DisplayStyle.timer:
        return _buildTimerStyle();
      case DisplayStyle.independent:
        return _buildIndependentStyle();
      case DisplayStyle.mixed:
        return _buildMixedStyle();
    }
  }

  // 计时器形态：圆环进度 + 内部时间
  Widget _buildTimerStyle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ProgressRing(
          progress: state.progress,
          size: 220,
          strokeWidth: 10,
          color: _ringColor,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(state.remainingSeconds),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (state.isBreak)
              Text(
                state.isLongBreak ? '长休息' : '短休息',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // 独立元素：圆形色块 + 旁边独立时间
  Widget _buildIndependentStyle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            state.isBreak ? Icons.coffee : Icons.circle,
            size: 48,
            color: _ringColor,
          ),
        ),
        const SizedBox(width: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatTime(state.remainingSeconds),
              style: const TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              state.isBreak
                  ? (state.isLongBreak ? '长休息中' : '短休息中')
                  : '专注中',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 混合形态：圆形色块 + 内部时间 + 外圈进度
  Widget _buildMixedStyle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        ProgressRing(
          progress: state.progress,
          size: 220,
          strokeWidth: 6,
          color: _ringColor,
        ),
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.isBreak ? Icons.coffee : Icons.circle,
                size: 32,
                color: _ringColor,
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(state.remainingSeconds),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (state.isBreak)
                Text(
                  state.isLongBreak ? '长休息' : '短休息',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: 创建 stats_summary_card.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

class StatsSummaryCard extends StatelessWidget {
  final int todayCount;

  const StatsSummaryCard({
    super.key,
    required this.todayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timer,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日已完成',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$todayCount 个番茄',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/tools/pomodoro/widgets/
git commit -m "feat(pomodoro): add UI widgets (ProgressRing, TimerDisplay, StatsSummaryCard)"
```

---

## Task 7: 创建设置页面

**Files:**
- Create: `lib/tools/pomodoro/pages/settings_page.dart`

- [ ] **Step 1: 创建 settings_page.dart**

```dart
import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/pomodoro_settings.dart';
import '../services/pomodoro_service.dart';

class PomodoroSettingsPage extends StatefulWidget {
  final PomodoroSettings initialSettings;
  final Function(PomodoroSettings) onSaved;

  const PomodoroSettingsPage({
    super.key,
    required this.initialSettings,
    required this.onSaved,
  });

  @override
  State<PomodoroSettingsPage> createState() => _PomodoroSettingsPageState();
}

class _PomodoroSettingsPageState extends State<PomodoroSettingsPage> {
  late PomodoroSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSaved(_settings);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection('计时设置', [
            _buildNumberTile(
              title: '番茄时长',
              value: _settings.workDuration,
              unit: '分钟',
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(workDuration: v);
              }),
            ),
            _buildSwitchTile(
              title: '短休息',
              value: _settings.shortBreakEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(shortBreakEnabled: v);
              }),
            ),
            if (_settings.shortBreakEnabled)
              _buildNumberTile(
                title: '休息时长',
                value: _settings.shortBreakDuration,
                unit: '分钟',
                indent: true,
                onChanged: (v) => setState(() {
                  _settings = _settings.copyWith(shortBreakDuration: v);
                }),
              ),
            _buildSwitchTile(
              title: '长休息',
              value: _settings.longBreakEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(longBreakEnabled: v);
              }),
            ),
            if (_settings.longBreakEnabled) ...[
              _buildNumberTile(
                title: '休息时长',
                value: _settings.longBreakDuration,
                unit: '分钟',
                indent: true,
                onChanged: (v) => setState(() {
                  _settings = _settings.copyWith(longBreakDuration: v);
                }),
              ),
              _buildNumberTile(
                title: '长休息间隔',
                value: _settings.longBreakInterval,
                unit: '个',
                indent: true,
                onChanged: (v) => setState(() {
                  _settings = _settings.copyWith(longBreakInterval: v);
                }),
              ),
            ],
          ]),
          _buildSection('显示设置', [
            _buildEnumTile<DisplayStyle>(
              title: '显示样式',
              value: _settings.displayStyle,
              options: {
                DisplayStyle.timer: '计时器形态',
                DisplayStyle.independent: '独立元素',
                DisplayStyle.mixed: '混合形态',
              },
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(displayStyle: v);
              }),
            ),
          ]),
          _buildSection('提醒设置', [
            _buildEnumTile<CompleteAction>(
              title: '完成行为',
              value: _settings.completeAction,
              options: {
                CompleteAction.autoProceed: '自动进入休息',
                CompleteAction.waitConfirm: '等待用户确认',
              },
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(completeAction: v);
              }),
            ),
            _buildSwitchTile(
              title: '振动提醒',
              value: _settings.vibrationEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(vibrationEnabled: v);
              }),
            ),
            _buildSwitchTile(
              title: '提示音',
              value: _settings.soundEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(soundEnabled: v);
              }),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool indent = false,
  }) {
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ).copyWith(left: indent ? 32 : 16),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildNumberTile({
    required String title,
    required int value,
    required String unit,
    required ValueChanged<int> onChanged,
    bool indent = false,
  }) {
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ).copyWith(left: indent ? 32 : 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text(
            '$value $unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < 60 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEnumTile<T>({
    required String title,
    required T value,
    required Map<T, String> options,
    required ValueChanged<T> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        options[value]!,
        style: const TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(title),
            children: options.entries.map((e) {
              return RadioListTile<T>(
                title: Text(e.value),
                value: e.key,
                groupValue: value,
                onChanged: (v) {
                  if (v != null) {
                    onChanged(v);
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/pomodoro/pages/settings_page.dart
git commit -m "feat(pomodoro): add settings page"
```

---

## Task 8: 创建统计页面

**Files:**
- Create: `lib/tools/pomodoro/pages/stats_page.dart`

- [ ] **Step 1: 创建 stats_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/ui/app_colors.dart';
import '../models/pomodoro_record.dart';
import '../services/pomodoro_stats_service.dart';

class PomodoroStatsPage extends StatefulWidget {
  const PomodoroStatsPage({super.key});

  @override
  State<PomodoroStatsPage> createState() => _PomodoroStatsPageState();
}

class _PomodoroStatsPageState extends State<PomodoroStatsPage> {
  final PomodoroStatsService _statsService = PomodoroStatsService();
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>>? _trend;
  int? _maxStreak;
  double? _avgDaily;
  List<PomodoroRecord>? _history;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await _statsService.getStatsSummary();
    final trend = await _statsService.getDailyTrend();
    final maxStreak = await _statsService.getMaxStreak();
    final avgDaily = await _statsService.getAverageDailyCount();
    final history = await _statsService.getHistoryRecords();

    setState(() {
      _summary = summary;
      _trend = trend;
      _maxStreak = maxStreak;
      _avgDaily = avgDaily;
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
      ),
      body: _summary == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildTrendChart(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildStatCard(
          '今日',
          '${_summary!['todayCount']}个',
          _formatDuration(_summary!['todayDuration'] as int),
        ),
        _buildStatCard(
          '本周',
          '${_summary!['weekCount']}个',
          _formatDuration(_summary!['weekDuration'] as int),
        ),
        _buildStatCard(
          '本月',
          '${_summary!['monthCount']}个',
          _formatDuration(_summary!['monthDuration'] as int),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, String duration) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              duration,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) {
      return '${h}h${m}m';
    }
    return '${m}m';
  }

  Widget _buildTrendChart() {
    if (_trend == null || _trend!.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = _trend!.map((d) => d['count'] as int).reduce((a, b) => a > b ? a : b);
    final barGroups = _trend!.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: (e.value['count'] as int).toDouble(),
            color: AppColors.primary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '每日趋势',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 2).toDouble(),
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
                        if (value.toInt() < weekdays.length) {
                          return Text(
                            weekdays[value.toInt()],
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  '最长连续',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_maxStreak ?? 0} 天',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  '平均每日',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_avgDaily ?? 0).toStringAsFixed(1)} 个',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history == null || _history!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '历史记录',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          ...(_history!.take(20).map((r) => _buildHistoryItem(r))),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(PomodoroRecord record) {
    final time = '${record.startedAt.hour.toString().padLeft(2, '0')}:${record.startedAt.minute.toString().padLeft(2, '0')}';
    final date = _formatDate(record.startedAt);
    final duration = record.durationSeconds ~/ 60;

    String typeLabel;
    Color typeColor;
    switch (record.type) {
      case PomodoroType.work:
        typeLabel = '专注';
        typeColor = const Color(0xFFFF8A80);
        break;
      case PomodoroType.shortBreak:
        typeLabel = '短休息';
        typeColor = AppColors.success;
        break;
      case PomodoroType.longBreak:
        typeLabel = '长休息';
        typeColor = AppColors.info;
        break;
    }

    return ListTile(
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: typeColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text('$date $time'),
      subtitle: Text('$duration分钟 · $typeLabel'),
      trailing: record.completed
          ? const Icon(Icons.check, color: AppColors.success, size: 20)
          : const Icon(Icons.close, color: AppColors.error, size: 20),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return '今天';
    if (d == yesterday) return '昨天';
    return '${date.month}/${date.day}';
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/pomodoro/pages/stats_page.dart
git commit -m "feat(pomodoro): add stats page with charts and history"
```

---

## Task 9: 创建主页面

**Files:**
- Create: `lib/tools/pomodoro/pomodoro_page.dart`

- [ ] **Step 1: 创建 pomodoro_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui/app_colors.dart';
import 'models/pomodoro_state.dart';
import 'services/pomodoro_service.dart';
import 'widgets/timer_display.dart';
import 'widgets/stats_summary_card.dart';
import 'pages/settings_page.dart';
import 'pages/stats_page.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroService>(
      builder: (context, service, child) {
        final state = service.state;
        final settings = service.settings;

        return Scaffold(
          appBar: AppBar(
            title: const Text('番茄钟'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PomodoroSettingsPage(
                        initialSettings: settings,
                        onSaved: (s) => service.saveSettings(s),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      TimerDisplay(state: state, settings: settings),
                      const SizedBox(height: 48),
                      _buildControlButtons(context, service),
                    ],
                  ),
                ),
              ),
              StatsSummaryCard(todayCount: state.completedCount),
              _buildStatsEntry(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(BuildContext context, PomodoroService service) {
    final state = service.state;

    if (state.status == PomodoroStatus.waiting) {
      return ElevatedButton(
        onPressed: service.proceed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(state.isBreak ? '开始下一个番茄' : '开始休息'),
      );
    }

    if (state.status == PomodoroStatus.idle) {
      return ElevatedButton(
        onPressed: service.startWork,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text('开始'),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state.status == PomodoroStatus.running ||
            state.status == PomodoroStatus.breakRunning)
          ElevatedButton(
            onPressed: service.pause,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: AppColors.divider),
              ),
            ),
            child: const Text('暂停'),
          ),
        if (state.status == PomodoroStatus.paused)
          ElevatedButton(
            onPressed: service.resume,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text('继续'),
          ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: service.reset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.divider),
            ),
          ),
          child: const Text('重置'),
        ),
      ],
    );
  }

  Widget _buildStatsEntry(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PomodoroStatsPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              '查看统计记录',
              style: TextStyle(
                color: AppColors.primary,
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
git add app/lib/tools/pomodoro/pomodoro_page.dart
git commit -m "feat(pomodoro): add main page with timer and controls"
```

---

## Task 10: 创建工具入口并注册

**Files:**
- Create: `lib/tools/pomodoro/pomodoro_tool.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: 创建 pomodoro_tool.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'pomodoro_page.dart';

class PomodoroTool implements ToolModule {
  @override
  String get id => 'pomodoro';

  @override
  String get name => '番茄钟';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.timer;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const PomodoroPage();
  }

  @override
  ToolSettings? get settings => null;
}
```

- [ ] **Step 2: 在 main.dart 中注册工具和 Provider**

在 `lib/main.dart` 中添加导入：

```dart
import 'tools/pomodoro/pomodoro_tool.dart';
import 'tools/pomodoro/services/pomodoro_service.dart';
```

在 `main()` 函数的注册部分添加：

```dart
ToolRegistry.register(PomodoroTool());
```

在 `MyApp` 的 `MultiProvider` 中添加 `PomodoroService`：

```dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AppProvider()),
    ChangeNotifierProvider(create: (_) => PomodoroService()..loadSettings()),
  ],
  // ...
);
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/pomodoro/pomodoro_tool.dart app/lib/main.dart
git commit -m "feat(pomodoro): register PomodoroTool"
```

---

## Task 11: 添加提示音资源

**Files:**
- Create: `assets/sounds/notification.mp3` (占位符说明)
- Modify: `pubspec.yaml`

- [ ] **Step 1: 创建资源目录和添加说明**

```bash
mkdir -p app/assets/sounds
```

注意：需要提供一个实际的音频文件 `notification.mp3`，或使用系统默认音。

- [ ] **Step 2: 更新 pubspec.yaml 资源配置**

在 `pubspec.yaml` 的 `flutter.assets` 部分添加：

```yaml
    - assets/sounds/
```

- [ ] **Step 3: Commit**

```bash
git add app/pubspec.yaml
git commit -m "chore(pomodoro): add sounds asset path"
```

---

## Task 12: 最终测试与集成

- [ ] **Step 1: 运行应用测试**

Run: `cd app && flutter run`
Expected: 应用正常启动，番茄钟工具出现在格子列表中

- [ ] **Step 2: 功能测试清单**

1. 点击番茄钟进入，检查页面正常显示
2. 点击开始，计时器开始倒计时
3. 点击暂停，计时器暂停
4. 点击继续，计时器恢复
5. 点击重置，计时器回到初始状态
6. 点击设置，检查设置页面各项可正常修改
7. 保存设置后返回，检查设置生效
8. 完成一个番茄后，检查振动/提示音
9. 进入统计页，检查数据展示

- [ ] **Step 3: 最终 Commit（如有修改）**

```bash
git add -A
git commit -m "fix(pomodoro): fix integration issues"
```

---

## 验收标准

- [ ] 番茄计时功能正常，支持开始、暂停、继续、重置
- [ ] 休息计时功能正常，支持短休息和长休息
- [ ] 三种显示样式可正常切换
- [ ] 设置项可正常保存和读取
- [ ] 计时结束时有振动和/或提示音提醒
- [ ] 统计页显示今日/本周/本月数据
- [ ] 历史记录可正常查看
- [ ] 番茄记录数据正确持久化