import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'pages/drink_plan_page.dart';

class DrinkPlanTool implements ToolModule {
  @override
  String get id => 'drink_plan';

  @override
  String get name => '奶茶计划';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.local_drink;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const DrinkPlanPage();
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
