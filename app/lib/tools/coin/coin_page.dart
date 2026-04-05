import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/ui/app_colors.dart';

class CoinPage extends StatefulWidget {
  const CoinPage({super.key});

  @override
  State<CoinPage> createState() => _CoinPageState();
}

class _CoinPageState extends State<CoinPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFlipping = false;
  bool? _isHeads; // true=正面, false=反面
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCoin() {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    _controller.forward(from: 0).then((_) {
      setState(() {
        _isHeads = _random.nextBool();
        _isFlipping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投硬币'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 硬币显示
            GestureDetector(
              onTap: _flipCoin,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final angle = _controller.value * 4 * 3.14159;
                  // 根据旋转角度决定显示哪一面，模拟硬币翻转效果
                  final bool showHeads = _isFlipping
                      ? (angle ~/ 3.14159) % 2 == 0
                      : (_isHeads ?? true);
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getCoinColor(),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _isHeads == null && !_isFlipping
                            ? Container(
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Text(
                                    '?',
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : Image.asset(
                                showHeads
                                    ? 'assets/images/coins/coin_heads.png'
                                    : 'assets/images/coins/coin_tails.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 48),

            // 结果文字
            if (!_isFlipping && _isHeads != null)
              Text(
                _isHeads! ? '金额' : '花',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              )
                  .animate()
                  .scale(delay: 100.ms, duration: 300.ms)
                  .fadeIn(),

            const SizedBox(height: 48),

            // 投掷按钮
            ElevatedButton.icon(
              onPressed: _isFlipping ? null : _flipCoin,
              icon: const Icon(Icons.refresh),
              label: const Text('投硬币'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoinColor() {
    if (_isFlipping) return Colors.grey.shade300;
    return (_isHeads == null || _isHeads!) ? Colors.grey.shade300 : Colors.grey.shade400;
  }
}

