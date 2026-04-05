# 时钟工具实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 LittleGrid 应用中新增时钟工具，包含闹钟、倒计时、秒表三个子功能，通过 PageView 左右滑动切换。

**Architecture:** 使用 Flutter 的 PageView 实现功能切换，服务层处理后台逻辑，SQLite 持久化闹钟数据，flutter_local_notifications 实现系统通知。

**Tech Stack:** Flutter, Dart, flutter_local_notifications, timezone, Provider

---

## File Structure

| 文件 | 职责 |
|------|------|
| `lib/tools/alarm/models/alarm_item.dart` | 闹钟数据模型 |
| `lib/tools/alarm/models/timer_state.dart` | 倒计时状态模型 |
| `lib/tools/alarm/models/stopwatch_lap.dart` | 秒表计次模型 |
| `lib/tools/alarm/services/notification_service.dart` | 通知服务封装 |
| `lib/tools/alarm/services/alarm_service.dart` | 闹钟后台调度服务 |
| `lib/tools/alarm/services/timer_service.dart` | 倒计时服务 |
| `lib/tools/alarm/services/stopwatch_service.dart` | 秒表服务 |
| `lib/tools/alarm/widgets/alarm_card.dart` | 闹钟卡片组件 |
| `lib/tools/alarm/widgets/timer_display.dart` | 倒计时显示组件 |
| `lib/tools/alarm/widgets/stopwatch_display.dart` | 秒表显示组件 |
| `lib/tools/alarm/widgets/lap_list.dart` | 计次列表组件 |
| `lib/tools/alarm/widgets/time_picker_dialog.dart` | 时间选择弹窗 |
| `lib/tools/alarm/widgets/page_indicator.dart` | 页面指示器 |
| `lib/tools/alarm/pages/alarm_list_page.dart` | 闹钟列表页 |
| `lib/tools/alarm/pages/timer_page.dart` | 倒计时页 |
| `lib/tools/alarm/pages/stopwatch_page.dart` | 秒表页 |
| `lib/tools/alarm/alarm_page.dart` | 主页面（PageView 容器） |
| `lib/tools/alarm/alarm_tool.dart` | ToolModule 实现 |
| `lib/main.dart` | 注册 AlarmTool |
| `lib/core/services/database_service.dart` | 数据库迁移（添加 alarms 表） |

---

### Task 1: 数据模型

**Files:**
- Create: `lib/tools/alarm/models/alarm_item.dart`
- Create: `lib/tools/alarm/models/timer_state.dart`
- Create: `lib/tools/alarm/models/stopwatch_lap.dart`

- [ ] **Step 1: 创建闹钟数据模型**

```dart
import 'package:flutter/material.dart';

enum RepeatType { once, daily, custom }

class AlarmItem {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final RepeatType repeatType;
  final List<int> repeatDays; // 0=周日, 1-6=周一至周六
  final bool isEnabled;
  final String sound;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlarmItem({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    this.repeatType = RepeatType.once,
    this.repeatDays = const [],
    this.isEnabled = true,
    this.sound = 'default',
    required this.createdAt,
    required this.updatedAt,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  /// 计算下次响铃时间
  DateTime? get nextTriggerTime {
    final now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, hour, minute);

    switch (repeatType) {
      case RepeatType.once:
        if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
          return null; // 已过期的单次闹钟
        }
        return next;

      case RepeatType.daily:
        while (next.isBefore(now) || next.isAtSameMomentAs(now)) {
          next = next.add(const Duration(days: 1));
        }
        return next;

      case RepeatType.custom:
        if (repeatDays.isEmpty) return null;
        for (int i = 0; i < 8; i++) {
          final checkDate = next.add(Duration(days: i));
          final weekday = checkDate.weekday % 7; // 转换为 0=周日
          if ((next.isAfter(now) || i > 0) && repeatDays.contains(weekday)) {
            return checkDate;
          }
        }
        return null;
    }
  }

  String get repeatText {
    switch (repeatType) {
      case RepeatType.once:
        return '单次';
      case RepeatType.daily:
        return '每天';
      case RepeatType.custom:
        if (repeatDays.length == 5 &&
            repeatDays.containsAll([1, 2, 3, 4, 5])) {
          return '工作日';
        }
        const dayNames = ['日', '一', '二', '三', '四', '五', '六'];
        return repeatDays.map((d) => '周${dayNames[d]}').join('、');
    }
  }

  AlarmItem copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    RepeatType? repeatType,
    List<int>? repeatDays,
    bool? isEnabled,
    String? sound,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlarmItem(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      sound: sound ?? this.sound,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'repeat_type': repeatType.name,
      'repeat_days': repeatDays.toString(),
      'is_enabled': isEnabled ? 1 : 0,
      'sound': sound,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory AlarmItem.fromMap(Map<String, dynamic> map) {
    return AlarmItem(
      id: map['id'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      label: map['label'] as String? ?? '',
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == map['repeat_type'],
        orElse: () => RepeatType.once,
      ),
      repeatDays: _parseRepeatDays(map['repeat_days'] as String?),
      isEnabled: map['is_enabled'] == 1,
      sound: map['sound'] as String? ?? 'default',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  static List<int> _parseRepeatDays(String? value) {
    if (value == null || value.isEmpty) return [];
    // 解析 "[1, 2, 3]" 格式
    final match = RegExp(r'\[(.*)\]').firstMatch(value);
    if (match == null) return [];
    return match
        .group(1)!
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }
}
```

