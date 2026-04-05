import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'coin_page.dart';

class CoinTool implements ToolModule {
  @override
  String get id => 'coin';

  @override
  String get name => '投硬币';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.monetization_on;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const CoinPage();
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
