import 'package:flutter/foundation.dart';

class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}

class CalculatorState extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  bool _isDegreeMode = true;
  double _memoryValue = 0;
  bool _hasMemoryValue = false;
  final List<CalculationHistory> _history = [];

  String get expression => _expression;
  String get result => _result;
  bool get isDegreeMode => _isDegreeMode;
  double get memoryValue => _memoryValue;
  bool get hasMemoryValue => _hasMemoryValue;
  List<CalculationHistory> get history => List.unmodifiable(_history);

  void input(String value) {
    if (_expression.length >= 100) return;
    _expression += value;
    notifyListeners();
  }

  void clear() {
    _expression = '';
    _result = '0';
    notifyListeners();
  }

  void backspace() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      notifyListeners();
    }
  }

  void toggleAngleMode() {
    _isDegreeMode = !_isDegreeMode;
    notifyListeners();
  }

  void calculate(String computedResult) {
    _result = computedResult;
    if (_expression.isNotEmpty && computedResult != 'Error') {
      _addToHistory(_expression, computedResult);
    }
    notifyListeners();
  }

  void setExpression(String expression) {
    _expression = expression;
    notifyListeners();
  }

  void memoryAdd(double value) {
    _memoryValue += value;
    _hasMemoryValue = true;
    notifyListeners();
  }

  void memorySubtract(double value) {
    _memoryValue -= value;
    _hasMemoryValue = true;
    notifyListeners();
  }

  void memoryRecall() {
    if (_hasMemoryValue) {
      _expression += _formatMemoryValue();
      notifyListeners();
    }
  }

  void memoryClear() {
    _memoryValue = 0;
    _hasMemoryValue = false;
    notifyListeners();
  }

  String _formatMemoryValue() {
    if (_memoryValue == _memoryValue.roundToDouble()) {
      return _memoryValue.round().toString();
    }
    return _memoryValue.toString();
  }

  void _addToHistory(String expression, String result) {
    _history.add(CalculationHistory(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    ));
    if (_history.length > 20) {
      _history.removeAt(0);
    }
  }

  void loadFromHistory(CalculationHistory item) {
    _expression = item.expression;
    _result = item.result;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
