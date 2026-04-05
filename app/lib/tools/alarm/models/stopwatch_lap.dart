class StopwatchLap {
  final int lapNumber;
  final Duration lapTime;
  final Duration totalTime;

  StopwatchLap({
    required this.lapNumber,
    required this.lapTime,
    required this.totalTime,
  });

  String get lapTimeDisplay => _formatDuration(lapTime);
  String get totalTimeDisplay => _formatDuration(totalTime);

  static String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    final centiseconds = (d.inMilliseconds % 1000) ~/ 10;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centiseconds.toString().padLeft(2, '0')}';
  }
}