import 'package:flutter/material.dart';

/// 工具分类
enum ToolCategory {
  life,   // 生活实用
  game,   // 趣味随机
  calc,   // 计算工具
}

/// 工具设置接口
abstract class ToolSettings {
  String get title;
  Widget buildSettingsPage();
  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
}

/// 工具模块接口 - 每个工具必须实现
abstract class ToolModule {
  /// 唯一标识（如：coin, dice, todo）
  String get id;

  /// 显示名称（如：投硬币）
  String get name;

  /// 版本号（如：1.0.0）
  String get version;

  /// 图标
  IconData get icon;

  /// 分类
  ToolCategory get category;

  /// 格子大小（1=小，2=大）
  int get gridSize;

  /// 构建工具页面
  Widget buildPage(BuildContext context);

  /// 可选：工具设置页面
  ToolSettings? get settings;

  /// 初始化时调用
  Future<void> onInit() async {}

  /// 销毁时调用
  Future<void> onDispose() async {}

  /// 进入工具时调用
  void onEnter() {}

  /// 退出工具时调用
  void onExit() {}
}

/// 工具注册表 - 管理所有工具
class ToolRegistry {
  static final Map<String, ToolModule> _tools = {};

  /// 注册工具
  static void register(ToolModule tool) {
    _tools[tool.id] = tool;
    tool.onInit();
    debugPrint('Tool registered: ${tool.id}');
  }

  /// 批量注册工具
  static void registerAll(List<ToolModule> tools) {
    for (final tool in tools) {
      register(tool);
    }
  }

  /// 获取工具
  static ToolModule? get(String id) => _tools[id];

  /// 获取所有工具
  static List<ToolModule> getAll() => _tools.values.toList();

  /// 获取指定分类的工具
  static List<ToolModule> getByCategory(ToolCategory category) {
    return _tools.values
        .where((tool) => tool.category == category)
        .toList();
  }

  /// 注销工具
  static Future<void> unregister(String id) async {
    final tool = _tools[id];
    if (tool != null) {
      await tool.onDispose();
      _tools.remove(id);
    }
  }

  /// 清空所有工具
  static Future<void> clear() async {
    for (final tool in _tools.values) {
      await tool.onDispose();
    }
    _tools.clear();
  }
}
