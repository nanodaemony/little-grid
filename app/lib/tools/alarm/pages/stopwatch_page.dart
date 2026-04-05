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