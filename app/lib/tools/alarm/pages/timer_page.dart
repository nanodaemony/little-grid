import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/timer_service.dart';
import '../widgets/timer_display.dart';
import '../models/timer_state.dart';

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