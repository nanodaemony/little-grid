import 'package:flutter/material.dart' hide TimePickerDialog;
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
    return Scaffold(
      body: widget.alarms.isEmpty
          ? Center(
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
            )
          : ListView.builder(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}