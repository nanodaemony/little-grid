import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/category.dart';
import '../models/record.dart';
import '../models/budget.dart';
import '../models/stats_models.dart';
import '../services/account_service.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  DateTime _currentMonth = DateTime.now();
  List<BudgetWithCategory> _budgets = [];
  double _totalBudget = 0;
  double _totalSpent = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final monthStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
    final budgets = await AccountService.getBudgets(monthStr);

    double totalBudget = 0;
    double totalSpent = 0;
    for (final b in budgets) {
      totalBudget += b.budget.amount;
      totalSpent += b.spent;
    }

    setState(() {
      _budgets = budgets;
      _totalBudget = totalBudget;
      _totalSpent = totalSpent;
      _isLoading = false;
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    if (_currentMonth.year == DateTime.now().year &&
        _currentMonth.month == DateTime.now().month) {
      return;
    }
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _loadData();
  }

  Future<void> _setBudget(Category category) async {
    final controller = TextEditingController();
    final existingBudget = _budgets.firstWhere(
      (b) => b.category.id == category.id,
      orElse: () => BudgetWithCategory(
        budget: Budget(categoryId: category.id!, month: '', amount: 0),
        category: category,
      ),
    );

    if (existingBudget.budget.id != null) {
      controller.text = existingBudget.budget.amount.toStringAsFixed(0);
    }

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('设置预算 - ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '预算金额',
            prefixText: '¥ ',
          ),
        ),
        actions: [
          if (existingBudget.budget.id != null)
            TextButton(
              onPressed: () async {
                await AccountService.deleteBudget(existingBudget.budget.id!);
                if (mounted) Navigator.pop(context, -1);
              },
              child: const Text('删除', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context, amount);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == -1) {
      _loadData();
      return;
    }

    if (result != null && result > 0) {
      final monthStr = '${_currentMonth.year}-${_currentMonth.month.toString().padLeft(2, '0')}';
      await AccountService.setBudget(category.id!, monthStr, result);
      _loadData();
    }
  }

  Future<void> _addBudget() async {
    final categories = await AccountService.getCategories(RecordType.expense);
    final categoriesWithBudget = _budgets.map((b) => b.category.id).toSet();
    final availableCategories = categories
        .where((c) => !categoriesWithBudget.contains(c.id))
        .toList();

    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('所有分类都已设置预算')),
      );
      return;
    }

    final selectedCategory = await showDialog<Category>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分类'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableCategories.length,
            itemBuilder: (context, index) {
              final category = availableCategories[index];
              return ListTile(
                leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
                title: Text(category.name),
                onTap: () => Navigator.pop(context, category),
              );
            },
          ),
        ),
      ),
    );

    if (selectedCategory != null) {
      _setBudget(selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (_totalBudget - _totalSpent).toDouble();
    final progress = _totalBudget > 0 ? ((_totalSpent / _totalBudget).clamp(0, 1) as num).toDouble() : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('预算')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthSelector(),
                _buildOverviewCard(remaining, progress),
                Expanded(
                  child: _budgets.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _budgets.length,
                          itemBuilder: (context, index) {
                            return _buildBudgetItem(_budgets[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudget,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            '${_currentMonth.year}年${_currentMonth.month}月',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(double remaining, double progress) {
    final isOverBudget = remaining < 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [AppColors.error, Colors.red.shade400]
              : [AppColors.primary, const Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOverBudget ? '已超支' : '本月剩余',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¥${remaining.abs().toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '总预算: ¥${_totalBudget.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '已用: ¥${_totalSpent.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% 已使用',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            '暂无预算设置',
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            '点击右下角添加预算',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(BudgetWithCategory item) {
    final isOverBudget = item.isOverBudget;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _setBudget(item.category),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(item.category.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '¥${item.spent.toStringAsFixed(0)} / ¥${item.budget.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverBudget ? AppColors.error : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOverBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '超支',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    isOverBudget ? AppColors.error : AppColors.primary,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
