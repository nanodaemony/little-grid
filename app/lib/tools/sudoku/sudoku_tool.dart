import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'sudoku_page.dart';

class SudokuTool implements ToolModule {
  @override
  String get id => 'sudoku';

  @override
  String get name => '数独';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.grid_3x3;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const SudokuPage();
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