- [ ] **Step 2: 创建倒计时状态模型**

```dart
enum TimerStatus { idle, running, paused, finished }

class TimerState {
  final Duration totalDuration;
  final Duration remainingTime;
  final TimerStatus status;

  TimerState({
    this.totalDuration = Duration.zero,
    this.remainingTime = Duration.zero,
    this.status = TimerStatus.idle,
  });

  TimerState copyWith({
    Duration? totalDuration,
    Duration? remainingTime,
    TimerStatus? status,
  }) {
    return TimerState(
      totalDuration: totalDuration ?? this.totalDuration,
      remainingTime: remainingTime ?? this.remainingTime,
      status: status ?? this.status,
    );
  }

  double get progress {
    if (totalDuration.inSeconds == 0) return 0;
    return 1 - (remainingTime.inMilliseconds / totalDuration.inMilliseconds);
  }

  String get displayTime {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 3: 创建秒表计次模型**

```dart
class StopwatchLap {
  final int lapNumber;
  final Duration lapTime;
  final Duration totalTime;

  StopwatchLap({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
  });

  String get lapTimeDisplay => _formatDuration(lapTime);
  String get totalTimeDisplay => _formatDuration(totalTime);

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final centiseconds = (d.inMilliseconds % 1000) ~/ 10;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centiseconds.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 4: 提交**

```bash
git add lib/tools/alarm/models/
git commit -m "feat(alarm): add data models (AlarmItem, TimerState, StopwatchLap)"
```

---

### Task 2: 通知服务

**Files:**
- Create: `lib/tools/alarm/services/notification_service.dart`

- [ ] **Step 1: 添加依赖**

在 `pubspec.yaml` 中添加：
```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0
  flutter_native_timezone: ^2.0.0
```

运行: `cd /home/nano/littlegrid/app && flutter pub get`

- [ ] **Step 2: 创建通知服务**

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区数据库
    tz_data.initializeTimeZones();

    _plugin = FlutterLocalNotificationsPlugin();

