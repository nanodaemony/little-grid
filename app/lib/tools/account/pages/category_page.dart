// app/lib/tools/account/pages/category_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/category.dart';
import '../models/record.dart';
import '../services/account_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  RecordType _type = RecordType.expense;
  List<Category> _categories = [];
  Map<int, List<Category>> _subCategories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final categories = await AccountService.getCategories(_type);
    final subCategories = <int, List<Category>>{};

    for (final cat in categories) {
      if (cat.id != null) {
        final subs = await AccountService.getSubCategories(cat.id!);
        subCategories[cat.id!] = subs;
      }
    }

    setState(() {
      _categories = categories;
      _subCategories = subCategories;
      _isLoading = false;
    });
  }

  void _switchType(RecordType type) {
    setState(() => _type = type);
    _loadData();
  }

  Future<void> _addCategory() async {
    final result = await _showCategoryDialog();
    if (result != null) {
      final category = Category(
        name: result['name'] as String,
        icon: result['icon'] as String,
        type: _type,
        parentId: result['parentId'] as int? ?? 0,
      );
      await AccountService.insertCategory(category);
      _loadData();
    }
  }

  Future<void> _editCategory(Category category) async {
    if (category.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预设分类不可编辑')),
      );
      return;
    }

    final result = await _showCategoryDialog(category: category);
    if (result != null) {
      final updated = category.copyWith(
        name: result['name'] as String,
        icon: result['icon'] as String,
      );
      await AccountService.updateCategory(updated);
      _loadData();
    }
  }

  Future<void> _hideCategory(Category category) async {
    if (!category.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('只能隐藏预设分类')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐藏分类'),
        content: Text('确定要隐藏 "${category.name}" 吗？隐藏后该分类将不再显示，但已有记录会保留。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('隐藏'),
          ),
        ],
      ),
    );

    if (confirm == true && category.id != null) {
      await AccountService.hideCategory(category.id!);
      _loadData();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    if (category.isPreset) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('预设分类不能删除')),
      );
      return;
    }

    if (category.id == null) return;

    // Check if category has records
    final recordCount = await AccountService.getRecordCountByCategory(category.id!);

    if (recordCount > 0) {
      final choice = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('分类有关联记录'),
          content: Text('"${category.name}" 下有 $recordCount 条记录。请选择处理方式：'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'cancel'),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'move'),
              child: const Text('移至"其他"'),
            ),
          ],
        ),
      );

      if (choice == 'move') {
        // Find "其他" category
        final otherCategory = _categories.firstWhere(
          (c) => c.name == '其他',
          orElse: () => category,
        );
        if (otherCategory.id != null) {
          await AccountService.updateRecordsCategory(category.id!, otherCategory.id!);
          await AccountService.deleteCategory(category.id!);
          _loadData();
        }
      }
    } else {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除 "${category.name}" 吗？'),
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
        await AccountService.deleteCategory(category.id!);
        _loadData();
      }
    }
  }

  Future<Map<String, dynamic>?> _showCategoryDialog({Category? category}) async {
    final nameController = TextEditingController(text: category?.name);
    final iconController = TextEditingController(text: category?.icon ?? '📝');
    int? parentId = category?.parentId ?? 0;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? '添加分类' : '编辑分类'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: '图标 (Emoji)',
                  hintText: '📝',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  hintText: '输入分类名称',
                ),
              ),
              if (category == null) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  value: parentId == 0 ? null : parentId,
                  decoration: const InputDecoration(labelText: '上级分类'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('一级分类'),
                    ),
                    ..._categories.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.icon} ${c.name}'),
                    )),
                  ],
                  onChanged: (value) => parentId = value ?? 0,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'icon': iconController.text.isEmpty ? '📝' : iconController.text,
                  'parentId': parentId,
                });
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类管理'),
        actions: [
          TextButton(
            onPressed: _addCategory,
            child: const Text('添加', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeToggle(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final subs = _subCategories[category.id] ?? [];
                          return _buildCategoryItem(category, subs);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: '支出',
                isSelected: _type == RecordType.expense,
                color: AppColors.error,
                onTap: () => _switchType(RecordType.expense),
              ),
            ),
            Expanded(
              child: _TypeButton(
                label: '收入',
                isSelected: _type == RecordType.income,
                color: AppColors.success,
                onTap: () => _switchType(RecordType.income),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            '暂无分类',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category, List<Category> subs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
        title: Text(category.name),
        subtitle: category.isPreset
            ? const Text('预设', style: TextStyle(fontSize: 12, color: Colors.grey))
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editCategory(category);
                break;
              case 'hide':
                _hideCategory(category);
                break;
              case 'delete':
                _deleteCategory(category);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!category.isPreset)
              const PopupMenuItem(value: 'edit', child: Text('编辑')),
            if (category.isPreset)
              const PopupMenuItem(value: 'hide', child: Text('隐藏')),
            if (!category.isPreset)
              const PopupMenuItem(
                value: 'delete',
                child: Text('删除', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        children: subs.map((sub) => _buildSubCategoryItem(sub)).toList(),
      ),
    );
  }

  Widget _buildSubCategoryItem(Category sub) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      leading: Text(sub.icon, style: const TextStyle(fontSize: 20)),
      title: Text(sub.name, style: const TextStyle(fontSize: 14)),
      dense: true,
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
