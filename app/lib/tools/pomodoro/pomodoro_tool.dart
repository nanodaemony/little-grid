import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'pomodoro_page.dart';

class PomodoroTool implements ToolModule {
  @override
  String get id => 'pomodoro';

  @override
  String get name => '番茄钟';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.timer;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const PomodoroPage();
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