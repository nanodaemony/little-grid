# 星座运势工具实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个星座运势功能格子，支持设置默认星座，展示今日和本周运势，包含综合指数及爱情、事业、财运、健康分项指数，使用 API + 本地混合模式。

**Architecture:** 遵循现有工具架构模式，创建 ToolModule 实现类 + Service 数据层 + Page UI 层的三层结构。优先使用 API 获取数据，失败时使用本地算法兜底，本地缓存 4-12 小时。

**Tech Stack:** Flutter + Dart, http package (已有), flutter_animate (已有)

---

## 文件结构

```
app/lib/tools/horoscope/
├── horoscope_tool.dart       # ToolModule 实现，工具注册入口
├── horoscope_page.dart       # 星座运势主页面 UI
├── horoscope_service.dart    # API 服务、本地生成算法、数据模型
├── models/
│   ├── zodiac_sign.dart      # 星座数据模型
│   └── horoscope_data.dart   # 运势数据模型
└── widgets/
    ├── zodiac_selector.dart  # 星座选择器（底部弹窗）
    ├── fortune_card.dart     # 综合运势卡片
    └── fortune_item.dart     # 分项运势项组件

app/lib/main.dart              # 注册 HoroscopeTool

app/pubspec.yaml               # 确认 http 依赖存在
```

---

## Task 1: 确认依赖和创建目录

**Files:**
- Check: `app/pubspec.yaml`
- Create: `app/lib/tools/horoscope/` 目录及子目录

- [ ] **Step 1: 检查 http 依赖是否已存在**

```bash
grep "http:" app/pubspec.yaml
```

- [ ] **Step 2: 如未存在，添加依赖**

```yaml
# 在 dependencies 部分添加
  http: ^1.2.0
```

- [ ] **Step 3: 运行 pub get (如修改了 pubspec.yaml)**

```bash
cd app && flutter pub get
```

- [ ] **Step 4: 创建目录结构**

```bash
mkdir -p app/lib/tools/horoscope/models
mkdir -p app/lib/tools/horoscope/widgets
```

- [ ] **Step 5: Commit**

```bash
# 只有修改了 pubspec.yaml 才需要 commit
git add app/pubspec.yaml
git commit -m "chore: ensure http dependency exists for horoscope" 2>/dev/null || true
```

---

## Task 2: 创建数据模型

**Files:**
- Create: `app/lib/tools/horoscope/models/zodiac_sign.dart`
- Create: `app/lib/tools/horoscope/models/horoscope_data.dart`

- [ ] **Step 1: 编写 zodiac_sign.dart**

```dart
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
```

- [ ] **Step 2: 编写 horoscope_data.dart**

```dart
/// 运势数据
class HoroscopeData {
  final String type;            // 'today', 'week'
  final int overallScore;       // 综合指数 0-100
  final String overallDesc;     // 综合描述

  final int loveScore;          // 爱情指数
  final String loveDesc;        // 爱情描述

  final int careerScore;        // 事业指数
  final String careerDesc;      // 事业描述

  final int wealthScore;        // 财运指数
  final String wealthDesc;      // 财运描述

  final int healthScore;        // 健康指数
  final String healthDesc;      // 健康描述

  HoroscopeData({
    required this.type,
    required this.overallScore,
    required this.overallDesc,
    required this.loveScore,
    required this.loveDesc,
    required this.careerScore,
    required this.careerDesc,
    required this.wealthScore,
    required this.wealthDesc,
    required this.healthScore,
    required this.healthDesc,
  });

  /// 根据分数获取颜色
  static Color getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.amber;
    return Colors.red;
  }

  /// 获取渐变颜色
  static List<Color> getGradientColors(int score) {
    if (score >= 80) {
      return [Colors.green.shade400, Colors.green.shade700];
    }
    if (score >= 60) {
      return [Colors.orange.shade400, Colors.orange.shade700];
    }
    if (score >= 40) {
      return [Colors.amber.shade400, Colors.amber.shade700];
    }
    return [Colors.red.shade400, Colors.red.shade700];
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/horoscope/models/zodiac_sign.dart
git add app/lib/tools/horoscope/models/horoscope_data.dart
git commit -m "feat: add horoscope data models (ZodiacSign, HoroscopeData)"
```

---

## Task 3: 创建 HoroscopeService（API + 本地生成）

**Files:**
- Create: `app/lib/tools/horoscope/horoscope_service.dart`

- [ ] **Step 1: 编写 horoscope_service.dart**

```dart
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
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/horoscope/horoscope_service.dart
git commit -m "feat: add HoroscopeService with local generation engine"
```

---

## Task 4: 创建 Widget 组件

**Files:**
- Create: `app/lib/tools/horoscope/widgets/zodiac_selector.dart`
- Create: `app/lib/tools/horoscope/widgets/fortune_card.dart`
- Create: `app/lib/tools/horoscope/widgets/fortune_item.dart`

- [ ] **Step 1: 编写 zodiac_selector.dart**

