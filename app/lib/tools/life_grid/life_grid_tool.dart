import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'life_grid_main_page.dart';
import 'services/life_grid_service.dart';

class LifeGridTool implements ToolModule {
  @override
  String get id => 'life_grid';

  @override
  String get name => '人生格子';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.calendar_view_month;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const LifeGridMainPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {
    await LifeGridService().init();
  }

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
