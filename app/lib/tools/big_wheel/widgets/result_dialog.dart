import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/wheel_option.dart';
import '../utils/color_utils.dart';

/// Dialog that displays the result of a wheel spin
class ResultDialog extends StatelessWidget {
  final WheelOption option;
  final VoidCallback onClose;
  final VoidCallback onSpinAgain;

  const ResultDialog({
    super.key,
    required this.option,
    required this.onClose,
    required this.onSpinAgain,
  });

  @override
  Widget build(BuildContext context) {
    final color = parseColor(option.color);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              '🎉 结果',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            // Large circle with option
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon if available
                    if (option.icon != null && option.icon!.isNotEmpty)
                      Text(
                        option.icon!,
                        style: const TextStyle(fontSize: 40),
                      ),
                    const SizedBox(height: 8),
                    // Option name
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Buttons
            Row(
              children: [
                // Close button
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '关闭',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Spin again button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onSpinAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '再转一次',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Show the result dialog
Future<void> showResultDialog({
  required BuildContext context,
  required WheelOption option,
  required VoidCallback onClose,
  required VoidCallback onSpinAgain,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ResultDialog(
      option: option,
      onClose: onClose,
      onSpinAgain: onSpinAgain,
    ),
  );
}
