import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'todo_page.dart';

class TodoTool implements ToolModule {
  @override
  String get id => 'todo';

  @override
  String get name => '待办清单';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.check_circle;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const TodoPage();
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
