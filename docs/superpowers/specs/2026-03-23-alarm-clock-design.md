# 时钟工具设计文档

**日期**: 2026-03-23
**状态**: 待审核
**分类**: life

---

## 1. 功能概述

在 LittleGrid 应用中新增一个时钟工具，包含闹钟、倒计时、秒表三个子功能，通过 PageView 左右滑动切换。

### 1.1 功能范围

**闹钟功能**:
- 设置指定时间响铃
- 支持三种重复模式：单次、每日、自定义周几
- 系统通知响铃（支持后台）
- 多闹钟管理（增删改查、开关）

**倒计时功能**:
- 预设时长：1分钟、3分钟、5分钟、10分钟、30分钟
- 支持自定义输入时长
- 开始/暂停/重置操作
- 时间到响铃通知

**秒表功能**:
- 精确到百分秒的计时
- 开始/暂停/重置操作
- 计次记录功能

---

## 2. 架构设计

### 2.1 模块结构

```
lib/tools/alarm/
├── alarm_tool.dart              # ToolModule 实现
├── alarm_page.dart              # 主页面（PageView 容器）
├── models/
│   ├── alarm_item.dart          # 闹钟数据模型
│   ├── timer_state.dart         # 倒计时状态
│   └── stopwatch_lap.dart       # 秒表计次模型
├── pages/
│   ├── alarm_list_page.dart     # 闹钟列表页
│   ├── timer_page.dart          # 倒计时页
│   └── stopwatch_page.dart      # 秒表页
├── widgets/
│   ├── alarm_card.dart          # 闹钟卡片组件
│   ├── timer_display.dart       # 倒计时显示组件
│   ├── stopwatch_display.dart   # 秒表显示组件
│   ├── lap_list.dart            # 计次列表组件
│   ├── time_picker_dialog.dart  # 时间选择弹窗
│   └── page_indicator.dart      # 页面指示器
└── services/
    ├── alarm_service.dart       # 闹钟后台调度服务
    ├── timer_service.dart       # 倒计时服务
    ├── stopwatch_service.dart   # 秒表服务
    └── notification_service.dart # 通知服务封装
```

### 2.2 ToolModule 实现

```dart
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

### 2.3 工具注册

在 `main.dart` 中注册工具：

```dart
void main() async {
  // ... 初始化代码
  ToolRegistry.register(AlarmTool());
  // ... 其他工具注册
}
```

### 2.4 服务生命周期

使用 Provider 管理服务实例：

```dart
// 在 main.dart 或顶层 widget 中
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => TimerService()),
    ChangeNotifierProvider(create: (_) => StopwatchService()),
    Provider(create: (_) => AlarmService()),
  ],
  child: MyApp(),
)
```

服务实例在应用生命周期内保持单例，通过 Provider 注入到各页面。

---

## 3. 数据模型

### 3.1 AlarmItem（闹钟）

```dart
class AlarmItem {
  final String id;
  final TimeOfDay time;          // 响铃时间
  final String label;            // 闹钟标签（如"起床"）
  final RepeatType repeatType;   // 单次/每日/自定义
  final List<int> repeatDays;    // 周几重复 (0=周日, 1-6=周一至周六)
  final bool isEnabled;          // 开关状态
  final String sound;            // 铃声标识

  DateTime? get nextTriggerTime; // 计算下次响铃时间
}

enum RepeatType { once, daily, custom }
```

### 3.2 TimerState（倒计时）

```dart
class TimerState {
  Duration totalDuration;        // 总时长
  Duration remainingTime;        // 剩余时间
  TimerStatus status;            // idle / running / paused / finished
}

