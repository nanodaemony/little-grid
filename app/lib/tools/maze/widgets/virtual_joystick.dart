import 'package:flutter/material.dart';
import '../maze_models.dart';

/// 虚拟方向按键
class VirtualJoystick extends StatelessWidget {
  final Function(Direction) onDirectionStart;
  final VoidCallback onDirectionEnd;
  final Function(Direction)? onDirectionTap;

  const VirtualJoystick({
    super.key,
    required this.onDirectionStart,
    required this.onDirectionEnd,
    this.onDirectionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上
          _DirectionButton(
            direction: Direction.up,
            icon: Icons.keyboard_arrow_up,
            onDirectionStart: onDirectionStart,
            onDirectionEnd: onDirectionEnd,
            onDirectionTap: onDirectionTap,
          ),
          const SizedBox(height: 8),
          // 中排（左-空-右）
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DirectionButton(
                direction: Direction.left,
                icon: Icons.keyboard_arrow_left,
                onDirectionStart: onDirectionStart,
                onDirectionEnd: onDirectionEnd,
                onDirectionTap: onDirectionTap,
              ),
              const SizedBox(width: 8),
              // 中间空位
              const SizedBox(
                width: 64,
                height: 64,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _DirectionButton(
                direction: Direction.right,
                icon: Icons.keyboard_arrow_right,
                onDirectionStart: onDirectionStart,
                onDirectionEnd: onDirectionEnd,
                onDirectionTap: onDirectionTap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 下
          _DirectionButton(
            direction: Direction.down,
            icon: Icons.keyboard_arrow_down,
            onDirectionStart: onDirectionStart,
            onDirectionEnd: onDirectionEnd,
            onDirectionTap: onDirectionTap,
          ),
        ],
      ),
    );
  }
}

/// 单个方向按钮
class _DirectionButton extends StatefulWidget {
  final Direction direction;
  final IconData icon;
  final Function(Direction) onDirectionStart;
  final VoidCallback onDirectionEnd;
  final Function(Direction)? onDirectionTap;

  const _DirectionButton({
    required this.direction,
    required this.icon,
    required this.onDirectionStart,
    required this.onDirectionEnd,
    this.onDirectionTap,
  });

  @override
  State<_DirectionButton> createState() => _DirectionButtonState();
}

class _DirectionButtonState extends State<_DirectionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Listener(
      onPointerDown: (_) {
        setState(() => _isPressed = true);
        widget.onDirectionStart(widget.direction);
      },
      onPointerUp: (_) {
        setState(() => _isPressed = false);
        widget.onDirectionEnd();
        widget.onDirectionTap?.call(widget.direction);
      },
      onPointerCancel: (_) {
        setState(() => _isPressed = false);
        widget.onDirectionEnd();
      },
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: _isPressed
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Icon(
          widget.icon,
          size: 32,
          color: _isPressed
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
