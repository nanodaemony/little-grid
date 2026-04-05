// app/lib/tools/big_wheel/pages/collection_list_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/wheel_collection.dart';
import '../services/big_wheel_service.dart';
import 'collection_edit_page.dart';
import 'option_list_page.dart';

class CollectionListPage extends StatefulWidget {
  const CollectionListPage({super.key});

  @override
  State<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  List<WheelCollection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    try {
      final collections = await BigWheelService.getCollections();
      setState(() {
        _collections = collections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  Future<void> _navigateToEdit(WheelCollection? collection) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CollectionEditPage(collection: collection),
      ),
    );
    if (result == true) {
      _loadCollections();
    }
  }

  Future<void> _navigateToOptions(WheelCollection collection) async {
    if (collection.id == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OptionListPage(collection: collection),
      ),
    );
    _loadCollections();
  }

  Future<void> _deleteCollection(WheelCollection collection) async {
    if (collection.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预设集合不能删除')),
      );
      return;
    }

    if (collection.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${collection.name}" 吗？此操作将同时删除该集合下的所有选项。'),
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
        await BigWheelService.deleteCollection(collection.id!);
        _loadCollections();
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

    final item = _collections.removeAt(oldIndex);
    _collections.insert(newIndex, item);

    setState(() {});

    try {
      await BigWheelService.updateSortOrder(_collections);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('排序更新失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('集合管理'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collections.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _collections.length,
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
                    final collection = _collections[index];
                    return _buildCollectionItem(collection, index);
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
            Icons.folder_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无集合',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            '点击 + 添加一个集合',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionItem(WheelCollection collection, int index) {
    return Dismissible(
      key: ValueKey(collection.id ?? index),
      direction: collection.isPreset
          ? DismissDirection.none
          : DismissDirection.endToStart,
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
      onDismissed: (_) => _deleteCollection(collection),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                collection.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            collection.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: collection.isPreset
              ? const Text(
                  '预设',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _navigateToOptions(collection),
                tooltip: '管理选项',
              ),
              const Icon(Icons.drag_handle, color: Colors.grey),
            ],
          ),
          onTap: () => _navigateToEdit(collection),
        ),
      ),
    );
  }
}
