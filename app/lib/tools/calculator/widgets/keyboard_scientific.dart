import 'package:flutter/material.dart';
import 'calculator_key.dart';

class KeyboardScientific extends StatefulWidget {
  final Function(String) onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onCalculate;
  final VoidCallback onToggleSign;
  final bool isDegreeMode;
  final VoidCallback onToggleAngleMode;
  final bool hasMemoryValue;
  final VoidCallback onMemoryAdd;
  final VoidCallback onMemorySubtract;
  final VoidCallback onMemoryRecall;
  final VoidCallback onMemoryClear;

  const KeyboardScientific({
    super.key,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
    required this.onCalculate,
    required this.onToggleSign,
    required this.isDegreeMode,
    required this.onToggleAngleMode,
    required this.hasMemoryValue,
    required this.onMemoryAdd,
    required this.onMemorySubtract,
    required this.onMemoryRecall,
    required this.onMemoryClear,
  });

  @override
  State<KeyboardScientific> createState() => _KeyboardScientificState();
}

class _KeyboardScientificState extends State<KeyboardScientific> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const _CustomPageScrollPhysics(),
      children: [
        _buildFirstPage(),
        _buildSecondPage(),
      ],
    );
  }

  Widget _buildFirstPage() {
    return Column(
      children: [
        // 第一行: DEG C ⌫ % ÷
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: widget.isDegreeMode ? 'DEG' : 'RAD',
                type: KeyType.function,
                onTap: widget.onToggleAngleMode,
              ),
              CalculatorKey(
                label: 'C',
                type: KeyType.clear,
                onTap: widget.onClear,
              ),
              CalculatorKey(
                label: '⌫',
                type: KeyType.operator,
                onTap: widget.onBackspace,
              ),
              CalculatorKey(
                label: '%',
                type: KeyType.operator,
                onTap: () => widget.onInput('%'),
              ),
              CalculatorKey(
                label: '÷',
                type: KeyType.operator,
                onTap: () => widget.onInput('÷'),
              ),
            ],
          ),
        ),
        // 第二行: sin 7 8 9 ×
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'sin',
                type: KeyType.function,
                onTap: () => widget.onInput('sin('),
              ),
              CalculatorKey(
                label: '7',
                type: KeyType.number,
                onTap: () => widget.onInput('7'),
              ),
              CalculatorKey(
                label: '8',
                type: KeyType.number,
                onTap: () => widget.onInput('8'),
              ),
              CalculatorKey(
                label: '9',
                type: KeyType.number,
                onTap: () => widget.onInput('9'),
              ),
              CalculatorKey(
                label: '×',
                type: KeyType.operator,
                onTap: () => widget.onInput('×'),
              ),
            ],
          ),
        ),
        // 第三行: cos 4 5 6 -
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'cos',
                type: KeyType.function,
                onTap: () => widget.onInput('cos('),
              ),
              CalculatorKey(
                label: '4',
                type: KeyType.number,
                onTap: () => widget.onInput('4'),
              ),
              CalculatorKey(
                label: '5',
                type: KeyType.number,
                onTap: () => widget.onInput('5'),
              ),
              CalculatorKey(
                label: '6',
                type: KeyType.number,
                onTap: () => widget.onInput('6'),
              ),
              CalculatorKey(
                label: '-',
                type: KeyType.operator,
                onTap: () => widget.onInput('-'),
              ),
            ],
          ),
        ),
        // 第四行: tan 1 2 3 +
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'tan',
                type: KeyType.function,
                onTap: () => widget.onInput('tan('),
              ),
              CalculatorKey(
                label: '1',
                type: KeyType.number,
                onTap: () => widget.onInput('1'),
              ),
              CalculatorKey(
                label: '2',
                type: KeyType.number,
                onTap: () => widget.onInput('2'),
              ),
              CalculatorKey(
                label: '3',
                type: KeyType.number,
                onTap: () => widget.onInput('3'),
              ),
              CalculatorKey(
                label: '+',
                type: KeyType.operator,
                onTap: () => widget.onInput('+'),
              ),
            ],
          ),
        ),
        // 第五行: π ( 0 . ) e
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'π',
                type: KeyType.function,
                onTap: () => widget.onInput('π'),
              ),
              CalculatorKey(
                label: '(',
                type: KeyType.operator,
                onTap: () => widget.onInput('('),
              ),
              CalculatorKey(
                label: '0',
                type: KeyType.number,
                onTap: () => widget.onInput('0'),
              ),
              CalculatorKey(
                label: '.',
                type: KeyType.number,
                onTap: () => widget.onInput('.'),
              ),
              CalculatorKey(
                label: ')',
                type: KeyType.operator,
                onTap: () => widget.onInput(')'),
              ),
            ],
          ),
        ),
        // 第六行: = e
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'e',
                type: KeyType.function,
                onTap: () => widget.onInput('e'),
                flex: 1,
              ),
              CalculatorKey(
                label: '=',
                type: KeyType.equals,
                onTap: widget.onCalculate,
                flex: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Column(
      children: [
        // 第一行: DEG C ⌫ n! ÷
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: widget.isDegreeMode ? 'DEG' : 'RAD',
                type: KeyType.function,
                onTap: widget.onToggleAngleMode,
              ),
              CalculatorKey(
                label: 'C',
                type: KeyType.clear,
                onTap: widget.onClear,
              ),
              CalculatorKey(
                label: '⌫',
                type: KeyType.operator,
                onTap: widget.onBackspace,
              ),
              CalculatorKey(
                label: 'n!',
                type: KeyType.function,
                onTap: () => widget.onInput('!'),
              ),
              CalculatorKey(
                label: '÷',
                type: KeyType.operator,
                onTap: () => widget.onInput('÷'),
              ),
            ],
          ),
        ),
        // 第二行: log 7 8 9 ×
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'log',
                type: KeyType.function,
                onTap: () => widget.onInput('log('),
              ),
              CalculatorKey(
                label: '7',
                type: KeyType.number,
                onTap: () => widget.onInput('7'),
              ),
              CalculatorKey(
                label: '8',
                type: KeyType.number,
                onTap: () => widget.onInput('8'),
              ),
              CalculatorKey(
                label: '9',
                type: KeyType.number,
                onTap: () => widget.onInput('9'),
              ),
              CalculatorKey(
                label: '×',
                type: KeyType.operator,
                onTap: () => widget.onInput('×'),
              ),
            ],
          ),
        ),
        // 第三行: ln 4 5 6 -
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'ln',
                type: KeyType.function,
                onTap: () => widget.onInput('ln('),
              ),
              CalculatorKey(
                label: '4',
                type: KeyType.number,
                onTap: () => widget.onInput('4'),
              ),
              CalculatorKey(
                label: '5',
                type: KeyType.number,
                onTap: () => widget.onInput('5'),
              ),
              CalculatorKey(
                label: '6',
                type: KeyType.number,
                onTap: () => widget.onInput('6'),
              ),
              CalculatorKey(
                label: '-',
                type: KeyType.operator,
                onTap: () => widget.onInput('-'),
              ),
            ],
          ),
        ),
        // 第四行: x² 1 2 3 +
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'x²',
                type: KeyType.function,
                onTap: () => widget.onInput('^2'),
              ),
              CalculatorKey(
                label: '1',
                type: KeyType.number,
                onTap: () => widget.onInput('1'),
              ),
              CalculatorKey(
                label: '2',
                type: KeyType.number,
                onTap: () => widget.onInput('2'),
              ),
              CalculatorKey(
                label: '3',
                type: KeyType.number,
                onTap: () => widget.onInput('3'),
              ),
              CalculatorKey(
                label: '+',
                type: KeyType.operator,
                onTap: () => widget.onInput('+'),
              ),
            ],
          ),
        ),
        // 第五行: ( M+ M- MR )
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '(',
                type: KeyType.operator,
                onTap: () => widget.onInput('('),
              ),
              CalculatorKey(
                label: 'M+',
                type: widget.hasMemoryValue ? KeyType.function : KeyType.number,
                onTap: widget.onMemoryAdd,
              ),
              CalculatorKey(
                label: 'M-',
                type: widget.hasMemoryValue ? KeyType.function : KeyType.number,
                onTap: widget.onMemorySubtract,
              ),
              CalculatorKey(
                label: 'MR',
                type: widget.hasMemoryValue ? KeyType.function : KeyType.number,
                onTap: widget.onMemoryRecall,
              ),
              CalculatorKey(
                label: ')',
                type: KeyType.operator,
                onTap: () => widget.onInput(')'),
              ),
            ],
          ),
        ),
        // 第六行: √ xʸ =
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '√',
                type: KeyType.function,
                onTap: () => widget.onInput('√('),
                flex: 1,
              ),
              CalculatorKey(
                label: 'xʸ',
                type: KeyType.function,
                onTap: () => widget.onInput('^'),
                flex: 1,
              ),
              CalculatorKey(
                label: '=',
                type: KeyType.equals,
                onTap: widget.onCalculate,
                flex: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 自定义滚动物理，在到达边界时允许父级处理手势
class _CustomPageScrollPhysics extends PageScrollPhysics {
  const _CustomPageScrollPhysics({super.parent});

  @override
  _CustomPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CustomPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final double result = super.applyBoundaryConditions(position, value);
    // 当到达边界时，返回0让父级有机会处理
    if (result != 0.0) {
      return 0.0;
    }
    return result;
  }
}
