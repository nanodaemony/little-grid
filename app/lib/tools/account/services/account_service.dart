// app/lib/tools/account/services/account_service.dart

import '../../../core/services/database_service.dart';
import '../models/record.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/stats_models.dart';

class AccountService {
  // ========== Preset Categories Data ==========

  static final List<Category> _presetExpenseCategories = [
    // 餐饮
    Category(name: '餐饮', icon: '🍚', type: RecordType.expense, isPreset: true, sortOrder: 1),
    Category(name: '早餐', icon: '🍜', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '午餐', icon: '🍱', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '晚餐', icon: '🍲', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '饮料', icon: '☕', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '零食', icon: '🍰', type: RecordType.expense, parentId: -1, isPreset: true),
    // 交通
    Category(name: '交通', icon: '🚌', type: RecordType.expense, isPreset: true, sortOrder: 2),
    Category(name: '地铁', icon: '🚇', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '公交', icon: '🚌', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '打车', icon: '🚗', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '加油', icon: '⛽', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '停车', icon: '🅿️', type: RecordType.expense, parentId: -1, isPreset: true),
    // 购物
    Category(name: '购物', icon: '🛒', type: RecordType.expense, isPreset: true, sortOrder: 3),
    Category(name: '服饰', icon: '👔', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '鞋包', icon: '👟', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '化妆品', icon: '💄', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '日用品', icon: '🏠', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '数码', icon: '📱', type: RecordType.expense, parentId: -1, isPreset: true),
    // 居住
    Category(name: '居住', icon: '🏠', type: RecordType.expense, isPreset: true, sortOrder: 4),
    Category(name: '房租', icon: '💰', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '水电', icon: '💡', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '燃气', icon: '🔥', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '网费', icon: '📶', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '维修', icon: '🔧', type: RecordType.expense, parentId: -1, isPreset: true),
    // 娱乐
    Category(name: '娱乐', icon: '🎮', type: RecordType.expense, isPreset: true, sortOrder: 5),
    Category(name: '电影', icon: '🎬', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '游戏', icon: '🎮', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: 'KTV', icon: '🎤', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '书籍', icon: '📚', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '旅游', icon: '✈️', type: RecordType.expense, parentId: -1, isPreset: true),
    // 医疗
    Category(name: '医疗', icon: '🏥', type: RecordType.expense, isPreset: true, sortOrder: 6),
    Category(name: '药品', icon: '💊', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '门诊', icon: '🏥', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '牙科', icon: '🦷', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '眼镜', icon: '👓', type: RecordType.expense, parentId: -1, isPreset: true),
    // 教育
    Category(name: '教育', icon: '📚', type: RecordType.expense, isPreset: true, sortOrder: 7),
    Category(name: '培训', icon: '📖', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '书籍', icon: '📕', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '学费', icon: '🎓', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '兴趣班', icon: '🎹', type: RecordType.expense, parentId: -1, isPreset: true),
    // 宠物
    Category(name: '宠物', icon: '🐾', type: RecordType.expense, isPreset: true, sortOrder: 8),
    Category(name: '猫粮', icon: '🐱', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '猫砂', icon: '🐾', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '狗粮', icon: '🐶', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '疫苗', icon: '💉', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '宠物医疗', icon: '🏥', type: RecordType.expense, parentId: -1, isPreset: true),
    // 人情
    Category(name: '人情', icon: '💝', type: RecordType.expense, isPreset: true, sortOrder: 9),
    Category(name: '礼物', icon: '🎁', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '红包', icon: '💒', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '生日', icon: '🎂', type: RecordType.expense, parentId: -1, isPreset: true),
    Category(name: '婚庆', icon: '💍', type: RecordType.expense, parentId: -1, isPreset: true),
    // 其他
    Category(name: '其他', icon: '💳', type: RecordType.expense, isPreset: true, sortOrder: 10),
    Category(name: '其他支出', icon: '📝', type: RecordType.expense, parentId: -1, isPreset: true),
  ];

