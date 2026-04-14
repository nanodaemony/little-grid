import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'maze_page.dart';

class MazeTool implements ToolModule {
  @override
  String get id => 'maze';

  @override
  String get name => '迷宫';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.route;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const MazePage();
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