enum TimerStatus { idle, running, paused, finished }
```

### 3.3 StopwatchLap（秒表计次）

```dart
class StopwatchLap {
  final int lapNumber;           // 计次编号
  final Duration lapTime;        // 本次计次时间
  final Duration totalTime;      // 累计时间
}
```

---

## 4. 界面设计

### 4.1 页面布局

```
┌─────────────────────────────────────┐
│  ←  时钟                             │  AppBar
├─────────────────────────────────────┤
│     闹钟    ·    倒计时    ·    秒表   │  页面指示器
├─────────────────────────────────────┤
│                                     │
│         PageView 可滑动区域          │
│                                     │
│  ┌─────────────────────────────┐    │
│  │     当前选中功能的内容        │    │
│  │                             │    │
│  └─────────────────────────────┘    │
│                                     │
└─────────────────────────────────────┘
```

### 4.2 闹钟页布局

```
┌─────────────────────────────────────┐
│  ┌───────────────────────────────┐  │
│  │  07:30          🔔  起床      │  │
│  │  每天         [开关]          │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │  09:00          🔔  上班      │  │
│  │  工作日       [开关]          │  │
│  └───────────────────────────────┘  │
│                                     │
│              [+]                    │  浮动添加按钮
└─────────────────────────────────────┘
```

**交互**:
- 点击卡片：编辑闹钟
- 滑动卡片：删除闹钟
- 点击开关：启用/禁用闹钟
- 点击 + 按钮：添加新闹钟

### 4.3 倒计时页布局

```
┌─────────────────────────────────────┐
│                                     │
│            05:00                    │  大字体显示 (MM:SS)
│                                     │
├─────────────────────────────────────┤
│   [1分] [3分] [5分] [10分] [30分]   │  预设按钮
│         [自定义]                    │
├─────────────────────────────────────┤
│                                     │
│      [开始]    [重置]               │  操作按钮
│                                     │
└─────────────────────────────────────┘
```

**状态变化**:
- idle: 显示预设 + [开始] [重置]
- running: 显示倒计时 + [暂停] [取消]
- paused: 显示倒计时 + [继续] [重置]
- finished: 显示 00:00 + [重置] + 响铃

### 4.4 秒表页布局

```
┌─────────────────────────────────────┐
│            00:05:32.48              │  主计时显示 (HH:MM:SS.ms)
├─────────────────────────────────────┤
│   #1    00:01:20.35    00:01:20    │  计次列表
│   #2    00:00:58.23    00:02:18    │  (本次时间 + 累计时间)
│   #3    00:01:05.90    00:03:24    │
├─────────────────────────────────────┤
│                                     │
│      [计次]    [暂停]               │  操作按钮
│                                     │
└─────────────────────────────────────┘
```

**状态变化**:
- 初始: [开始]
- 运行中: [计次] [暂停]
- 暂停后: [继续] [重置]

### 4.5 视觉规范

**颜色**:
- 时间显示：`Colors.white`，48px，monospace 字体
- 卡片背景：`AppColors.surface`
- 开关：`AppColors.primary`
- 页面指示器：当前页 `AppColors.primary`，其他页 `Colors.grey`

**字体**:
- 大时间显示：`TextStyle(fontSize: 64, fontFamily: 'monospace', fontWeight: FontWeight.w300)`
- 计次时间：`TextStyle(fontSize: 16, fontFamily: 'monospace')`

### 4.6 自定义时长输入

```
┌─────────────────────────────────────┐
│         设置倒计时                   │
├─────────────────────────────────────┤
│                                     │
│     [ 时 ]  :  [ 分 ]  :  [ 秒 ]    │  数字滚轮选择器
│                                     │
├─────────────────────────────────────┤
│         [取消]    [确定]            │
└─────────────────────────────────────┘
```

使用 `CupertinoTimerPicker` 或自定义数字滚轮组件。

### 4.7 闹钟空状态

```
┌─────────────────────────────────────┐
│                                     │
│              ⏰                     │
│         暂无闹钟                     │
│      点击 + 添加一个闹钟             │
│                                     │
└─────────────────────────────────────┘
```

---

## 5. 服务层设计

### 5.1 AlarmService

```dart
class AlarmService {
  final NotificationService _notificationService;

  /// 调度闹钟
  Future<void> scheduleAlarm(AlarmItem alarm) async {
    final triggerTime = alarm.nextTriggerTime;
    if (triggerTime == null) return;

    await _notificationService.zonedSchedule(
      id: alarm.id.hashCode,
      title: '闹钟',
      body: alarm.label,
      scheduledDate: triggerTime,
      sound: alarm.sound,
    );
  }

  /// 取消闹钟
  Future<void> cancelAlarm(String alarmId) async {
    await _notificationService.cancel(alarmId.hashCode);
  }

  /// 重新调度所有启用的闹钟（应用启动时调用）
  Future<void> rescheduleAllAlarms(List<AlarmItem> alarms) async {
    for (final alarm in alarms.where((a) => a.isEnabled)) {
      await scheduleAlarm(alarm);
    }
  }
}
```

### 5.2 TimerService

```dart
class TimerService extends ChangeNotifier {
  Timer? _timer;
  Duration _totalDuration = Duration.zero;
  Duration _remainingTime = Duration.zero;
  TimerStatus _status = TimerStatus.idle;

  Duration get remainingTime => _remainingTime;
  TimerStatus get status => _status;

  void start(Duration duration);
  void pause();
  void resume();
  void reset();
}
```

### 5.3 StopwatchService

```dart
class StopwatchService extends ChangeNotifier {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  final List<StopwatchLap> _laps = [];

  bool get isRunning => _stopwatch.isRunning;
  Duration get elapsedTime => _stopwatch.elapsed;
  List<StopwatchLap> get laps;

