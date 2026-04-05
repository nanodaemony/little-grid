// app/lib/tools/bookshelf/bookshelf_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/usage_service.dart';
import 'models/category.dart';
import 'models/item.dart';
import 'models/tag.dart';
import 'providers/bookshelf_provider.dart';
import 'widgets/category_tab.dart';
import 'widgets/item_card.dart';
import 'pages/category_page.dart';
import 'pages/item_detail_page.dart';
import 'pages/add_item_dialog.dart';
import 'services/bookshelf_api.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('bookshelf');
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<BookshelfProvider>();
    try {
      provider.setLoadingCategories(true);
      provider.setLoadingItems(true);

      final categories = await BookshelfApi.getCategories();
      provider.setCategories(categories);

      // 初始化默认分类
      if (categories.isNotEmpty) {
        provider.selectCategory(categories.first);
        await _loadItems(categories.first.id);
      }

      final tags = await BookshelfApi.getTags();
      provider.setTags(tags);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    } finally {
      provider.setLoadingCategories(false);
      provider.setLoadingItems(false);
    }
  }

  Future<void> _loadItems(int categoryId) async {
    final provider = context.read<BookshelfProvider>();
    provider.setLoadingItems(true);
    try {
      final items = await BookshelfApi.getItems(categoryId: categoryId);
      provider.setItems(items);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载条目失败: $e')),
        );
      }
    } finally {
      provider.setLoadingItems(false);
    }
  }

  @override
  void dispose() {
    UsageService.recordExit('bookshelf');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookshelfProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('书架'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _showSearchDialog(provider),
                tooltip: '搜索',
              ),
            ],
          ),
          body: Column(
            children: [
              // 分类标签栏
              CategoryTab(
                categories: provider.categories,
                selectedCategory: provider.selectedCategory,
                onCategorySelected: (category) {
                  provider.selectCategory(category);
                  _loadItems(category.id);
                },
                onManageCategories: () => _showCategoryPage(provider),
                isLoading: provider.isLoadingCategories,
              ),
              const Divider(height: 1),
              // 条目列表
              Expanded(
                child: _buildItemsList(provider),
              ),
            ],
          ),
          floatingActionButton: provider.selectedCategory != null
              ? FloatingActionButton(
                  onPressed: () => _showAddItemDialog(provider),
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  Widget _buildItemsList(BookshelfProvider provider) {
    if (provider.loadingItems) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.selectedCategory == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '请先创建分类',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无条目',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _showAddItemDialog(provider),
              icon: const Icon(Icons.add),
              label: const Text('添加第一个条目'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (provider.selectedCategory != null) {
          await _loadItems(provider.selectedCategory!.id);
        }
      },
      child: ListView.builder(
        itemCount: provider.items.length,
        itemBuilder: (context, index) {
          final item = provider.items[index];
          return ItemCard(
            item: item,
            onTap: () => _showItemDetailPage(provider, item),
            onEdit: () => _showItemDetailPage(provider, item),
            onDelete: () => _deleteItem(provider, item),
          );
        },
      ),
    );
  }

  void _showCategoryPage(BookshelfProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryPage(
          initialCategories: provider.categories,
          onCategoriesUpdated: (categories) {
            provider.setCategories(categories);
            // 如果当前选中的分类不在新列表中，选第一个
            if (provider.selectedCategory != null &&
                !categories.any((c) => c.id == provider.selectedCategory!.id)) {
              if (categories.isNotEmpty) {
                provider.selectCategory(categories.first);
                _loadItems(categories.first.id);
              }
            }
          },
        ),
      ),
    );
  }

  void _showAddItemDialog(BookshelfProvider provider) {
    if (provider.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择分类')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddItemDialog(
        category: provider.selectedCategory!,
        onItemAdded: (item) {
          provider.addItem(item);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('添加成功'),
              action: SnackBarAction(
                label: '继续编辑',
                onPressed: () {
                  Navigator.pop(context);
                  _showItemDetailPage(provider, item);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showItemDetailPage(BookshelfProvider provider, Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailPage(
          item: item,
          category: provider.selectedCategory,
          categories: provider.categories,
          tags: provider.tags,
          onItemSaved: (savedItem) {
            if (savedItem == null) {
              // 删除
              provider.removeItem(item.id);
            } else {
              // 更新
              provider.updateItem(savedItem);
            }
          },
        ),
      ),
    );
  }

  Future<void> _deleteItem(BookshelfProvider provider, Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${item.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await BookshelfApi.deleteItem(item.id);
      provider.removeItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  void _showSearchDialog(BookshelfProvider provider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('搜索'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入标题、作者搜索...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            Navigator.pop(dialogContext);
            _performSearch(value, provider);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _performSearch(controller.text, provider);
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String query, BookshelfProvider provider) async {
    if (query.trim().isEmpty) return;

    try {
      // 过滤当前列表
      final filtered = provider.items
          .where((item) =>
              item.title.toLowerCase().contains(query.toLowerCase()) ||
              (item.author?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();

      if (mounted) {
        setState(() {
          provider.setItems(filtered);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('找到 ${filtered.length} 个结果'),
            action: SnackBarAction(
              label: '恢复',
              onPressed: () {
                if (provider.selectedCategory != null) {
                  _loadItems(provider.selectedCategory!.id);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索失败: $e')),
        );
      }
    }
  }
}