    await _plugin!.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );

    await _createNotificationChannels();
    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin!.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'alarm_channel',
        '闹钟',
        description: '闹钟提醒通知',
        importance: Importance.high,
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'timer_channel',
        '倒计时',
        description: '倒计时结束通知',
        importance: Importance.high,
      ),
    );
  }

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _plugin!.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin!.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
  }

  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channel = 'alarm_channel',
  }) async {
    await _plugin!.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channel == 'alarm_channel' ? '闹钟' : '倒计时',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin!.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin!.cancelAll();
  }
}
```

- [ ] **Step 3: 提交**

```bash
git add pubspec.yaml lib/tools/alarm/services/notification_service.dart
git commit -m "feat(alarm): add notification service"
```

---

### Task 3: 倒计时和秒表服务

**Files:**
- Create: `lib/tools/alarm/services/timer_service.dart`
- Create: `lib/tools/alarm/services/stopwatch_service.dart`

- [ ] **Step 1: 创建倒计时服务**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timer_state.dart';
import 'notification_service.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  TimerState _state = TimerState();

  TimerState get state => _state;

  void start(Duration duration) {
    _state = TimerState(
      totalDuration: duration,
      remainingTime: duration,
      status: TimerStatus.running,
    );
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_state.remainingTime.inMilliseconds <= 100) {
        _finish();
      } else {
        _state = _state.copyWith(
          remainingTime: _state.remainingTime - const Duration(milliseconds: 100),
        );
        notifyListeners();
      }
    });
  }

  void pause() {
    if (_state.status != TimerStatus.running) return;
    _timer?.cancel();
    _state = _state.copyWith(status: TimerStatus.paused);
    notifyListeners();
  }

  void resume() {
    if (_state.status != TimerStatus.paused) return;
    _state = _state.copyWith(status: TimerStatus.running);
    notifyListeners();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_state.remainingTime.inMilliseconds <= 100) {
        _finish();
      } else {
        _state = _state.copyWith(
          remainingTime: _state.remainingTime - const Duration(milliseconds: 100),
        );
        notifyListeners();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _state = TimerState();
    notifyListeners();
  }

  void _finish() {
    _timer?.cancel();
    _state = _state.copyWith(
      remainingTime: Duration.zero,
      status: TimerStatus.finished,
    );
    notifyListeners();

    // 发送通知
    NotificationService().zonedSchedule(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '倒计时结束',
      body: '时间到！',
      scheduledDate: DateTime.now(),
      channel: 'timer_channel',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 2: 创建秒表服务**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stopwatch_lap.dart';

class StopwatchService extends ChangeNotifier {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  final List<StopwatchLap> _laps = [];
  Duration _elapsed = Duration.zero;

  bool get isRunning => _stopwatch.isRunning;
  Duration get elapsed => _elapsed;
  List<StopwatchLap> get laps => List.unmodifiable(_laps);

  void start() {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      _elapsed = _stopwatch.elapsed;
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    if (!_stopwatch.isRunning) return;

    _stopwatch.stop();
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _laps.clear();
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void addLap() {
    if (!_stopwatch.isRunning) return;

    final totalTime = _stopwatch.elapsed;
    final previousTotal = _laps.isEmpty
        ? Duration.zero
        : _laps.last.totalTime;
    final lapTime = totalTime - previousTotal;

    _laps.add(StopwatchLap(
      lapNumber: _laps.length + 1,
      lapTime: lapTime,
      totalTime: totalTime,
    ));
    notifyListeners();
  }

  String get displayTime {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;
    final centiseconds = (_elapsed.inMilliseconds % 1000) ~/ 10;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centiseconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 3: 提交**

```bash
git add lib/tools/alarm/services/timer_service.dart lib/tools/alarm/services/stopwatch_service.dart
git commit -m "feat(alarm): add timer and stopwatch services"
```

---

### Task 4: 闹钟服务与数据库迁移

**Files:**
- Create: `lib/tools/alarm/services/alarm_service.dart`
- Modify: `lib/core/services/database_service.dart`

- [ ] **Step 1: 创建闹钟服务**

```dart
import '../models/alarm_item.dart';
import 'notification_service.dart';

class AlarmService {
  final NotificationService _notificationService = NotificationService();

  Future<void> scheduleAlarm(AlarmItem alarm) async {
    final triggerTime = alarm.nextTriggerTime;
    if (triggerTime == null) return;

    await _notificationService.zonedSchedule(
      id: alarm.id.hashCode,
      title: '闹钟',
      body: alarm.label.isEmpty ? '时间到了' : alarm.label,
      scheduledDate: triggerTime,
      channel: 'alarm_channel',
    );
  }

  Future<void> cancelAlarm(String alarmId) async {
    await _notificationService.cancel(alarmId.hashCode);
  }

