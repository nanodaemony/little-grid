import 'package:flutter/material.dart';
import '../core/models/tool_config.dart';
import '../core/services/storage_service.dart';
import '../core/services/tool_registry.dart';
import '../core/utils/logger.dart';

class AppProvider extends ChangeNotifier {
  List<ToolConfig> _toolConfigs = [];
  bool _isLoading = true;
  String? _avatarPath;

  List<ToolConfig> get toolConfigs => _toolConfigs;
  bool get isLoading => _isLoading;
  String? get avatarPath => _avatarPath;

  /// 初始化
  Future<void> init() async {
    await initTools();
    await loadAvatar();
  }

  /// 初始化工具配置
  Future<void> initTools() async {
    _isLoading = true;
    notifyListeners();

    try {
      var configs = await StorageService.getToolConfigs();

      // 如果没有配置，创建默认配置
      if (configs.isEmpty) {
        configs = _createDefaultConfigs();
        await StorageService.saveToolConfigs(configs);
      } else {
        // 检查是否有新工具需要添加
        final existingIds = configs.map((c) => c.id).toSet();
        final allTools = ToolRegistry.getAll();
        final newTools = allTools.where((t) => !existingIds.contains(t.id));

        if (newTools.isNotEmpty) {
          for (final tool in newTools) {
            configs.add(ToolConfig(
              id: tool.id,
              name: tool.name,
              category: tool.category.name,
              sortOrder: 0,
              gridSize: tool.gridSize,
            ));
          }
          await StorageService.saveToolConfigs(configs);
        }
      }

      _toolConfigs = configs;
    } catch (e, stack) {
      AppLogger.e('Failed to init tools', e, stack);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 加载头像路径
  Future<void> loadAvatar() async {
    try {
      _avatarPath = await StorageService.getAvatarPath();
      notifyListeners();
    } catch (e, stack) {
      AppLogger.e('Failed to load avatar', e, stack);
    }
  }

  /// 更新头像
  Future<void> updateAvatar(String path) async {
    try {
      await StorageService.saveAvatarPath(path);
      _avatarPath = path;
      notifyListeners();
    } catch (e, stack) {
      AppLogger.e('Failed to update avatar', e, stack);
    }
  }

  /// 记录工具使用
  Future<void> recordToolUse(String toolId) async {
    await StorageService.updateToolUsage(toolId);
    await initTools(); // 刷新配置
  }

  /// 切换置顶状态
  Future<void> togglePin(String toolId) async {
    final config = _toolConfigs.firstWhere((c) => c.id == toolId);
    await StorageService.togglePin(toolId, !config.isPinned);
    await initTools();
  }

  /// 获取排序后的工具
  List<ToolConfig> getSortedTools() {
    final sorted = List<ToolConfig>.from(_toolConfigs);

    // 按置顶和最后使用时间排序
    sorted.sort((a, b) {
      // 置顶优先
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // 然后按最后使用时间
      if (a.lastUsedAt != null && b.lastUsedAt != null) {
        return b.lastUsedAt!.compareTo(a.lastUsedAt!);
      }
      if (a.lastUsedAt != null) return -1;
      if (b.lastUsedAt != null) return 1;

      return a.sortOrder.compareTo(b.sortOrder);
    });

    return sorted;
  }

  /// 创建默认配置
  List<ToolConfig> _createDefaultConfigs() {
    final tools = ToolRegistry.getAll();
    return tools.map((tool) => ToolConfig(
      id: tool.id,
      name: tool.name,
      category: tool.category.name,
      sortOrder: 0,
      gridSize: tool.gridSize,
    )).toList();
  }
}
