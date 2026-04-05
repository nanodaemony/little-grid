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