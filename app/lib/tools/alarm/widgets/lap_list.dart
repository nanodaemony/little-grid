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