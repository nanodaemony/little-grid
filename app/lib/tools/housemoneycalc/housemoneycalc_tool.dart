import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'housemoneycalc_page.dart';

class HouseMoneyCalcTool implements ToolModule {
  @override
  String get id => 'housemoneycalc';

  @override
  String get name => '房贷计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.home_work;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const HouseMoneyCalcPage();
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
