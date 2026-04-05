import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

class CalculatorService {
  static final Parser _parser = Parser();

  /// 计算表达式
  static String evaluate(String expression, bool isDegreeMode) {
    try {
      // 预处理表达式
      String processedExpr = _preprocessExpression(expression, isDegreeMode);

      // 解析表达式
      final exp = _parser.parse(processedExpr);

      // 创建上下文
      final context = ContextModel();

      // 绑定常量
      context.bindVariable(Variable('pi'), Number(math.pi));
      context.bindVariable(Variable('e'), Number(math.e));

      // 计算结果
      final result = exp.evaluate(EvaluationType.REAL, context);

      return _formatResult(result);
    } catch (e) {
      return 'Error';
    }
  }

  /// 预处理表达式
  static String _preprocessExpression(String expression, bool isDegreeMode) {
    String processed = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('√', 'sqrt')
        .replaceAll('π', 'pi');

    // 处理阶乘: 将 n! 转换为数学表达式
    processed = _convertFactorial(processed);

    // 如果是DEG模式，转换三角函数
    if (isDegreeMode) {
      processed = _convertToDegreeMode(processed);
    }

    // 处理自然对数
    processed = processed.replaceAll('ln(', 'log(');

    return processed;
  }

  /// 将阶乘语法 n! 转换为乘积表达式
  static String _convertFactorial(String expression) {
    // 匹配数字后跟 ! 的模式，如 "5!" 转换为 "(1*2*3*4*5)"
    final regex = RegExp(r'(\d+)!');
    return expression.replaceAllMapped(regex, (match) {
      final numberStr = match.group(1);
      if (numberStr == null) return match.group(0)!;
      final n = int.tryParse(numberStr);
      if (n == null || n < 0 || n > 170) return 'Error';
      if (n == 0 || n == 1) return '1';

      // 构建阶乘表达式: 1*2*3*...*n
      final factors = List.generate(n, (i) => (i + 1).toString()).join('*');
      return '($factors)';
    });
  }

  /// 在DEG模式下转换三角函数
  static String _convertToDegreeMode(String expression) {
    // 将 sin(x) 转换为 sin(x * pi / 180)
    String result = expression;
    result = result.replaceAllMapped(
      RegExp(r'sin\(([^)]+)\)'),
      (match) => 'sin(${match.group(1)} * pi / 180)',
    );
    result = result.replaceAllMapped(
      RegExp(r'cos\(([^)]+)\)'),
      (match) => 'cos(${match.group(1)} * pi / 180)',
    );
    result = result.replaceAllMapped(
      RegExp(r'tan\(([^)]+)\)'),
      (match) => 'tan(${match.group(1)} * pi / 180)',
    );
    return result;
  }

  /// 格式化结果
  static String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return '∞';

    // 处理接近整数的浮点数
    if ((value - value.round()).abs() < 1e-10) {
      return value.round().toString();
    }

    // 保留最多10位小数
    String result = value.toStringAsPrecision(10);

    // 移除末尾的0
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      if (result.endsWith('.')) {
        result = result.substring(0, result.length - 1);
      }
    }

    return result;
  }

  /// 检查表达式是否有效
  static bool isValidExpression(String expression) {
    if (expression.isEmpty) return false;
    try {
      final processed = _preprocessExpression(expression, false);
      if (processed == 'Error') return false;
      _parser.parse(processed);
      return true;
    } catch (e) {
      return false;
    }
  }
}
