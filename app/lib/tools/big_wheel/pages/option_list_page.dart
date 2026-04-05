// app/lib/tools/big_wheel/pages/option_list_page.dart

import 'package:flutter/material.dart';
import '../models/wheel_collection.dart';
import '../models/wheel_option.dart';
import '../services/big_wheel_service.dart';
import 'option_edit_page.dart';

class OptionListPage extends StatefulWidget {
  final WheelCollection collection;

  const OptionListPage({super.key, required this.collection});

  @override
  State<OptionListPage> createState() => _OptionListPageState();
}

class _OptionListPageState extends State<OptionListPage> {
  List<WheelOption> _options = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() => _isLoading = true);
    try {
      final options = await BigWheelService.getOptions(widget.collection.id!);
      setState(() {
        _options = options;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  Future<void> _navigateToEdit(WheelOption? option) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OptionEditPage(
          collectionId: widget.collection.id!,
          option: option,
        ),
      ),
    );
    if (result == true) {
      _loadOptions();
    }
  }

  Future<void> _deleteOption(WheelOption option) async {
    if (option.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${option.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await BigWheelService.deleteOption(option.id!);
        _loadOptions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = _options.removeAt(oldIndex);
    _options.insert(newIndex, item);

    setState(() {});

    try {
      await BigWheelService.updateOptionSortOrder(_options);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('排序更新失败: $e')),
      );
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.grey;
    }
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.collection.name} - 选项'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _options.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _options.length,
                  onReorder: _onReorder,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final option = _options[index];
                    return _buildOptionItem(option, index);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.format_list_bulleted_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无选项',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            '点击 + 添加一个选项',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(WheelOption option, int index) {
    final color = _parseColor(option.color);
    final hasCustomWeight = option.weight != 1.0;
    final hasIcon = option.icon != null && option.icon!.isNotEmpty;

    return Dismissible(
      key: ValueKey(option.id ?? index),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (_) => _deleteOption(option),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: hasIcon
                ? Center(
                    child: Text(
                      option.icon!,
                      style: const TextStyle(fontSize: 20),
                    ),
                  )
                : null,
          ),
          title: Text(
            option.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: hasCustomWeight
              ? Text(
                  '权重: ${option.weight.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _navigateToEdit(option),
                tooltip: '编辑',
              ),
              const Icon(Icons.drag_handle, color: Colors.grey),
            ],
          ),
          onTap: () => _navigateToEdit(option),
        ),
      ),
    );
  }
}
