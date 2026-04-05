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