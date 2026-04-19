# APP内横幅通知与系统通知集成 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add in-app banner notifications and integrate system notifications for Pomodoro, Anniversary, and Drink Plan tools.

**Architecture:**
- Create `InAppBanner` widget for banner display with swipe/click dismissal
- Create `BannerQueue` for managing multiple notifications
- Create `InAppBannerService` for global banner management
- Enhance existing `NotificationService` with new channels and convenience methods
- Integrate into 3 tools: Pomodoro, Anniversary, Drink Plan

**Tech Stack:** Flutter, flutter_local_notifications (already in pubspec.yaml)

---

## File Structure

**New files to create:**
- `lib/core/widgets/in_app_banner.dart` - Banner UI component
- `lib/core/services/banner_queue.dart` - Notification queue management
- `lib/core/services/in_app_banner_service.dart` - Banner service

**Files to modify:**
- `lib/core/services/notification_service.dart` - Enhance with new channels/methods
- `lib/main.dart` - Initialize services and add banner overlay
- `lib/tools/pomodoro/*` - Add notifications
- `lib/tools/anniversary/*` - Add notifications
- `lib/tools/drink_plan/*` - Add notifications

---

## Task 1: Enhance NotificationService with new channels and methods

**Files:**
- Modify: `lib/core/services/notification_service.dart`

- [ ] **Step 1: Read current notification_service.dart**

First, read the existing file to understand its structure.

- [ ] **Step 2: Add new notification channels in _createNotificationChannels()**

Add these channels after the existing ones:

```dart
await androidPlugin?.createNotificationChannel(
  const AndroidNotificationChannel(
    'pomodoro_channel',
    '番茄钟',
    description: '番茄钟提醒通知',
    importance: Importance.high,
    playSound: true,
  ),
);

await androidPlugin?.createNotificationChannel(
  const AndroidNotificationChannel(
    'anniversary_channel',
    '纪念日',
    description: '纪念日提醒通知',
    importance: Importance.defaultImportance,
    playSound: true,
  ),
);

await androidPlugin?.createNotificationChannel(
  const AndroidNotificationChannel(
    'drink_plan_channel',
    '喝水提醒',
    description: '定时喝水提醒通知',
    importance: Importance.defaultImportance,
    playSound: true,
  ),
);
```

- [ ] **Step 3: Add convenience method showPomodoroNotification()**

Add this method to NotificationService:

```dart
Future<void> showPomodoroNotification({
  required int id,
  required bool isWorkFinished,
  required DateTime scheduledDate,
}) async {
  if (_plugin == null || !_initialized) {
    throw StateError('NotificationService not initialized. Call initialize() first.');
  }

  final title = isWorkFinished ? '番茄钟结束' : '休息结束';
  final body = isWorkFinished ? '休息一下吧，喝杯水~' : '开始新的专注吧！';

  await _plugin!.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'pomodoro_channel',
        '番茄钟',
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
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

- [ ] **Step 4: Add convenience method showAnniversaryNotification()**

Add this method:

```dart
Future<void> showAnniversaryNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  if (_plugin == null || !_initialized) {
    throw StateError('NotificationService not initialized. Call initialize() first.');
  }

  await _plugin!.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    NotificationDetails(
      android: const AndroidNotificationDetails(
        'anniversary_channel',
        '纪念日',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

- [ ] **Step 5: Add convenience method showDrinkPlanNotification()**

Add this method:

```dart
Future<void> showDrinkPlanNotification({
  required int id,
  required DateTime scheduledDate,
}) async {
  if (_plugin == null || !_initialized) {
    throw StateError('NotificationService not initialized. Call initialize() first.');
  }

  await _plugin!.zonedSchedule(
    id,
    '喝水时间到',
    '记得补充水分哦~',
    tz.TZDateTime.from(scheduledDate, tz.local),
    NotificationDetails(
      android: const AndroidNotificationDetails(
        'drink_plan_channel',
        '喝水提醒',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

- [ ] **Step 6: Add showImmediately() method for immediate in-app banner trigger**

Add this method to show a notification immediately (useful for testing and in-app banners when app is foreground):

```dart
Future<void> showImmediately({
  required int id,
  required String title,
  required String body,
  String channel = 'alarm_channel',
}) async {
  if (_plugin == null || !_initialized) {
    throw StateError('NotificationService not initialized. Call initialize() first.');
  }

  await _plugin!.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel,
        channel == 'alarm_channel' ? '闹钟' :
        channel == 'timer_channel' ? '倒计时' :
        channel == 'pomodoro_channel' ? '番茄钟' :
        channel == 'anniversary_channel' ? '纪念日' : '喝水提醒',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    ),
  );
}
```

- [ ] **Step 7: Commit changes**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/core/services/notification_service.dart
git commit -m "feat: enhance NotificationService with new channels and convenience methods"
```

