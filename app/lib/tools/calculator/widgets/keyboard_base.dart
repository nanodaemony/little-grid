import 'package:flutter/material.dart';
import 'calculator_key.dart';

class KeyboardBase extends StatelessWidget {
  final Function(String) onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onCalculate;
  final VoidCallback onToggleSign;

  const KeyboardBase({
    super.key,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
    required this.onCalculate,
    required this.onToggleSign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 第一行: C ⌫ % ÷
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'C',
                type: KeyType.clear,
                onTap: onClear,
              ),
              CalculatorKey(
                label: '⌫',
                type: KeyType.operator,
                onTap: onBackspace,
              ),
              CalculatorKey(
                label: '%',
                type: KeyType.operator,
                onTap: () => onInput('%'),
              ),
              CalculatorKey(
                label: '÷',
                type: KeyType.operator,
                onTap: () => onInput('÷'),
              ),
            ],
          ),
        ),
        // 第二行: 7 8 9 ×
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '7',
                type: KeyType.number,
                onTap: () => onInput('7'),
              ),
              CalculatorKey(
                label: '8',
                type: KeyType.number,
                onTap: () => onInput('8'),
              ),
              CalculatorKey(
                label: '9',
                type: KeyType.number,
                onTap: () => onInput('9'),
              ),
              CalculatorKey(
                label: '×',
                type: KeyType.operator,
                onTap: () => onInput('×'),
              ),
            ],
          ),
        ),
        // 第三行: 4 5 6 -
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '4',
                type: KeyType.number,
                onTap: () => onInput('4'),
              ),
              CalculatorKey(
                label: '5',
                type: KeyType.number,
                onTap: () => onInput('5'),
              ),
              CalculatorKey(
                label: '6',
                type: KeyType.number,
                onTap: () => onInput('6'),
              ),
              CalculatorKey(
                label: '-',
                type: KeyType.operator,
                onTap: () => onInput('-'),
              ),
            ],
          ),
        ),
        // 第四行: 1 2 3 +
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '1',
                type: KeyType.number,
                onTap: () => onInput('1'),
              ),
              CalculatorKey(
                label: '2',
                type: KeyType.number,
                onTap: () => onInput('2'),
              ),
              CalculatorKey(
                label: '3',
                type: KeyType.number,
                onTap: () => onInput('3'),
              ),
              CalculatorKey(
                label: '+',
                type: KeyType.operator,
                onTap: () => onInput('+'),
              ),
            ],
          ),
        ),
        // 第五行: ( 0 . )
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '(',
                type: KeyType.operator,
                onTap: () => onInput('('),
              ),
              CalculatorKey(
                label: '0',
                type: KeyType.number,
                onTap: () => onInput('0'),
              ),
              CalculatorKey(
                label: '.',
                type: KeyType.number,
                onTap: () => onInput('.'),
              ),
              CalculatorKey(
                label: ')',
                type: KeyType.operator,
                onTap: () => onInput(')'),
              ),
            ],
          ),
        ),
        // 第六行: ± =
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '±',
                type: KeyType.operator,
                onTap: onToggleSign,
                flex: 1,
              ),
              CalculatorKey(
                label: '=',
                type: KeyType.equals,
                onTap: onCalculate,
                flex: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
