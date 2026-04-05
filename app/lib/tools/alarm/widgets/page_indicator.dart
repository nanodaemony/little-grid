import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final List<String> labels;
  final void Function(int)? onTabSelected;

  const PageIndicator({
    super.key,
    required this.currentPage,
    this.pageCount = 3,
    this.labels = const ['闹钟', '倒计时', '秒表'],
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final isSelected = index == currentPage;
          return GestureDetector(
            onTap: onTabSelected != null ? () => onTabSelected!(index) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}