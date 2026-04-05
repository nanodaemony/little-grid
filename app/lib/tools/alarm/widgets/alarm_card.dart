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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alarm.repeatText),
              if (alarm.isEnabled && alarm.timeUntilTrigger != null)
                Text(
                  alarm.timeUntilTrigger!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
          trailing: Switch(
            value: alarm.isEnabled,
            onChanged: (_) => onToggle(),
          ),
        ),
      ),
    );
  }
}