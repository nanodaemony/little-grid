import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'salary_calculator_page.dart';

class SalaryCalculatorTool implements ToolModule {
  @override
  String get id => 'salary_calculator';

  @override
  String get name => '工资计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.payment;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const SalaryCalculatorPage();
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