  static final List<Category> _presetIncomeCategories = [
    // 工资
    Category(name: '工资', icon: '💵', type: RecordType.income, isPreset: true, sortOrder: 1),
    Category(name: '基本工资', icon: '💰', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '奖金', icon: '🎁', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '加班费', icon: '📈', type: RecordType.income, parentId: -1, isPreset: true),
    // 兼职
    Category(name: '兼职', icon: '💼', type: RecordType.income, isPreset: true, sortOrder: 2),
    Category(name: '自由职业', icon: '💻', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '兼职收入', icon: '📝', type: RecordType.income, parentId: -1, isPreset: true),
    // 理财
    Category(name: '理财', icon: '📈', type: RecordType.income, isPreset: true, sortOrder: 3),
    Category(name: '股票', icon: '📊', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '基金', icon: '💰', type: RecordType.income, parentId: -1, isPreset: true),
    Category(name: '利息', icon: '🏦', type: RecordType.income, parentId: -1, isPreset: true),
    // 其他
    Category(name: '其他', icon: '🎁', type: RecordType.income, isPreset: true, sortOrder: 4),
    Category(name: '其他收入', icon: '📝', type: RecordType.income, parentId: -1, isPreset: true),
  ];

  /// Initialize preset categories (called once on first run)
  static Future<void> initPresetCategories() async {
    final db = await DatabaseService.database;
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM account_categories');
    final existingCount = (count.first['count'] as int);

    if (existingCount > 0) return;

    // Insert expense categories
    int? lastParentId;
    for (final category in _presetExpenseCategories) {
      final catToInsert = category.parentId == -1 && lastParentId != null
          ? category.copyWith(parentId: lastParentId)
          : category;
      final id = await db.insert('account_categories', catToInsert.toMap());
      if (category.parentId == 0) {
        lastParentId = id;
      }
    }

    // Insert income categories
    lastParentId = null;
    for (final category in _presetIncomeCategories) {
      final catToInsert = category.parentId == -1 && lastParentId != null
          ? category.copyWith(parentId: lastParentId)
          : category;
      final id = await db.insert('account_categories', catToInsert.toMap());
      if (category.parentId == 0) {
        lastParentId = id;
      }
    }
  }

  // ========== Record Operations ==========

  static Future<int> insertRecord(Record record) async {
    final db = await DatabaseService.database;
    return await db.insert('account_records', record.toMap());
  }

