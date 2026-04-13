# 新工具模块模板

## 文件结构

```
app/lib/tools/xxx/
├── xxx_tool.dart      # 必须 - 工具注册
├── xxx_page.dart      # 必须 - 主页面
├── xxx_models.dart    # 可选 - 数据模型
└── xxx_service.dart   # 可选 - 业务逻辑
```

## xxx_tool.dart

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'xxx_page.dart';

class XxxTool implements ToolModule {
  @override
  String get id => 'xxx';

  @override
  String get name => '工具名称';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.extension;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) => const XxxPage();

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
```

## 注册到 main.dart

```dart
import 'tools/xxx/xxx_tool.dart';

void main() {
  ToolRegistry.register(XxxTool());
  // ...
}
```
