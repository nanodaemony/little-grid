import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DicePage extends StatefulWidget {
  const DicePage({super.key});

  @override
  State<DicePage> createState() => _DicePageState();
}

class _DicePageState extends State<DicePage> {
  final Random _random = Random();
  List<int> _diceValues = [1];
  int _diceCount = 1;
  bool _isRolling = false;
  Timer? _rollTimer;

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }

  void _rollDice() {
    if (_isRolling) return;

    setState(() {
      _isRolling = true;
    });

    // 随机点数切换动画
    int elapsed = 0;
    const interval = 60; // 每60ms切换一次
    const duration = 600; // 总时长600ms

    _rollTimer?.cancel();
    _rollTimer = Timer.periodic(const Duration(milliseconds: interval), (timer) {
      setState(() {
        _diceValues = List.generate(
          _diceCount,
          (_) => _random.nextInt(6) + 1,
        );
      });

      elapsed += interval;
      if (elapsed >= duration) {
        timer.cancel();
        setState(() {
          _isRolling = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('骰子'),
      ),
      body: Column(
        children: [
          // 骰子数量选择
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('骰子数量:'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _diceCount > 1
                      ? () {
                          setState(() {
                            _diceCount--;
                            _diceValues = List.filled(_diceCount, 1);
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '$_diceCount',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: _diceCount < 6
                      ? () {
                          setState(() {
                            _diceCount++;
                            _diceValues = List.filled(_diceCount, 1);
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // 骰子显示区
          Expanded(
            child: Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: _diceValues.map((value) {
                  return _DiceWidget(
                    value: value,
                    isRolling: _isRolling,
                  );
                }).toList(),
              ),
            ),
          ),

          // 点数总和
          if (_diceValues.length > 1 && !_isRolling)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '总和: ${_diceValues.reduce((a, b) => a + b)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().scale(),
            ),

          // 投掷按钮
          Padding(
            padding: const EdgeInsets.all(32),
            child: ElevatedButton.icon(
              onPressed: _isRolling ? null : _rollDice,
              icon: const Icon(Icons.casino),
              label: const Text('投掷'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiceWidget extends StatelessWidget {
  final int value;
  final bool isRolling;

  const _DiceWidget({required this.value, required this.isRolling});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: _buildDots(value),
    ).animate(target: isRolling ? 1 : 0).shake();
  }

  Widget _buildDots(int value) {
    final dotColor = Colors.red.shade600;
    final dotSize = 12.0;

    Widget dot() => Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        );

    switch (value) {
      case 1:
        return Center(child: dot());
      case 2:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [dot(), const Spacer(), dot()],
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [dot(), Center(child: dot()), dot()],
          ),
        );
      case 4:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
            ],
          ),
        );
      case 5:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Center(child: dot()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
            ],
          ),
        );
      case 6:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [dot(), dot()],
              ),
            ],
          ),
        );
      default:
        return Center(child: dot());
    }
  }
}
