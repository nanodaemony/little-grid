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
