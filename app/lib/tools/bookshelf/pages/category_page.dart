// app/lib/tools/bookshelf/pages/category_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:littlegrid/core/services/usage_service.dart';
import '../models/category.dart';
import '../services/bookshelf_api.dart';

class CategoryPage extends StatefulWidget {
  final List<Category> initialCategories;
  final ValueChanged<List<Category>> onCategoriesUpdated;

  const CategoryPage({
    super.key,
    required this.initialCategories,
    required this.onCategoriesUpdated,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Category> _categories;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('bookshelf_category');
    _categories = List.from(widget.initialCategories);
  }

  @override
  void dispose() {
    UsageService.recordExit('bookshelf_category');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: _saveAndExit,
            tooltip: '保存',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无分类',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _addCategory,
              child: const Text('添加第一个分类'),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      itemCount: _categories.length,
      onReorder: _onReorder,
      itemBuilder: (context, index) {
        return _buildCategoryItem(context, index);
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, int index) {
    final category = _categories[index];

    return Container(
      key: ValueKey(category.id),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          title: Text(category.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editCategory(index),
                tooltip: '编辑',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCategory(index),
                tooltip: '删除',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _categories.removeAt(oldIndex);
      _categories.insert(newIndex, item);

      // 更新排序值
      for (var i = 0; i < _categories.length; i++) {
        _categories[i] = _categories[i].copyWith(sort: i);
      }
    });
  }

  void _addCategory() {
    _showCategoryDialog();
  }

  void _editCategory(int index) {
    _showCategoryDialog(category: _categories[index]);
  }

  void _showCategoryDialog({Category? category}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final isEditing = category != null;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? '编辑分类' : '添加分类'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '分类名称',
            hintText: '例如：电影、书籍、游戏',
            border: OutlineInputBorder(),
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入分类名称')),
                );
                return;
              }

              Navigator.pop(dialogContext);

              if (isEditing) {
                await _updateCategory(category!, name);
              } else {
                await _createCategory(name);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCategory(String name) async {
    setState(() => _isLoading = true);

    try {
      final newCategory = await BookshelfApi.createCategory(
        name,
        sort: _categories.length,
      );
      setState(() {
        _categories.add(newCategory);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    }
  }

  Future<void> _updateCategory(Category category, String name) async {
    setState(() => _isLoading = true);

    try {
      final updated = await BookshelfApi.updateCategory(
        category.id,
        name,
        sort: category.sort,
      );

      setState(() {
        final index = _categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          _categories[index] = updated;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    }
  }

  void _deleteCategory(int index) {
    final category = _categories[index];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除分类"${category.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performDelete(category, index);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Category category, int index) async {
    setState(() => _isLoading = true);

    try {
      await BookshelfApi.deleteCategory(category.id);
      setState(() {
        _categories.removeAt(index);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  void _saveAndExit() {
    widget.onCategoriesUpdated(_categories);
    Navigator.pop(context);
  }
}
