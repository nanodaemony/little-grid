import 'dart:math';

class HealthTips {
  static const List<String> tips = [
    '🥤 你看看你现在多少斤了，还在喝？',
    '☕ 今天的咖啡因摄入已超标，小心失眠哦',
    '🧋 奶茶虽好，可不要贪杯哦',
    '🍬 这杯糖的甜度，够你跑3公里了',
    '💪 放下饮料，拿起水杯，你可以的！',
    '🦷 想想你的牙齿，它们正在哭泣',
    '💰 这杯奶茶钱，够买两斤水果了',
    '🏃‍♀️ 喝前想一想，今天的运动白做了吗？',
    '🍎 不如来杯鲜榨果汁？',
    '😴 糖分会让你更疲惫，真的需要吗？',
    '🌊 多喝水，皮肤会更好哦',
    '🎯 小目标：今天只喝一杯！',
  ];

  static final Random _random = Random();

  static String getRandomTip() {
    return tips[_random.nextInt(tips.length)];
  }
}
