import 'package:flutter/material.dart';

/// 12星座数据
class ZodiacSign {
  final String id;
  final String name;
  final String dateRange;
  final IconData icon;

  const ZodiacSign({
    required this.id,
    required this.name,
    required this.dateRange,
    required this.icon,
  });

  /// 获取所有12星座
  static const List<ZodiacSign> all = [
    ZodiacSign(
      id: 'aries',
      name: '白羊座',
      dateRange: '3.21-4.19',
      icon: Icons.emoji_events,
    ),
    ZodiacSign(
      id: 'taurus',
      name: '金牛座',
      dateRange: '4.20-5.20',
      icon: Icons.eco,
    ),
    ZodiacSign(
      id: 'gemini',
      name: '双子座',
      dateRange: '5.21-6.21',
      icon: Icons.people,
    ),
    ZodiacSign(
      id: 'cancer',
      name: '巨蟹座',
      dateRange: '6.22-7.22',
      icon: Icons.nightlight,
    ),
    ZodiacSign(
      id: 'leo',
      name: '狮子座',
      dateRange: '7.23-8.23',
      icon: Icons.wb_sunny,
    ),
    ZodiacSign(
      id: 'virgo',
      name: '处女座',
      dateRange: '8.24-9.23',
      icon: Icons.check_circle,
    ),
    ZodiacSign(
      id: 'libra',
      name: '天秤座',
      dateRange: '9.24-10.23',
      icon: Icons.balance,
    ),
    ZodiacSign(
      id: 'scorpio',
      name: '天蝎座',
      dateRange: '10.24-11.22',
      icon: Icons.visibility,
    ),
    ZodiacSign(
      id: 'sagittarius',
      name: '射手座',
      dateRange: '11.23-12.21',
      icon: Icons.rocket_launch,
    ),
    ZodiacSign(
      id: 'capricorn',
      name: '摩羯座',
      dateRange: '12.22-1.19',
      icon: Icons.terrain,
    ),
    ZodiacSign(
      id: 'aquarius',
      name: '水瓶座',
      dateRange: '1.20-2.18',
      icon: Icons.water,
    ),
    ZodiacSign(
      id: 'pisces',
      name: '双鱼座',
      dateRange: '2.19-3.20',
      icon: Icons.waves,
    ),
  ];

  /// 根据 ID 获取星座
  static ZodiacSign? fromId(String id) {
    try {
      return all.firstWhere((z) => z.id == id);
    } catch (e) {
      return null;
    }
  }
}
