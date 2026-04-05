import 'package:flutter/material.dart';
import '../models/drink_plan_models.dart';

class DayCell extends StatelessWidget {
  final DateTime date;
  final DailyRecord? record;
  final VoidCallback onTap;
  final bool isToday;
  final double opacity;

  const DayCell({
    super.key,
    required this.date,
    this.record,
    required this.onTap,
    this.isToday = false,
    this.opacity = 0.3,
  });

  Color _getBackgroundColor(double opacity) {
    if (record == null || record!.drinks.isEmpty) {
      return Colors.transparent;
    }

    final sugar = record!.totalSugar;

    if (sugar == 0) {
      return Colors.green.withOpacity(opacity);
    } else if (sugar <= 25) {
      return Colors.yellow.withOpacity(opacity);
    } else if (sugar <= 50) {
      return Colors.orange.withOpacity(opacity);
    } else {
      return Colors.red.withOpacity(opacity);
    }
  }

  String _getEmoji() {
    if (record == null || record!.drinks.isEmpty) {
      return '';
    }

    final sugar = record!.totalSugar;

    if (sugar == 0) {
      return '✅';
    } else if (sugar <= 25) {
      return '😐';
    } else if (sugar <= 50) {
      return '😰';
    } else {
      return '🤢';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(opacity),
          border: isToday
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Theme.of(context).primaryColor : null,
                ),
              ),
            ),
            if (_getEmoji().isNotEmpty)
              Positioned(
                top: 2,
                right: 2,
                child: Text(
                  _getEmoji(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
