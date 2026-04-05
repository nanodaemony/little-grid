import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'gomoku_page.dart';

class GomokuTool implements ToolModule {
  @override
  String get id => 'gomoku';

  @override
  String get name => '五子棋';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.grid_on;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const GomokuPage();
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