  static Future<int> updateRecord(Record record) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_records',
      record.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  static Future<int> deleteRecord(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'account_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Record>> getRecords({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    int? limit,
  }) async {
    final db = await DatabaseService.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }
    if (categoryId != null) {
      whereClauses.add('(category_id = ? OR sub_category_id = ?)');
      whereArgs.addAll([categoryId, categoryId]);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'account_records',
      where: whereClauses.isEmpty ? null : whereClauses.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );

    return maps.map((map) => Record.fromMap(map)).toList();
  }

  static Future<Record?> getRecordById(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'account_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Record.fromMap(maps.first);
  }

  static Future<int> updateRecordsCategory(int oldCategoryId, int newCategoryId) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_records',
      {'category_id': newCategoryId, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'category_id = ?',
      whereArgs: [oldCategoryId],
    );
  }

  static Future<int> getRecordCountByCategory(int categoryId) async {
    final db = await DatabaseService.database;
    final count = await db.rawQuery(
      'SELECT COUNT(*) as count FROM account_records WHERE category_id = ? OR sub_category_id = ?',
      [categoryId, categoryId],
    );
    return (count.first['count'] as int);
  }

  // ========== Statistics ==========

  static Future<MonthlySummary> getMonthlySummary(String month) async {
    final db = await DatabaseService.database;
    final startOfMonth = DateTime.parse('$month-01');
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN type = 1 THEN amount ELSE 0 END) as expense,
        SUM(CASE WHEN type = 2 THEN amount ELSE 0 END) as income
      FROM account_records
      WHERE date >= ? AND date <= ?
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    final map = result.first;
    return MonthlySummary(
      income: (map['income'] as num?)?.toDouble() ?? 0,
      expense: (map['expense'] as num?)?.toDouble() ?? 0,
    );
  }

  static Future<List<CategoryStats>> getCategoryStats(
    String month,
    RecordType type,
  ) async {
    final db = await DatabaseService.database;
    final startOfMonth = DateTime.parse('$month-01');
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0, 23, 59, 59);
    final typeValue = type == RecordType.expense ? 1 : 2;

    final result = await db.rawQuery('''
      SELECT category_id, SUM(amount) as total
      FROM account_records
      WHERE type = ? AND date >= ? AND date <= ?
      GROUP BY category_id
      ORDER BY total DESC
    ''', [typeValue, startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    final stats = <CategoryStats>[];
    for (final row in result) {
      final categoryId = row['category_id'] as int;
      final category = await getCategoryById(categoryId);
      if (category != null) {
        stats.add(CategoryStats(
          category: category,
          amount: (row['total'] as num).toDouble(),
        ));
      }
    }
    return stats;
  }

  static Future<List<TrendData>> getTrendData(int months) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final result = <TrendData>[];

    for (int i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthStr = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      final summary = await getMonthlySummary(monthStr);
      result.add(TrendData(
        month: monthStr,
        income: summary.income,
        expense: summary.expense,
      ));
    }

    return result;
  }

  // ========== Category Operations ==========

  static Future<List<Category>> getCategories(RecordType type) async {
    final db = await DatabaseService.database;
    final typeValue = type == RecordType.expense ? 1 : 2;

    final List<Map<String, dynamic>> maps = await db.query(
      'account_categories',
      where: 'type = ? AND parent_id = 0 AND is_hidden = 0',
      whereArgs: [typeValue],
      orderBy: 'sort_order ASC, id ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  static Future<List<Category>> getSubCategories(int parentId) async {
    final db = await DatabaseService.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'account_categories',
      where: 'parent_id = ? AND is_hidden = 0',
      whereArgs: [parentId],
      orderBy: 'id ASC',
    );

    return maps.map((map) => Category.fromMap(map)).toList();
  }

  static Future<Category?> getCategoryById(int id) async {
    final db = await DatabaseService.database;
    final maps = await db.query(
      'account_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  static Future<int> insertCategory(Category category) async {
    final db = await DatabaseService.database;
    return await db.insert('account_categories', category.toMap());
  }

  static Future<int> updateCategory(Category category) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  static Future<int> hideCategory(int id) async {
    final db = await DatabaseService.database;
    return await db.update(
      'account_categories',
      {'is_hidden': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteCategory(int id) async {
    final db = await DatabaseService.database;
    return await db.delete(
      'account_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== Budget Operations ==========

  static Future<List<BudgetWithCategory>> getBudgets(String month) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery('''
      SELECT b.*, c.name as category_name, c.icon as category_icon, c.icon_type as category_icon_type
      FROM account_budgets b
      INNER JOIN account_categories c ON b.category_id = c.id
      WHERE b.month = ?
      ORDER BY b.amount DESC
    ''', [month]);

    final budgets = <BudgetWithCategory>[];
    for (final row in result) {
      final budget = Budget.fromMap(row);
      final category = Category(
        id: budget.categoryId,
        name: row['category_name'] as String,
        icon: row['category_icon'] as String,
        iconType: row['category_icon_type'] == 1 ? IconType.emoji : IconType.asset,
        type: RecordType.expense,
      );
      final spent = await getCategorySpending(budget.categoryId, month);
      budgets.add(BudgetWithCategory(
        budget: budget,
        category: category,
        spent: spent,
      ));
    }
    return budgets;
  }

  static Future<int> setBudget(int categoryId, String month, double amount) async {
    final db = await DatabaseService.database;

    // Try to update existing
    final updated = await db.update(
      'account_budgets',
      {
        'amount': amount,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'category_id = ? AND month = ?',
      whereArgs: [categoryId, month],
    );

    if (updated > 0) return updated;

    // Insert new
    final budget = Budget(
      categoryId: categoryId,
      month: month,
      amount: amount,
    );
    return await db.insert('account_budgets', budget.toMap());
  }

  static Future<double> getCategorySpending(int categoryId, String month) async {
    final db = await DatabaseService.database;
    final startOfMonth = DateTime.parse('$month-01');
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM account_records
      WHERE category_id = ? AND type = 1 AND date >= ? AND date <= ?
    ''', [categoryId, startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  static Future<void> deleteBudget(int id) async {
    final db = await DatabaseService.database;
    await db.delete(
      'account_budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