  Future<void> rescheduleAllAlarms(List<AlarmItem> alarms) async {
    for (final alarm in alarms.where((a) => a.isEnabled)) {
      await scheduleAlarm(alarm);
    }
  }
}
```

- [ ] **Step 2: 更新数据库服务**

在 `database_service.dart` 中：
1. 更新数据库版本号
2. 添加闹钟表创建语句
3. 添加迁移逻辑

需要先读取现有的 database_service.dart 文件了解当前结构。

- [ ] **Step 3: 提交**

```bash
git add lib/tools/alarm/services/alarm_service.dart lib/core/services/database_service.dart
git commit -m "feat(alarm): add alarm service and database migration"
```

---

### Task 5: UI 组件

**Files:**
- Create: `lib/tools/alarm/widgets/page_indicator.dart`
- Create: `lib/tools/alarm/widgets/alarm_card.dart`
- Create: `lib/tools/alarm/widgets/timer_display.dart`
- Create: `lib/tools/alarm/widgets/stopwatch_display.dart`
- Create: `lib/tools/alarm/widgets/lap_list.dart`
- Create: `lib/tools/alarm/widgets/time_picker_dialog.dart`

- [ ] **Step 1: 创建页面指示器组件**

```dart
import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final List<String> labels;

  const PageIndicator({
    super.key,
    required this.currentPage,
    this.pageCount = 3,
    this.labels = const ['闹钟', '倒计时', '秒表'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final isSelected = index == currentPage;
          return GestureDetector(
            onTap: () {
              // 由父组件处理
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 2: 创建闹钟卡片组件**

```dart
import 'package:flutter/material.dart';
import '../models/alarm_item.dart';

class AlarmCard extends StatelessWidget {
  final AlarmItem alarm;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          onTap: onTap,
          title: Row(
            children: [
              Text(
                '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 32,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w300,
                ),
              ),
              if (alarm.label.isNotEmpty) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    alarm.label,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(alarm.repeatText),
          trailing: Switch(
            value: alarm.isEnabled,
            onChanged: (_) => onToggle(),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: 创建倒计时显示组件**

```dart
import 'package:flutter/material.dart';
import '../models/timer_state.dart';

class TimerDisplay extends StatelessWidget {
  final TimerState state;

  const TimerDisplay({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 250,
            height: 250,
            child: CircularProgressIndicator(
              value: state.progress,
              strokeWidth: 8,
              backgroundColor: Colors.grey.withOpacity(0.3),
            ),
          ),
          Text(
            state.displayTime,
            style: const TextStyle(
              fontSize: 48,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: 创建秒表显示组件**

```dart
import 'package:flutter/material.dart';

class StopwatchDisplay extends StatelessWidget {
  final String displayTime;

  const StopwatchDisplay({super.key, required this.displayTime});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        displayTime,
        style: const TextStyle(
          fontSize: 48,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: 创建计次列表组件**

```dart
import 'package:flutter/material.dart';
import '../models/stopwatch_lap.dart';

class LapList extends StatelessWidget {
  final List<StopwatchLap> laps;

  const LapList({super.key, required this.laps});

  @override
  Widget build(BuildContext context) {
    if (laps.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: laps.length,
      itemBuilder: (context, index) {
        final lap = laps[laps.length - 1 - index]; // 倒序显示
        return ListTile(
          title: Text(
            '#${lap.lapNumber}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lap.lapTimeDisplay,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              const SizedBox(width: 24),
              Text(
                lap.totalTimeDisplay,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 6: 创建时间选择弹窗**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimePickerDialog extends StatefulWidget {
  final int initialHour;
  final int initialMinute;

  const TimePickerDialog({
    super.key,
    this.initialHour = 7,
    this.initialMinute = 0,
  });

  @override
  State<TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<TimePickerDialog> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置闹钟'),
      content: SizedBox(
        height: 200,
        child: CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          initialTimerDuration: Duration(hours: _hour, minutes: _minute),
          onTimerDurationChanged: (duration) {
            _hour = duration.inHours;
            _minute = duration.inMinutes % 60;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop((_hour, _minute)),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 7: 提交**

```bash
git add lib/tools/alarm/widgets/
git commit -m "feat(alarm): add UI components"
```

---

### Task 6: 页面实现

**Files:**
- Create: `lib/tools/alarm/pages/alarm_list_page.dart`
- Create: `lib/tools/alarm/pages/timer_page.dart`
- Create: `lib/tools/alarm/pages/stopwatch_page.dart`

- [ ] **Step 1: 创建闹钟列表页**

```dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_item.dart';
import '../widgets/alarm_card.dart';
import '../widgets/time_picker_dialog.dart';

class AlarmListPage extends StatefulWidget {
  final List<AlarmItem> alarms;
  final Function(AlarmItem) onAddAlarm;
  final Function(AlarmItem) onUpdateAlarm;
  final Function(String) onDeleteAlarm;
  final Function(AlarmItem) onToggleAlarm;

  const AlarmListPage({
    super.key,
    required this.alarms,
    required this.onAddAlarm,
    required this.onUpdateAlarm,
    required this.onDeleteAlarm,
    required this.onToggleAlarm,
  });

  @override
  State<AlarmListPage> createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  Future<void> _showAddDialog() async {
    final result = await showDialog<(int, int)>(
      context: context,
      builder: (context) => const TimePickerDialog(),
    );

    if (result != null && mounted) {
      final alarm = AlarmItem(
        id: const Uuid().v4(),
        hour: result.$1,
        minute: result.$2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onAddAlarm(alarm);
    }
  }

  Future<void> _showEditDialog(AlarmItem alarm) async {
    final result = await showDialog<(int, int)>(
      context: context,
      builder: (context) => TimePickerDialog(
        initialHour: alarm.hour,
        initialMinute: alarm.minute,
      ),
    );

    if (result != null && mounted) {
      final updated = alarm.copyWith(
        hour: result.$1,
        minute: result.$2,
        updatedAt: DateTime.now(),
      );
      widget.onUpdateAlarm(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alarms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('暂无闹钟', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text(
              '点击 + 添加一个闹钟',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: widget.alarms.length,
          itemBuilder: (context, index) {
            final alarm = widget.alarms[index];
            return AlarmCard(
              alarm: alarm,
              onTap: () => _showEditDialog(alarm),
              onToggle: () => widget.onToggleAlarm(alarm),
              onDelete: () => widget.onDeleteAlarm(alarm.id),
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: _showAddDialog,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 创建倒计时页**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../widgets/timer_display.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  static const _presets = [
    Duration(minutes: 1),
    Duration(minutes: 3),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerService>(
      builder: (context, service, child) {
        final state = service.state;

        return Column(
          children: [
            const SizedBox(height: 32),
            TimerDisplay(state: state),
            const SizedBox(height: 32),
            if (state.status == TimerStatus.idle) ...[
              Wrap(
                spacing: 8,
                children: _presets.map((d) {
                  return ActionChip(
                    label: Text('${d.inMinutes}分钟'),
                    onPressed: () => service.start(d),
                  );
                }).toList(),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.status == TimerStatus.running)
                    ElevatedButton(
                      onPressed: service.pause,
                      child: const Text('暂停'),
                    ),
                  if (state.status == TimerStatus.paused)
                    ElevatedButton(
                      onPressed: service.resume,
                      child: const Text('继续'),
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: service.reset,
                    child: const Text('重置'),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
```

- [ ] **Step 3: 创建秒表页**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/stopwatch_service.dart';
import '../widgets/stopwatch_display.dart';
import '../widgets/lap_list.dart';

class StopwatchPage extends StatelessWidget {
  const StopwatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StopwatchService>(
      builder: (context, service, child) {
        return Column(
          children: [
            const SizedBox(height: 32),
            StopwatchDisplay(displayTime: service.displayTime),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!service.isRunning && service.elapsed == Duration.zero)
                  ElevatedButton(
                    onPressed: service.start,
                    child: const Text('开始'),
                  ),
                if (service.isRunning) ...[
                  ElevatedButton(
                    onPressed: service.addLap,
                    child: const Text('计次'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: service.pause,
                    child: const Text('暂停'),
                  ),
                ],
                if (!service.isRunning && service.elapsed != Duration.zero) ...[
                  ElevatedButton(
                    onPressed: service.start,
                    child: const Text('继续'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: service.reset,
                    child: const Text('重置'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: LapList(laps: service.laps)),
          ],
        );
      },
    );
  }
}
```

- [ ] **Step 4: 提交**

```bash
git add lib/tools/alarm/pages/
git commit -m "feat(alarm): add pages (alarm list, timer, stopwatch)"
```

---

### Task 7: 主页面和 ToolModule

**Files:**
- Create: `lib/tools/alarm/alarm_page.dart`
- Create: `lib/tools/alarm/alarm_tool.dart`

- [ ] **Step 1: 创建主页面**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/alarm_item.dart';
import 'services/alarm_service.dart';
import 'services/timer_service.dart';
import 'services/stopwatch_service.dart';
import 'pages/alarm_list_page.dart';
import 'pages/timer_page.dart';
import 'pages/stopwatch_page.dart';
import 'widgets/page_indicator.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<AlarmItem> _alarms = [];
  final AlarmService _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    // TODO: 从数据库加载闹钟
    setState(() {});
  }

  Future<void> _addAlarm(AlarmItem alarm) async {
    // TODO: 保存到数据库
    setState(() {
      _alarms.add(alarm);
    });
    await _alarmService.scheduleAlarm(alarm);
  }

  Future<void> _updateAlarm(AlarmItem alarm) async {
    // TODO: 更新数据库
    setState(() {
      final index = _alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        _alarms[index] = alarm;
      }
    });
    await _alarmService.cancelAlarm(alarm.id);
    if (alarm.isEnabled) {
      await _alarmService.scheduleAlarm(alarm);
    }
  }

  Future<void> _deleteAlarm(String id) async {
    // TODO: 从数据库删除
    setState(() {
      _alarms.removeWhere((a) => a.id == id);
    });
    await _alarmService.cancelAlarm(id);
  }

  Future<void> _toggleAlarm(AlarmItem alarm) async {
    final updated = alarm.copyWith(
      isEnabled: !alarm.isEnabled,
      updatedAt: DateTime.now(),
    );
    await _updateAlarm(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('时钟'),
      ),
      body: Column(
        children: [
          PageIndicator(
            currentPage: _currentPage,
            onTabSelected: (index) {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                AlarmListPage(
                  alarms: _alarms,
                  onAddAlarm: _addAlarm,
                  onUpdateAlarm: _updateAlarm,
                  onDeleteAlarm: _deleteAlarm,
                  onToggleAlarm: _toggleAlarm,
                ),
                const TimerPage(),
                const StopwatchPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 更新页面指示器支持点击**

修改 `page_indicator.dart` 添加 `onTabSelected` 回调。

- [ ] **Step 3: 创建 ToolModule 实现**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'alarm_page.dart';

class AlarmTool implements ToolModule {
  @override
  String get id => 'alarm';

  @override
  String get name => '时钟';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.access_time;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const AlarmPage();
  }

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

- [ ] **Step 4: 提交**

```bash
git add lib/tools/alarm/alarm_page.dart lib/tools/alarm/alarm_tool.dart
git commit -m "feat(alarm): add main page and ToolModule"
```

---

### Task 8: 注册工具

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: 在 main.dart 中注册 AlarmTool**

添加导入和注册代码，同时初始化通知服务。

- [ ] **Step 2: 提交**

```bash
git add lib/main.dart
git commit -m "feat(alarm): register AlarmTool in main.dart"
```

---

### Task 9: 验证运行

- [ ] **Step 1: 运行应用验证功能**

Run: `cd /home/nano/littlegrid/app && flutter run`

验证项：
1. 主页格子中显示"时钟"图标
2. 点击进入时钟页面
3. PageView 滑动切换三个功能
4. 页面指示器点击切换
5. 闹钟列表空状态显示
6. 添加闹钟功能
7. 倒计时预设按钮工作
8. 秒表计时和计次功能

- [ ] **Step 2: 最终提交**

```bash
git add -A
git commit -m "feat(alarm): complete alarm clock feature"
```