import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'bmi_page.dart';

class BMITool implements ToolModule {
  @override
  String get id => 'bmi';

  @override
  String get name => 'BMI计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.monitor_weight;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const BMIPage();
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