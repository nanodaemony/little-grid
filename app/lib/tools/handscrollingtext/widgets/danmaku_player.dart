import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';

class DanmakuPlayer extends StatefulWidget {
  final DanmakuConfig config;
  final bool isPreview;

  const DanmakuPlayer({
    super.key,
    required this.config,
    this.isPreview = false,
  });

  @override
  State<DanmakuPlayer> createState() => _DanmakuPlayerState();
}

class _DanmakuPlayerState extends State<DanmakuPlayer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(DanmakuPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.mode != widget.config.mode ||
        oldWidget.config.speed != widget.config.speed ||
        oldWidget.config.text != widget.config.text) {
      _initAnimation();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initAnimation() {
    _controller?.dispose();

    if (widget.config.mode != DanmakuMode.scroll) {
      _controller = null;
      _animation = null;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      final estimatedWidth = widget.config.text.length * widget.config.fontSize * 0.8;
      final distance = screenWidth + estimatedWidth;
      final durationMs = (distance / widget.config.speed * 20).toInt();

      _controller = AnimationController(
        duration: Duration(milliseconds: durationMs.clamp(2000, 20000)),
        vsync: this,
      );

      _animation = Tween<double>(
        begin: screenWidth,
        end: -estimatedWidth,
      ).animate(_controller!);

      _controller!.repeat();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          TextStyle textStyle = TextStyle(
            fontSize: widget.isPreview
                ? widget.config.fontSize * 0.3
                : widget.config.fontSize,
            color: widget.config.textColor,
            fontWeight: FontWeight.bold,
          );

          switch (widget.config.fontFamily) {
            case 'serif':
              textStyle = textStyle.copyWith(fontFamily: 'serif');
              break;
            case 'sansSerif':
              textStyle = textStyle.copyWith(fontFamily: 'sans-serif');
              break;
            case 'monospace':
              textStyle = textStyle.copyWith(fontFamily: 'monospace');
              break;
          }

          if (widget.config.mode == DanmakuMode.scroll && _animation != null) {
            return AnimatedBuilder(
              animation: _animation!,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      left: _animation!.value,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          widget.config.text,
                          style: textStyle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return Center(
              child: Text(
                widget.config.text,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            );
          }
        },
      ),
    );
  }
}