---

## Task 2: Create BannerQueue for notification queue management

**Files:**
- Create: `lib/core/services/banner_queue.dart`

- [ ] **Step 1: Create banner_queue.dart with BannerData model and BannerQueue**

Write the complete file:

```dart
import 'dart:async';
import 'package:flutter/material.dart';

/// Banner data model
class BannerData {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final String? toolId;

  BannerData({
    required this.title,
    required this.body,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFF22C55E),
    this.onTap,
    this.toolId,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();
}

/// Banner queue management service
class BannerQueue extends ChangeNotifier {
  final List<BannerData> _queue = [];
  BannerData? _currentBanner;
  bool _isShowing = false;

  /// Get current showing banner
  BannerData? get currentBanner => _currentBanner;

  /// Get queue length
  int get queueLength => _queue.length;

  /// Check if a banner is currently showing
  bool get isShowing => _isShowing;

  /// Enqueue a new banner
  void enqueue(BannerData data) {
    if (_queue.length >= 10) {
      _queue.removeAt(0);
    }
    _queue.add(data);
    _tryShowNext();
  }

  /// Dismiss current banner
  void dismissCurrent() {
    _currentBanner = null;
    _isShowing = false;
    notifyListeners();

    // Wait a bit before showing next
    Future.delayed(const Duration(milliseconds: 300), () {
      _tryShowNext();
    });
  }

  /// Clear all banners
  void clearAll() {
    _queue.clear();
    dismissCurrent();
  }

  /// Try to show next banner in queue
  void _tryShowNext() {
    if (_isShowing || _queue.isEmpty) return;

    _currentBanner = _queue.removeAt(0);
    _isShowing = true;
    notifyListeners();
  }
}
```

- [ ] **Step 2: Commit the new file**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/core/services/banner_queue.dart
git commit -m "feat: add BannerQueue for notification queue management"
```

---

## Task 3: Create InAppBanner widget

**Files:**
- Create: `lib/core/widgets/in_app_banner.dart`

- [ ] **Step 1: Create in_app_banner.dart**

Write the complete file:

```dart
import 'package:flutter/material.dart';
import '../services/banner_queue.dart';
import '../ui/app_colors.dart';

/// In-app banner widget
class InAppBanner extends StatefulWidget {
  final BannerData data;
  final VoidCallback onDismiss;

  const InAppBanner({
    super.key,
    required this.data,
    required this.onDismiss,
  });

  @override
  State<InAppBanner> createState() => _InAppBannerState();
}

