// app/lib/tools/bookshelf/providers/bookshelf_provider.dart

import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/item.dart';
import '../models/tag.dart';

class BookshelfProvider extends ChangeNotifier {
  // ========== 分类状态 ==========

  List<Category> _categories = [];
  List<Category> get categories => _categories;
  Category? _selectedCategory = null;
  Category? get selectedCategory => _selectedCategory;
  bool _loadingCategories = false;
  bool get isLoadingCategories => _loadingCategories;

  void setLoadingCategories(bool loading) {
    _loadingCategories = loading;
    notifyListeners();
  }

  void setCategories(List<Category> categories) {
    _categories = categories;
    if (_categories.isNotEmpty && _selectedCategory == null) {
      _selectedCategory = _categories.first;
    }
    notifyListeners();
  }

  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void updateCategory(Category category) {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      notifyListeners();
    }
  }

  void removeCategory(int categoryId) {
    _categories.removeWhere((c) => c.id == categoryId);
    if (_selectedCategory?.id == categoryId && _categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }
    notifyListeners();
  }

  // ========== 条目状态 ==========

  List<Item> _items = [];
  List<Item> get items => _items;
  bool _loadingItems = false;
  bool get loadingItems => _loadingItems;

  void setItems(List<Item> items) {
    _items = items;
    _loadingItems = false;
    notifyListeners();
  }

  void setLoadingItems(bool loading) {
    _loadingItems = loading;
    notifyListeners();
  }

  void addItem(Item item) {
    _items.insert(0, item);
    notifyListeners();
  }

  void updateItem(Item item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  void removeItem(int itemId) {
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
  }

  // ========== 标签状态 ==========

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  void setTags(List<Tag> tags) {
    _tags = tags;
    notifyListeners();
  }

  void addTag(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }
}
