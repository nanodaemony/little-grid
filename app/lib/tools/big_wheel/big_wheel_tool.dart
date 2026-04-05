import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'big_wheel_page.dart';
import 'services/big_wheel_service.dart';

class BigWheelTool implements ToolModule {
  @override
  String get id => 'big_wheel';

  @override
  String get name => '大转盘';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.rotate_right;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const BigWheelPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {
    await BigWheelService.initPresetCollections();
  }

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
