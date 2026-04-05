import 'package:flutter/material.dart';

class StopwatchDisplay extends StatelessWidget {
  final String displayTime;

  const StopwatchDisplay({super.key, required this.displayTime});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        displayTime,
        style: const TextStyle(
          fontSize: 48,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}