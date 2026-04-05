import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/rmbconvertor/services/rmb_converter.dart';

void main() {
  group('RmbConverter', () {
    test('converts 0 correctly', () {
      expect(RmbConverter.convert(0), '零元整');
    });

    test('converts single digits', () {
      expect(RmbConverter.convert(1), '壹元整');
      expect(RmbConverter.convert(5), '伍元整');
      expect(RmbConverter.convert(9), '玖元整');
    });

    test('converts tens correctly', () {
      expect(RmbConverter.convert(10), '壹拾元整');
      expect(RmbConverter.convert(15), '壹拾伍元整');
      expect(RmbConverter.convert(20), '贰拾元整');
    });

    test('converts hundreds correctly', () {
      expect(RmbConverter.convert(100), '壹佰元整');
      expect(RmbConverter.convert(101), '壹佰零壹元整');
      expect(RmbConverter.convert(110), '壹佰壹拾元整');
      expect(RmbConverter.convert(123), '壹佰贰拾叁元整');
    });

    test('converts thousands correctly', () {
      expect(RmbConverter.convert(1000), '壹仟元整');
      expect(RmbConverter.convert(1001), '壹仟零壹元整');
      expect(RmbConverter.convert(1234), '壹仟贰佰叁拾肆元整');
    });

    test('converts ten thousands correctly', () {
      expect(RmbConverter.convert(10000), '壹万元整');
      expect(RmbConverter.convert(10001), '壹万零壹元整');
      expect(RmbConverter.convert(12345), '壹万贰仟叁佰肆拾伍元整');
    });

    test('converts hundred millions correctly', () {
      expect(RmbConverter.convert(100000000), '壹亿元整');
      expect(RmbConverter.convert(100000001), '壹亿零壹元整');
      expect(RmbConverter.convert(123456789), '壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖元整');
    });

    test('converts decimals correctly', () {
      expect(RmbConverter.convert(0.01), '壹分');
      expect(RmbConverter.convert(0.10), '壹角');
      expect(RmbConverter.convert(0.15), '壹角伍分');
      expect(RmbConverter.convert(1.23), '壹元贰角叁分');
      expect(RmbConverter.convert(100.50), '壹佰元伍角');
    });

    test('converts complex amounts', () {
      expect(RmbConverter.convert(1004.06), '壹仟零肆元零陆分');
      expect(RmbConverter.convert(100000.01), '壹拾万零壹分');
    });

    test('formatInput adds thousand separators', () {
      expect(RmbConverter.formatInput('1234'), '1,234');
      expect(RmbConverter.formatInput('1234.56'), '1,234.56');
      expect(RmbConverter.formatInput('1234567'), '1,234,567');
    });

    test('parseAmount parses formatted string', () {
      expect(RmbConverter.parseAmount('1,234.56'), 1234.56);
      expect(RmbConverter.parseAmount('1,234'), 1234.0);
    });
  });
}
