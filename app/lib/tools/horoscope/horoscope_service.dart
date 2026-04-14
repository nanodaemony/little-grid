import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/zodiac_sign.dart';
import 'models/horoscope_data.dart';

/// 星座运势服务
class HoroscopeService {
  /// 本地存储键
  static const String _defaultZodiacKey = 'horoscope_default_zodiac';
  static const String _cachePrefix = 'horoscope_cache';

  /// 获取运势（优先 API，失败时本地生成）
  static Future<HoroscopeData> getHoroscope(
    ZodiacSign sign,
    String type, // 'today' or 'week'
  ) async {
    try {
      // 先尝试 API（预留接口，暂时先用本地）
      // return await _getFromApi(sign, type);
      return await _generateLocal(sign, type);
    } catch (e) {
      debugPrint('API failed, using local generation: $e');
      return await _generateLocal(sign, type);
    }
  }

  /// 本地生成运势
  static Future<HoroscopeData> _generateLocal(
    ZodiacSign sign,
    String type,
  ) async {
    // 使用星座 ID + 日期作为种子，确保同一天同一星座结果一致
    final now = DateTime.now();
    final seed = '${sign.id}_${type}_${now.year}_${now.month}_${now.day}';
    final random = Random(seed.hashCode);

    // 根据类型生成不同范围的分数
    final isToday = type == 'today';
    final minScore = isToday ? 40 : 35;
    final maxScore = isToday ? 95 : 90;

    int randomScore() => minScore + random.nextInt(maxScore - minScore + 1);

    final overallScore = randomScore();

    return HoroscopeData(
      type: type,
      overallScore: overallScore,
      overallDesc: _getRandomDesc(overallScore, 'overall', random),
      loveScore: randomScore(),
      loveDesc: _getRandomDesc(randomScore(), 'love', random),
      careerScore: randomScore(),
      careerDesc: _getRandomDesc(randomScore(), 'career', random),
      wealthScore: randomScore(),
      wealthDesc: _getRandomDesc(randomScore(), 'wealth', random),
      healthScore: randomScore(),
      healthDesc: _getRandomDesc(randomScore(), 'health', random),
    );
  }

  /// 获取随机描述
  static String _getRandomDesc(int score, String category, Random random) {
    final templates = _descTemplates[category] ?? _descTemplates['overall']!;
    final level = score >= 80 ? 'high' : score >= 60 ? 'mid' : score >= 40 ? 'low' : 'poor';
    final list = templates[level] ?? templates['mid']!;
    return list[random.nextInt(list.length)];
  }

  /// 描述模板库
  static const Map<String, Map<String, List<String>>> _descTemplates = {
    'overall': {
      'high': [
        '今日运势极佳，把握机会！',
        '万事顺心，适合开展新计划。',
        '精力充沛，好运连连。',
      ],
      'mid': [
        '整体运势平稳，按部就班即可。',
        '有小惊喜，但需要保持耐心。',
        '运势中等，稳定发展为主。',
      ],
      'low': [
        '运势平平，建议保守行事。',
        '需要多加注意，避免冲动决策。',
        '保持低调，静待时机。',
      ],
      'poor': [
        '运势较低迷，建议多休息调整。',
        '诸事不顺，心态最重要。',
        '小心行事，避免意外状况。',
      ],
    },
    'love': {
      'high': [
        '桃花运旺盛，适合表白。',
        '感情甜蜜，互动温馨。',
        '魅力四射，异性缘佳。',
      ],
      'mid': [
        '感情平稳，细水长流。',
        '有小摩擦，沟通可解决。',
        '平淡中见真情。',
      ],
      'low': [
        '感情平淡，需要多花心思。',
        '避免争吵，多些理解。',
        '单身者可静待缘分。',
      ],
      'poor': [
        '感情易有波折，保持冷静。',
        '不宜表白，先提升自己。',
        '感情低潮期，多爱自己。',
      ],
    },
    'career': {
      'high': [
        '事业运佳，有望获得突破。',
        '工作顺利，贵人相助。',
        '展现能力，获得认可。',
      ],
      'mid': [
        '工作平稳，按计划推进。',
        '有小挑战，可从容应对。',
        '稳扎稳打，步步为营。',
      ],
      'low': [
        '工作压力较大，注意调节。',
        '避免失误，仔细检查。',
        '低调行事，避免纠纷。',
      ],
      'poor': [
        '事业多阻滞，需保持耐心。',
        '不宜跳槽，稳定为上。',
        '工作易出错，加倍小心。',
      ],
    },
    'wealth': {
      'high': [
        '财运亨通，有意外收获。',
        '适合投资，眼光独到。',
        '正财偏财皆有收获。',
      ],
      'mid': [
        '财运平稳，量入为出。',
        '有小财运，不宜贪心。',
        '收支平衡，稳健理财。',
      ],
      'low': [
        '财运一般，避免大额支出。',
        '不宜投资，保守为上。',
        '注意财务，避免损失。',
      ],
      'poor': [
        '财运低迷，小心破财。',
        '捂紧钱包，避免借贷。',
        '投资需谨慎，保本最重要。',
      ],
    },
    'health': {
      'high': [
        '精力充沛，身心愉悦。',
        '身体状态极佳，适合运动。',
        '元气满满，健康有活力。',
      ],
      'mid': [
        '身体状况良好，注意作息。',
        '整体健康，适当锻炼。',
        '无大碍，保持规律生活。',
      ],
      'low': [
        '感觉疲惫，多休息。',
        '注意饮食，避免熬夜。',
        '小毛病需注意调理。',
      ],
      'poor': [
        '身体欠佳，及早就医。',
        '过度劳累，需要休养。',
        '健康亮红灯，多加关注。',
      ],
    },
  };

  /// API 获取（预留，待接入真实 API）
  static Future<HoroscopeData> _getFromApi(
    ZodiacSign sign,
    String type,
  ) async {
    // 预留 API 接口，可接入天行数据、聚合数据等
    throw UnimplementedError('API not implemented yet');
  }

  /// 简短描述（用于 1 行显示）
  static String getShortDesc(int score, String category) {
    if (score >= 80) {
      return '运势极佳';
    }
    if (score >= 60) {
      return '运势良好';
    }
    if (score >= 40) {
      return '运势平稳';
    }
    return '需多注意';
  }

  /// 获取分项图标
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'love':
        return Icons.favorite;
      case 'career':
        return Icons.work;
      case 'wealth':
        return Icons.attach_money;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.star;
    }
  }

  /// 获取分项名称
  static String getCategoryName(String category) {
    switch (category) {
      case 'love':
        return '爱情运势';
      case 'career':
        return '事业运势';
      case 'wealth':
        return '财运运势';
      case 'health':
        return '健康运势';
      default:
        return '综合运势';
    }
  }
}
