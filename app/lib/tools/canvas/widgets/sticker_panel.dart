import 'package:flutter/material.dart';

class StickerPanel extends StatelessWidget {
  final void Function(String) onStickerSelected;

  const StickerPanel({
    super.key,
    required this.onStickerSelected,
  });

  static const _stickers = [
    // 表情
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😊', '😍', '🥰',
    // 手势
    '👍', '👎', '👏', '🙏', '💪', '✌️', '🤞', '👆', '👇', '👈', '👉',
    // 符号
    '❤️', '💔', '💡', '⭐', '🌟', '✨', '💫', '🔥', '💯', '🎉', '🎊', '🎈', '🎁', '🏆',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 10,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: _stickers.map((emoji) {
          return GestureDetector(
            onTap: () => onStickerSelected(emoji),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }
}