class _InAppBannerState extends State<InAppBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _animationController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onDismiss();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 50) {
      _dismiss();
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Positioned(
          top: topPadding + 8,
          left: 8,
          right: 8,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: GestureDetector(
                onHorizontalDragUpdate: _handleDragUpdate,
                onHorizontalDragEnd: _handleDragEnd,
                onTap: widget.data.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.data.iconBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.data.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.data.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.data.body,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Close button
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Banner overlay widget that manages banner display
class InAppBannerOverlay extends StatelessWidget {
  const InAppBannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BannerQueue>(
      builder: (context, queue, child) {
        if (queue.currentBanner == null) {
          return const SizedBox.shrink();
        }
        return InAppBanner(
          data: queue.currentBanner!,
          onDismiss: () => queue.dismissCurrent(),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Commit the new file**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/core/widgets/in_app_banner.dart
git commit -m "feat: add InAppBanner widget"
```

---

## Task 4: Create InAppBannerService

**Files:**
- Create: `lib/core/services/in_app_banner_service.dart`

- [ ] **Step 1: Create in_app_banner_service.dart**

Write the complete file:

```dart
import 'package:flutter/material.dart';
import 'banner_queue.dart';

/// In-app banner service for global banner management
class InAppBannerService {
  static final InAppBannerService _instance = InAppBannerService._internal();
  factory InAppBannerService() => _instance;
  InAppBannerService._internal();

  BannerQueue? _queue;
  bool _initialized = false;

  /// Initialize the service
  void initialize(BannerQueue queue) {
    if (_initialized) return;
    _queue = queue;
    _initialized = true;
  }

  /// Show a banner
  void show({
    required String title,
    required String body,
    required IconData icon,
    Color? iconBackgroundColor,
    VoidCallback? onTap,
    String? toolId,
  }) {
    if (_queue == null || !_initialized) {
      throw StateError('InAppBannerService not initialized. Call initialize() first.');
    }

    final data = BannerData(
      title: title,
      body: body,
      icon: icon,
      iconBackgroundColor: iconBackgroundColor ?? const Color(0xFF22C55E),
      onTap: onTap,
      toolId: toolId,
    );

    _queue!.enqueue(data);
  }

  /// Dismiss current banner
  void dismiss() {
    if (_queue == null || !_initialized) return;
    _queue!.dismissCurrent();
  }

  /// Clear all banners
  void clearAll() {
    if (_queue == null || !_initialized) return;
    _queue!.clearAll();
  }
}
```

- [ ] **Step 2: Commit the new file**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/core/services/in_app_banner_service.dart
git commit -m "feat: add InAppBannerService"
```

---

## Task 5: Initialize services in main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Read current main.dart**

Read the file to understand its current structure.

- [ ] **Step 2: Add imports at the top**

Add these imports after existing ones:

```dart
import 'core/services/banner_queue.dart';
import 'core/services/in_app_banner_service.dart';
import 'core/widgets/in_app_banner.dart';
```

- [ ] **Step 3: Add BannerQueue to providers**

In the `MultiProvider` providers list, add:

```dart
ChangeNotifierProvider(create: (_) => BannerQueue()),
```

Add this line after the existing providers, before `DebugLogService`.

- [ ] **Step 4: Initialize InAppBannerService in initState**

In `_MainPageState.initState`, add:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  // ... existing code ...

  // Initialize banner service
  final bannerQueue = context.read<BannerQueue>();
  InAppBannerService().initialize(bannerQueue);
});
```

- [ ] **Step 5: Add InAppBannerOverlay using MaterialApp builder**

Wrap the MaterialApp child with the banner overlay. Modify the MaterialApp:

```dart
MaterialApp(
  // ... existing properties ...
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        const InAppBannerOverlay(),
      ],
    );
  },
  // ... existing home property ...
)
```

- [ ] **Step 6: Commit changes**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/main.dart
git commit -m "feat: initialize banner services and add overlay"
```

---

## Task 6: Integrate notifications into Pomodoro tool

**Files:**
- Read: `lib/tools/pomodoro/services/pomodoro_service.dart`
- Modify: `lib/tools/pomodoro/services/pomodoro_service.dart`
- Read: `lib/tools/pomodoro/pomodoro_page.dart`

- [ ] **Step 1: Read pomodoro_service.dart to understand current implementation**

- [ ] **Step 2: Add imports to pomodoro_service.dart**

```dart
import '../../../core/services/notification_service.dart';
import '../../../core/services/in_app_banner_service.dart';
```

- [ ] **Step 3: Add notification methods in PomodoroService**

Add these methods to the PomodoroService class:

```dart
/// Schedule notification for timer end
Future<void> _scheduleNotification() async {
  if (_endTime == null) return;

  final notificationService = NotificationService();

  // Cancel any existing notifications for this session
  await notificationService.cancel(1000);
  await notificationService.cancel(1001);

  // Schedule based on current mode
  final id = _isWorkMode ? 1000 : 1001;
  await notificationService.showPomodoroNotification(
    id: id,
    isWorkFinished: _isWorkMode,
    scheduledDate: _endTime!,
  );
}

/// Cancel scheduled notifications
Future<void> _cancelNotifications() async {
  final notificationService = NotificationService();
  await notificationService.cancel(1000);
  await notificationService.cancel(1001);
}

/// Show in-app banner when timer ends
void _showInAppBanner() {
  final bannerService = InAppBannerService();

  final title = _isWorkMode ? '番茄钟结束' : '休息结束';
  final body = _isWorkMode ? '休息一下吧，喝杯水~' : '开始新的专注吧！';
  final icon = _isWorkMode ? Icons.timer : Icons.play_circle;
  final color = _isWorkMode ? const Color(0xFF22C55E) : const Color(0xFF3B82F6);

  bannerService.show(
    title: title,
    body: body,
    icon: icon,
    iconBackgroundColor: color,
    toolId: 'pomodoro',
  );
}
```

- [ ] **Step 4: Call _scheduleNotification() when timer starts**

Find where the timer starts (in `start()` method) and add:

```dart
await _scheduleNotification();
```

- [ ] **Step 5: Call _cancelNotifications() when timer stops/pauses/resets**

In `pause()` method, add:
```dart
await _cancelNotifications();
```

In `reset()` method, add:
```dart
await _cancelNotifications();
```

- [ ] **Step 6: Call _showInAppBanner() when timer completes**

Find where the timer completes (where it calls `_onTimerComplete()`) and add:
```dart
_showInAppBanner();
```

- [ ] **Step 7: Commit changes**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/tools/pomodoro/services/pomodoro_service.dart
git commit -m "feat: add notifications to Pomodoro tool"
```

---

## Task 7: Integrate notifications into Anniversary tool

**Files:**
- Read: `lib/tools/anniversary/services/anniversary_service.dart`
- Read: `lib/tools/anniversary/anniversary_page.dart`
- Modify: Relevant files in anniversary tool

- [ ] **Step 1: Explore anniversary tool structure**

Read the anniversary service and page to understand how anniversaries are stored and managed.

- [ ] **Step 2: Add notification scheduling for anniversaries**

Add methods to schedule notifications when anniversaries are created/updated:

```dart
import '../../../core/services/notification_service.dart';

// Schedule notification for an anniversary
Future<void> _scheduleAnniversaryNotification(Anniversary anniversary) async {
  final notificationService = NotificationService();

  // Base ID: 2000 + anniversary.id
  final baseId = 2000 + (anniversary.id ?? 0);

  // Cancel existing notifications
  await notificationService.cancel(baseId);
  await notificationService.cancel(baseId + 1);

  // Calculate notification dates
  final now = DateTime.now();
  final anniversaryDate = anniversary.date;

  // This year's anniversary
  var thisYearAnniversary = DateTime(
    now.year,
    anniversaryDate.month,
    anniversaryDate.day,
    9,  // 9 AM
    0,
  );

  // If already passed this year, schedule for next year
  if (thisYearAnniversary.isBefore(now)) {
    thisYearAnniversary = DateTime(
      now.year + 1,
      anniversaryDate.month,
      anniversaryDate.day,
      9,
      0,
    );
  }

  // Day-before reminder (1 day before at 6 PM)
  final dayBefore = thisYearAnniversary.subtract(const Duration(days: 1));
  final dayBeforeReminder = DateTime(
    dayBefore.year,
    dayBefore.month,
    dayBefore.day,
    18,  // 6 PM
    0,
  );

  // Schedule day-before reminder if it's in the future
  if (dayBeforeReminder.isAfter(now)) {
    final daysUntil = thisYearAnniversary.difference(now).inDays;
    await notificationService.showAnniversaryNotification(
      id: baseId,
      title: anniversary.title,
      body: '还有${daysUntil + 1}天就是纪念日了！',
      scheduledDate: dayBeforeReminder,
    );
  }

  // Schedule day-of reminder
  await notificationService.showAnniversaryNotification(
    id: baseId + 1,
    title: anniversary.title,
    body: '今天是纪念日！',
    scheduledDate: thisYearAnniversary,
  );
}

/// Cancel notifications for an anniversary
Future<void> _cancelAnniversaryNotification(Anniversary anniversary) async {
  final notificationService = NotificationService();
  final baseId = 2000 + (anniversary.id ?? 0);
  await notificationService.cancel(baseId);
  await notificationService.cancel(baseId + 1);
}
```

- [ ] **Step 3: Call notification scheduling when creating/updating anniversaries**

Call `_scheduleAnniversaryNotification()` when an anniversary is saved.

- [ ] **Step 4: Call notification cancellation when deleting anniversaries**

Call `_cancelAnniversaryNotification()` when an anniversary is deleted.

- [ ] **Step 5: Add in-app banner trigger**

Add in-app banner support for when the app is open and an anniversary reminder is due.

- [ ] **Step 6: Commit changes**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/tools/anniversary/
git commit -m "feat: add notifications to Anniversary tool"
```

---

## Task 8: Integrate notifications into Drink Plan tool

**Files:**
- Read: `lib/tools/drink_plan/`
- Modify: Relevant files in drink_plan tool

- [ ] **Step 1: Explore drink plan tool structure**

Read the drink plan pages and services to understand how reminders are currently set up.

- [ ] **Step 2: Add notification scheduling for drink reminders**

```dart
import '../../../core/services/notification_service.dart';

// Schedule drink plan notifications
Future<void> _scheduleDrinkNotifications(List<TimeOfDay> times) async {
  final notificationService = NotificationService();

  // Cancel existing notifications (3000-3099 range)
  for (int i = 3000; i < 3100; i++) {
    await notificationService.cancel(i);
  }

  // Schedule new notifications
  final now = DateTime.now();
  for (int i = 0; i < times.length; i++) {
    final time = times[i];
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await notificationService.showDrinkPlanNotification(
      id: 3000 + i,
      scheduledDate: scheduledTime,
    );
  }
}

/// Cancel all drink plan notifications
Future<void> _cancelDrinkNotifications() async {
  final notificationService = NotificationService();
  for (int i = 3000; i < 3100; i++) {
    await notificationService.cancel(i);
  }
}
```

- [ ] **Step 3: Call notification scheduling when reminders are enabled/updated**

- [ ] **Step 4: Call notification cancellation when reminders are disabled**

- [ ] **Step 5: Add in-app banner support**

- [ ] **Step 6: Commit changes**

```bash
cd /Users/nano/claude/little-grid/app
git add lib/tools/drink_plan/
git commit -m "feat: add notifications to Drink Plan tool"
```

---

## Task 9: Test and verify everything works

**Files:**
- All modified files

- [ ] **Step 1: Run the app and test basic banner functionality**

Test that:
- Banner displays correctly
- Clicking close button dismisses it
- Swiping left/right dismisses it
- Multiple banners queue correctly

- [ ] **Step 2: Test Pomodoro notifications**

Test that:
- Timer completion shows banner
- System notification is scheduled

- [ ] **Step 3: Test Anniversary notifications**

Test that:
- Creating an anniversary schedules notifications

- [ ] **Step 4: Test Drink Plan notifications**

Test that:
- Enabling reminders schedules notifications

- [ ] **Step 5: Final commit (if any fixes needed)**

```bash
cd /Users/nano/claude/little-grid/app
git status
# Add and commit any fixes
```

---

## Summary

This plan creates:
- `BannerQueue` - Queue management for multiple notifications
- `InAppBanner` - Banner UI with slide/click dismissal
- `InAppBannerService` - Global banner service
- Enhanced `NotificationService` with new channels and methods
- Integrates notifications into Pomodoro, Anniversary, and Drink Plan tools