  void start();
  void pause();
  void reset();
  void addLap();
}
```

---

## 6. 数据存储

### 6.1 闹钟表（alarms）

```sql
CREATE TABLE alarms (
  id TEXT PRIMARY KEY,
  hour INTEGER NOT NULL,
  minute INTEGER NOT NULL,
  label TEXT,
  repeat_type TEXT NOT NULL,     -- 'once' / 'daily' / 'custom'
  repeat_days TEXT,              -- JSON 数组，如 "[1,2,3,4,5]"
  is_enabled INTEGER DEFAULT 1,
  sound TEXT DEFAULT 'default',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

### 6.2 数据库迁移

在 `DatabaseService` 中更新数据库版本和迁移逻辑：

```dart
// 数据库版本从 2 升级到 3
static const int _version = 3;

// 新安装时的表创建
@override
Future<void> _onCreate(Database db, int version) async {
  // ... 其他表的创建语句 ...

  // 闹钟表
  await db.execute('''
    CREATE TABLE alarms (
      id TEXT PRIMARY KEY,
      hour INTEGER NOT NULL,
      minute INTEGER NOT NULL,
      label TEXT,
      repeat_type TEXT NOT NULL,
      repeat_days TEXT,
      is_enabled INTEGER DEFAULT 1,
      sound TEXT DEFAULT 'default',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''');
}

// 已有数据库升级
@override
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 3) {
    // 添加闹钟表
    await db.execute('''
      CREATE TABLE alarms (
        id TEXT PRIMARY KEY,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        label TEXT,
        repeat_type TEXT NOT NULL,
        repeat_days TEXT,
        is_enabled INTEGER DEFAULT 1,
        sound TEXT DEFAULT 'default',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }
}
```

### 6.3 Timer 和 Stopwatch 持久化策略

| 功能 | 持久化 | 说明 |
|------|--------|------|
| **倒计时** | 不持久化 | 应用关闭或切换后清除，用户重新设置 |
| **秒表** | 不持久化 | 应用关闭后清除，计次记录不保存 |
| **闹钟** | 持久化 | SQLite 存储，应用重启后恢复调度 |

---

## 7. 权限配置

### 7.1 Android

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### 7.2 iOS

```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

### 7.3 通知服务初始化

```dart
class NotificationService {
  FlutterLocalNotificationsPlugin? _plugin;

  Future<void> initialize() async {
    // 初始化时区数据库
    tz.initializeTimeZones();
    // 使用设备本地时区（需要 flutter_native_timezone 包）
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    _plugin = FlutterLocalNotificationsPlugin();

    await _plugin!.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
    );

    // 创建通知渠道
    await _createNotificationChannels();
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
    await _plugin!.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _plugin!.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }
}
```

### 7.4 后台执行限制

**Android 12+ 精确闹钟权限**:
- 需要在设置中引导用户开启"允许设置闹钟和提醒"权限
- 如果用户拒绝，降级为非精确闹钟

```dart
Future<bool> requestExactAlarmPermission() async {
  if (Platform.isAndroid) {
    final status = await Permission.scheduleExactAlarm.status;
    if (!status.isGranted) {
      // 引导用户到系统设置
      await openAppSettings();
      return false;
    }
  }
  return true;
}
```

**倒计时后台运行**:
- 使用 `flutter_local_notifications` 的定时通知功能
- 倒计时开始时预调度结束通知
- 应用切换到后台后，倒计时 UI 不更新，但通知正常触发

---

## 8. 依赖项

```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.0
  uuid: ^4.0.0
  permission_handler: ^11.0.0
  flutter_native_timezone: ^2.0.0
```

---

## 9. 铃声配置

### 9.1 默认铃声

将默认铃声文件放入 `assets/sounds/` 目录：

```
assets/
└── sounds/
    ├── alarm_default.mp3
    └── timer_end.mp3
```

### 9.2 pubspec.yaml 配置

```yaml
flutter:
  assets:
    - assets/sounds/
```

### 9.3 铃声选择（MVP 版本）

MVP 版本仅提供默认铃声，后续版本可扩展多铃声选择功能。

---

## 10. 错误处理

### 10.1 错误类型

| 错误类型 | 处理方式 |
|---------|---------|
| 通知权限被拒绝 | 显示引导提示，跳转系统设置 |
| 闹钟调度失败 | 记录日志，显示 Toast 提示 |
| 数据库写入失败 | 记录日志，显示"保存失败" |
| 精确闹钟权限被拒 | 降级为非精确闹钟，提示用户 |

### 10.2 错误处理示例

```dart
Future<bool> scheduleAlarmSafely(AlarmItem alarm) async {
  try {
    await alarmService.scheduleAlarm(alarm);
    return true;
  } on PlatformException catch (e) {
    logger.e('Failed to schedule alarm', e);
    showToast('闹钟设置失败，请检查通知权限');
    return false;
  }
}
```

---

## 11. 验收标准

- [ ] PageView 滑动切换三个功能流畅
- [ ] 闹钟可添加/编辑/删除，数据持久化
- [ ] 闹钟支持单次/每日/自定义周几重复
- [ ] 闹钟在后台能正常触发系统通知
- [ ] 倒计时预设和自定义输入正常工作
- [ ] 倒计时结束触发通知
- [ ] 秒表计时精确到百分秒
- [ ] 秒表计次功能正常
- [ ] 应用重启后闹钟正常恢复调度
- [ ] 视觉风格与现有应用一致
- [ ] 权限请求流程正常
- [ ] 空状态显示正常