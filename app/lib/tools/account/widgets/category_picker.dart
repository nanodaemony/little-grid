// app/lib/tools/account/widgets/category_picker.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/category.dart';
import '../models/record.dart';
import '../services/account_service.dart';

class CategoryPicker extends StatefulWidget {
  final RecordType type;
  final Category? selectedCategory;
  final Category? selectedSubCategory;

  const CategoryPicker({
    super.key,
    required this.type,
    this.selectedCategory,
    this.selectedSubCategory,
  });

  @override
  State<CategoryPicker> createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Category> _subCategories = [];
  Category? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedSubCategory = widget.selectedSubCategory;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await AccountService.getCategories(widget.type);
    setState(() => _categories = categories);

    if (_selectedCategory != null) {
      _loadSubCategories(_selectedCategory!);
    }
  }

  Future<void> _loadSubCategories(Category category) async {
    final subCategories = await AccountService.getSubCategories(category.id!);
    setState(() {
      _subCategories = subCategories;
      if (_subCategories.isEmpty) {
        // No subcategories, select this category directly
        _confirmSelection();
      }
    });
  }

  void _selectCategory(Category category) {
    if (_selectedCategory?.id == category.id) return;

    setState(() {
      _selectedCategory = category;
      _selectedSubCategory = null;
      _subCategories = [];
    });
    _loadSubCategories(category);
  }

  void _selectSubCategory(Category subCategory) {
    setState(() => _selectedSubCategory = subCategory);
    _confirmSelection();
  }

  void _confirmSelection() {
    Navigator.pop(context, {
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                // Primary categories
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.grey.shade50,
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory?.id == category.id;
                        return _CategoryItem(
                          category: category,
                          isSelected: isSelected,
                          onTap: () => _selectCategory(category),
                        );
                      },
                    ),
                  ),
                ),
                // Secondary categories
                Expanded(
                  flex: 3,
                  child: _subCategories.isEmpty
                      ? Center(
                          child: Text(
                            '该分类暂无子分类',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _subCategories.length,
                          itemBuilder: (context, index) {
                            final sub = _subCategories[index];
                            final isSelected = _selectedSubCategory?.id == sub.id;
                            return _SubCategoryItem(
                              category: sub,
                              isSelected: isSelected,
                              onTap: () => _selectSubCategory(sub),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text(
            '选择分类',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubCategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
