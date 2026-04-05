import 'category.dart';
import 'budget.dart';

/// Monthly summary
class MonthlySummary {
  final double income;
  final double expense;

  MonthlySummary({required this.income, required this.expense});

  double get balance => income - expense;
}

/// Category statistics
class CategoryStats {
  final Category category;
  final double amount;

  CategoryStats({required this.category, required this.amount});
}

/// Trend data for line chart
class TrendData {
  final String month;
  final double income;
  final double expense;

  TrendData({required this.month, required this.income, required this.expense});
}

/// Budget with associated category
class BudgetWithCategory {
  final Budget budget;
  final Category category;
  final double spent;

  BudgetWithCategory({
    required this.budget,
    required this.category,
    this.spent = 0,
  });

  double get remaining => budget.amount - spent;
  double get progress => budget.amount > 0 ? (spent / budget.amount).clamp(0, 1) : 0;
  bool get isOverBudget => spent > budget.amount;
}
