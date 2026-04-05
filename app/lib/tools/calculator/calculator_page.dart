import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/usage_service.dart';
import 'models/calculator_state.dart';
import 'services/calculator_service.dart';
import 'widgets/display_panel.dart';
import 'widgets/keyboard_base.dart';
import 'widgets/keyboard_scientific.dart';
import 'widgets/history_panel.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late CalculatorState _state;
  final PageController _keyboardController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _state = CalculatorState();
    UsageService.recordEnter('calculator');
  }

  @override
  void dispose() {
    _keyboardController.dispose();
    UsageService.recordExit('calculator');
    _state.dispose();
    super.dispose();
  }

  void _handleInput(String value) {
    _state.input(value);
  }

  void _handleClear() {
    _state.clear();
  }

  void _handleBackspace() {
    _state.backspace();
  }

  void _handleCalculate() {
    final result = CalculatorService.evaluate(
      _state.expression,
      _state.isDegreeMode,
    );
    _state.calculate(result);
  }

  void _handleToggleSign() {
    // 正负号切换：在当前数字前添加/移除负号
    if (_state.expression.isEmpty) {
      // 表达式为空时，直接输入负号
      _state.input('-');
      return;
    }

    // 找到当前正在输入的数字位置（从末尾开始）
    String expr = _state.expression;

    // 如果最后一个字符是数字或小数点，找到这个数字的起始位置
    if (RegExp(r'[\d.]\$').hasMatch(expr)) {
      // 从后向前查找数字的开始
      int i = expr.length - 1;
      while (i >= 0 && RegExp(r'[\d.]\$').hasMatch(expr[i])) {
        i--;
      }

      // 检查这个数字前是否有负号
      if (i >= 0 && expr[i] == '-') {
        // 检查是否是减号运算符（前面是数字或右括号）
        if (i > 0 && RegExp(r'[\d)]\$').hasMatch(expr[i - 1])) {
          // 这是减号运算符，在当前数字前加负号
          _state.setExpression('\${expr.substring(0, i + 1)}(-\${expr.substring(i + 1)}');
        } else {
          // 这是负号，移除它
          _state.setExpression('\${expr.substring(0, i)}\${expr.substring(i + 1)}');
        }
      } else {
        // 没有负号，在当前数字前加负号
        _state.setExpression('\${expr.substring(0, i + 1)}(-\${expr.substring(i + 1)}');
      }
    } else {
      // 最后一个字符不是数字，直接添加负号
      _state.input('-');
    }
  }

  void _handleToggleAngleMode() {
    _state.toggleAngleMode();
  }

  void _handleMemoryAdd() {
    final currentResult = double.tryParse(_state.result);
    if (currentResult != null) {
      _state.memoryAdd(currentResult);
    }
  }

  void _handleMemorySubtract() {
    final currentResult = double.tryParse(_state.result);
    if (currentResult != null) {
      _state.memorySubtract(currentResult);
    }
  }

  void _handleMemoryRecall() {
    _state.memoryRecall();
  }

  void _handleMemoryClear() {
    _state.memoryClear();
  }

  void _handleHistorySelect(CalculationHistory item) {
    _state.loadFromHistory(item);
  }

  void _handleClearHistory() {
    _state.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('科学计算器'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: Consumer<CalculatorState>(
          builder: (context, state, child) {
            return HistoryPanel(
              history: state.history,
              onSelect: _handleHistorySelect,
              onClear: _handleClearHistory,
            );
          },
        ),
        body: Column(
          children: [
            // 显示面板
            Consumer<CalculatorState>(
              builder: (context, state, child) {
                return DisplayPanel(
                  expression: state.expression,
                  result: state.result,
                );
              },
            ),
            // 页面指示器
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(0),
                  const SizedBox(width: 8),
                  _buildIndicator(1),
                ],
              ),
            ),
            // 键盘区域
            Expanded(
              child: PageView(
                controller: _keyboardController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // 基础键盘页
                  KeyboardBase(
                    onInput: _handleInput,
                    onClear: _handleClear,
                    onBackspace: _handleBackspace,
                    onCalculate: _handleCalculate,
                    onToggleSign: _handleToggleSign,
                  ),
                  // 科学键盘页
                  Consumer<CalculatorState>(
                    builder: (context, state, child) {
                      return KeyboardScientific(
                        onInput: _handleInput,
                        onClear: _handleClear,
                        onBackspace: _handleBackspace,
                        onCalculate: _handleCalculate,
                        onToggleSign: _handleToggleSign,
                        isDegreeMode: state.isDegreeMode,
                        onToggleAngleMode: _handleToggleAngleMode,
                        hasMemoryValue: state.hasMemoryValue,
                        onMemoryAdd: _handleMemoryAdd,
                        onMemorySubtract: _handleMemorySubtract,
                        onMemoryRecall: _handleMemoryRecall,
                        onMemoryClear: _handleMemoryClear,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int page) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == page
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
      ),
    );
  }
}
