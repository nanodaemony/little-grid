import '../models/alarm_item.dart';
import 'notification_service.dart';

class AlarmService {
  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await _notificationService.initialize();
  }

  Future<void> requestPermissions() async {
    await _notificationService.requestPermissions();
  }

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