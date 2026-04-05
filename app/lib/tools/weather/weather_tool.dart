import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'weather_page.dart';

class WeatherTool implements ToolModule {
  @override
  String get id => 'weather';

  @override
  String get name => '天气';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.wb_sunny;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const WeatherPage();
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
