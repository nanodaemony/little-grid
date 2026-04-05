/// 人民币金额转大写服务
class RmbConverter {
  // 数字映射
  static const List<String> _digits = [
    '零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'
  ];

  // 单位映射
  static const List<String> _units = ['', '拾', '佰', '仟'];
  static const List<String> _bigUnits = ['', '万', '亿'];

  /// 将金额数字转换为人民币大写
  ///
  /// [amount]: 金额，如 1234.56
  /// 返回: 大写字符串，如 "壹仟贰佰叁拾肆元伍角陆分"
  static String convert(double amount) {
    if (amount == 0) return '零元整';

    // 分离整数和小数部分
    int integerPart = amount.floor();
    int decimalPart = ((amount - integerPart) * 100).round();

    String result = '';

    // 处理整数部分
    if (integerPart > 0) {
      result = _convertInteger(integerPart);
      result += '元';
    } else if (decimalPart == 0) {
      // 整数和小数都为0的情况已在上面处理
      result = '零元整';
      return result;
    }
    // 如果整数部分为0但小数部分不为0，不添加"零元"前缀

    // 处理小数部分（角、分）
    int jiao = decimalPart ~/ 10;
    int fen = decimalPart % 10;

    if (jiao == 0 && fen == 0) {
      // 只有整数部分，添加"整"
      if (integerPart > 0) {
        result += '整';
      }
    } else {
      if (jiao > 0) {
        result += _digits[jiao] + '角';
      }
      if (fen > 0) {
        result += _digits[fen] + '分';
      }
    }

    return result;
  }

  /// 转换整数部分
  static String _convertInteger(int number) {
    if (number == 0) return '';

    String result = '';
    int bigUnitIndex = 0;

    while (number > 0) {
      int segment = number % 10000;
      if (segment != 0) {
        String segmentStr = _convertSegment(segment);
        if (bigUnitIndex > 0) {
          segmentStr += _bigUnits[bigUnitIndex];
        }
        result = segmentStr + result;
      } else if (result.isNotEmpty && !result.startsWith('零')) {
        result = '零' + result;
      }

      number ~/= 10000;
      bigUnitIndex++;
    }

    // 清理连续的零
    result = _cleanZeros(result);

    return result;
  }

  /// 转换4位数段（个、十、百、千）
  static String _convertSegment(int number) {
    String result = '';
    int unitIndex = 0;

    while (number > 0) {
      int digit = number % 10;
      if (digit != 0) {
        result = _digits[digit] + _units[unitIndex] + result;
      } else if (result.isNotEmpty && !result.startsWith('零')) {
        result = '零' + result;
      }
      number ~/= 10;
      unitIndex++;
    }

    return result;
  }

  /// 清理连续的零
  static String _cleanZeros(String str) {
    String result = str.replaceAll(RegExp(r'零+'), '零');
    // 去除末尾的零
    if (result.endsWith('零') && result.length > 1) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  /// 验证金额是否在支持范围内
  static bool isValidAmount(double amount) {
    return amount >= 0 && amount <= 999999999.99;
  }

  /// 格式化输入（添加千分位逗号）
  static String formatInput(String input) {
    // 过滤非数字和小数点
    String filtered = input.replaceAll(RegExp(r'[^\d.]'), '');

    // 处理多个小数点
    int firstDot = filtered.indexOf('.');
    if (firstDot != -1) {
      String beforeDot = filtered.substring(0, firstDot);
      String afterDot = filtered.substring(firstDot + 1).replaceAll('.', '');
      // 限制小数位为2位
      if (afterDot.length > 2) {
        afterDot = afterDot.substring(0, 2);
      }
      filtered = beforeDot + '.' + afterDot;
    }

    // 添加千分位逗号
    List<String> parts = filtered.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

    // 处理整数部分的千分位
    if (integerPart.length > 3) {
      StringBuffer result = StringBuffer();
      int count = 0;
      for (int i = integerPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          result.write(',');
        }
        result.write(integerPart[i]);
        count++;
      }
      integerPart = result.toString().split('').reversed.join();
    }

    return integerPart + decimalPart;
  }

  /// 解析格式化的字符串为数字
  static double parseAmount(String formatted) {
    String cleaned = formatted.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0;
  }
}