```dart
import 'package:flutter/material.dart';
import '../models/zodiac_sign.dart';

/// 星座选择器底部弹窗
class ZodiacSelector extends StatelessWidget {
  final Function(ZodiacSign) onSelected;

  const ZodiacSelector({
    super.key,
    required this.onSelected,
  });

  static void show(
    BuildContext context, {
    required Function(ZodiacSign) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ZodiacSelector(onSelected: onSelected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // 标题
          Text(
            '选择你的星座',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          // 星座网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: ZodiacSign.all.length,
              itemBuilder: (context, index) {
                final sign = ZodiacSign.all[index];
                return _ZodiacItem(
                  sign: sign,
                  onTap: () {
                    onSelected(sign);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个星座项
class _ZodiacItem extends StatelessWidget {
  final ZodiacSign sign;
  final VoidCallback onTap;

  const _ZodiacItem({
    required this.sign,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sign.icon,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              sign.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              sign.dateRange,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 编写 fortune_card.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/horoscope_data.dart';

/// 综合运势卡片
class FortuneCard extends StatelessWidget {
  final HoroscopeData data;

  const FortuneCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = HoroscopeData.getGradientColors(data.overallScore);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // 圆形进度条
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: data.overallScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${data.overallScore}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      '分',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // 描述
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '综合运势',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.overallDesc,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
```

- [ ] **Step 3: 编写 fortune_item.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/horoscope_data.dart';
import '../horoscope_service.dart';

/// 分项运势项
class FortuneItem extends StatelessWidget {
  final String category;
  final int score;
  final String desc;
  final int index;

