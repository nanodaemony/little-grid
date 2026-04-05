import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'account_page.dart';
import 'services/account_service.dart';

class AccountTool implements ToolModule {
  @override
  String get id => 'account';

  @override
  String get name => '账本';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.account_balance_wallet;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const AccountPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {
    await AccountService.initPresetCategories();
  }

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
