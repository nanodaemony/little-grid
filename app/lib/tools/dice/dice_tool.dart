import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'dice_page.dart';

class DiceTool implements ToolModule {
  @override
  String get id => 'dice';

  @override
  String get name => '骰子';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.casino;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const DicePage();
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