  const FortuneItem({
    super.key,
    required this.category,
    required this.score,
    required this.desc,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final color = HoroscopeData.getScoreColor(score);
    final shortDesc = HoroscopeService.getShortDesc(score, category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HoroscopeService.getCategoryIcon(category),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // 名称 + 进度条
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HoroscopeService.getCategoryName(category),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // 分数
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                shortDesc,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms);
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/tools/horoscope/widgets/zodiac_selector.dart
git add app/lib/tools/horoscope/widgets/fortune_card.dart
git add app/lib/tools/horoscope/widgets/fortune_item.dart
git commit -m "feat: add horoscope widgets (selector, card, item)"
```

---

## Task 5: 创建 HoroscopeTool 入口

**Files:**
- Create: `app/lib/tools/horoscope/horoscope_tool.dart`

- [ ] **Step 1: 编写 horoscope_tool.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'horoscope_page.dart';

class HoroscopeTool implements ToolModule {
  @override
  String get id => 'horoscope';

  @override
  String get name => '星座运势';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.star;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const HoroscopePage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/horoscope/horoscope_tool.dart
git commit -m "feat: add HoroscopeTool module entry"
```

---

## Task 6: 创建主页面 HoroscopePage

**Files:**
- Create: `app/lib/tools/horoscope/horoscope_page.dart`

- [ ] **Step 1: 编写 horoscope_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'horoscope_service.dart';
import 'models/zodiac_sign.dart';
import 'models/horoscope_data.dart';
import 'widgets/zodiac_selector.dart';
import 'widgets/fortune_card.dart';
import 'widgets/fortune_item.dart';
import '../../core/services/storage_service.dart';

class HoroscopePage extends StatefulWidget {
  const HoroscopePage({super.key});

  @override
  State<HoroscopePage> createState() => _HoroscopePageState();
}

class _HoroscopePageState extends State<HoroscopePage> {
  bool _isLoading = false;
  String? _error;
  ZodiacSign? _selectedSign;
  String _currentType = 'today'; // 'today' or 'week'
  HoroscopeData? _todayData;
  HoroscopeData? _weekData;

  @override
  void initState() {
    super.initState();
    _loadDefaultZodiac();
  }

  /// 加载默认星座
  Future<void> _loadDefaultZodiac() async {
    try {
      final savedId = await StorageService.getString('horoscope_default_zodiac');
      if (savedId != null) {
        final sign = ZodiacSign.fromId(savedId);
        if (sign != null) {
          setState(() => _selectedSign = sign);
          _loadHoroscope();
          return;
        }
      }
    } catch (e) {
      debugPrint('Load default zodiac failed: $e');
    }
    // 没有默认星座，保持 null
  }

  /// 保存默认星座
  Future<void> _saveDefaultZodiac(ZodiacSign sign) async {
    try {
      await StorageService.setString('horoscope_default_zodiac', sign.id);
    } catch (e) {
      debugPrint('Save default zodiac failed: $e');
    }
  }

  /// 加载运势
  Future<void> _loadHoroscope({bool force = false}) async {
    if (_selectedSign == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 加载今日和本周
      final today = await HoroscopeService.getHoroscope(_selectedSign!, 'today');
      final week = await HoroscopeService.getHoroscope(_selectedSign!, 'week');

      if (mounted) {
        setState(() {
          _todayData = today;
          _weekData = week;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '获取运势失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 显示星座选择器
  void _showZodiacSelector() {
    ZodiacSelector.show(
      context,
      onSelected: (sign) {
        setState(() => _selectedSign = sign);
        _saveDefaultZodiac(sign);
        _loadHoroscope(force: true);
      },
    );
  }

  /// 获取当前显示的数据
  HoroscopeData? get _currentData {
    return _currentType == 'today' ? _todayData : _weekData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('星座运势'),
        actions: [
          if (_selectedSign != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : () => _loadHoroscope(force: true),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadHoroscope(force: true),
        child: _selectedSign == null
            ? _buildNoSelection()
            : _buildContent(),
      ),
    );
  }

  /// 未选择星座的占位
  Widget _buildNoSelection() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_outline,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              Text(
                '选择你的星座',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '点击下方按钮开始',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _showZodiacSelector,
                icon: const Icon(Icons.search),
                label: const Text('选择星座'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 主内容
  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 星座选择栏
            _buildZodiacBar(),
            const SizedBox(height: 20),
            // 日期切换 Tab
            _buildTypeTab(),
            const SizedBox(height: 20),
            // 加载状态
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadHoroscope(force: true),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              )
            else if (_currentData != null) ...[
              // 综合运势卡片
              FortuneCard(data: _currentData!),
              const SizedBox(height: 24),
              // 分项运势
              Text(
                '分项运势',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              FortuneItem(
                category: 'love',
                score: _currentData!.loveScore,
                desc: _currentData!.loveDesc,
                index: 0,
              ),
              FortuneItem(
                category: 'career',
                score: _currentData!.careerScore,
                desc: _currentData!.careerDesc,
                index: 1,
              ),
              FortuneItem(
                category: 'wealth',
                score: _currentData!.wealthScore,
                desc: _currentData!.wealthDesc,
                index: 2,
              ),
              FortuneItem(
                category: 'health',
                score: _currentData!.healthScore,
                desc: _currentData!.healthDesc,
                index: 3,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 星座选择栏
  Widget _buildZodiacBar() {
    return GestureDetector(
      onTap: _showZodiacSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              _selectedSign!.icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedSign!.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    _selectedSign!.dateRange,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// 日期切换 Tab
  Widget _buildTypeTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: '今日',
              isSelected: _currentType == 'today',
              onTap: () {
                setState(() => _currentType = 'today');
              },
            ),
          ),
          Expanded(
            child: _TabButton(
              title: '本周',
              isSelected: _currentType == 'week',
              onTap: () {
                setState(() => _currentType = 'week');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab 按钮
class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/horoscope/horoscope_page.dart
git commit -m "feat: add HoroscopePage main UI"
```

---

## Task 7: 注册 HoroscopeTool

**Files:**
- Modify: `app/lib/main.dart`

先让我查看一下 main.dart 的当前内容：

- [ ] **Step 1: 读取 main.dart**

```bash
cat app/lib/main.dart
```

- [ ] **Step 2: 添加导入语句**

在 main.dart 顶部 imports 区域添加：
```dart
import 'tools/horoscope/horoscope_tool.dart';
```

- [ ] **Step 3: 注册工具**

在 `ToolRegistry.registerAll` 调用处添加：
```dart
HoroscopeTool(),
```

- [ ] **Step 4: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat: register HoroscopeTool in main.dart"
```

---

## Task 8: 验证和测试

**Files:**
- All horoscope files

- [ ] **Step 1: 运行 Flutter analyze**

```bash
cd app && flutter analyze lib/tools/horoscope/
```

预期：无错误

- [ ] **Step 2: 检查文件完整性**

```bash
ls -la app/lib/tools/horoscope/
ls -la app/lib/tools/horoscope/models/
ls -la app/lib/tools/horoscope/widgets/
```

应该包含：
- horoscope/horoscope_tool.dart
- horoscope/horoscope_page.dart
- horoscope/horoscope_service.dart
- horoscope/models/zodiac_sign.dart
- horoscope/models/horoscope_data.dart
- horoscope/widgets/zodiac_selector.dart
- horoscope/widgets/fortune_card.dart
- horoscope/widgets/fortune_item.dart

- [ ] **Step 3: 确保所有 imports 正确**

检查所有文件的 imports，确保没有引用不存在的文件。

---

## 完成标准

- [ ] pubspec.yaml 确认 http 依赖存在
- [ ] 数据模型已创建（zodiac_sign.dart, horoscope_data.dart）
- [ ] HoroscopeService 已实现（本地生成 + API 预留）
- [ ] Widget 组件已创建（zodiac_selector.dart, fortune_card.dart, fortune_item.dart）
- [ ] HoroscopeTool 入口已创建
- [ ] HoroscopePage 主页面已创建
- [ ] main.dart 已注册 HoroscopeTool
- [ ] Flutter analyze 无错误

---

## 后续优化（可选，不在本计划内）

1. 接入真实的第三方星座运势 API（天行数据、聚合数据等）
2. 添加本地缓存（今日 4 小时，本周 12 小时）
3. 支持明日/本月/年度运势
4. 添加幸运色/幸运数字显示
5. 星座配对功能
6. 运势分享截图
7. 每日运势通知提醒
