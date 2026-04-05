import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'calculator_page.dart';

class CalculatorTool implements ToolModule {
  @override
  String get id => 'calculator';

  @override
  String get name => '科学计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.calculate;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const CalculatorPage();
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
