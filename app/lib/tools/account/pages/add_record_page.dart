// app/lib/tools/account/pages/add_record_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/record.dart';
import '../models/category.dart';
import '../services/account_service.dart';
import '../widgets/category_picker.dart';

class AddRecordPage extends StatefulWidget {
  final Record? record;
  final RecordType? initialType;

  const AddRecordPage({super.key, this.record, this.initialType});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  late RecordType _type;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  Category? _selectedCategory;
  Category? _selectedSubCategory;
  List<Category> _categories = [];

  String get _title => widget.record == null ? '记一笔' : '编辑记录';

  @override
  void initState() {
    super.initState();
    _type = widget.record?.type ?? widget.initialType ?? RecordType.expense;
    _loadCategories();

    if (widget.record != null) {
      _amountController.text = widget.record!.amount.toStringAsFixed(2);
      _noteController.text = widget.record!.note ?? '';
      _date = widget.record!.date;
      _loadExistingCategories();
    }
  }

  Future<void> _loadCategories() async {
    final categories = await AccountService.getCategories(_type);
    setState(() => _categories = categories);
  }

  Future<void> _loadExistingCategories() async {
    if (widget.record == null) return;
    final category = await AccountService.getCategoryById(widget.record!.categoryId);
    final subCategory = widget.record!.subCategoryId != null
        ? await AccountService.getCategoryById(widget.record!.subCategoryId!)
        : null;
    setState(() {
      _selectedCategory = category;
      _selectedSubCategory = subCategory;
    });
  }

  void _switchType(RecordType type) {
    if (_type == type) return;
    setState(() {
      _type = type;
      _selectedCategory = null;
      _selectedSubCategory = null;
    });
    _loadCategories();
  }

  Future<void> _selectCategory() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CategoryPicker(
        type: _type,
        selectedCategory: _selectedCategory,
        selectedSubCategory: _selectedSubCategory,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result['category'] as Category?;
        _selectedSubCategory = result['subCategory'] as Category?;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('请输入有效金额');
      return;
    }
    if (_selectedCategory == null) {
      _showError('请选择分类');
      return;
    }

    final record = Record(
      id: widget.record?.id,
      amount: amount,
      type: _type,
      categoryId: _selectedCategory!.id!,
      subCategoryId: _selectedSubCategory?.id,
      date: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    if (widget.record == null) {
      await AccountService.insertRecord(record);
    } else {
      await AccountService.updateRecord(record);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type toggle
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // Amount input
            _buildAmountInput(),
            const SizedBox(height: 24),

            // Category selector
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Date selector
            _buildDateSelector(),
            const SizedBox(height: 16),

            // Note input
            _buildNoteInput(),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
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
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('金额', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '¥ ',
            prefixStyle: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _type == RecordType.expense ? AppColors.error : AppColors.success,
            ),
            border: InputBorder.none,
            hintText: '0.00',
            hintStyle: TextStyle(color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return InkWell(
      onTap: _selectCategory,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (_selectedCategory != null) ...[
              Text(_selectedSubCategory?.icon ?? _selectedCategory!.icon,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                _selectedSubCategory?.name ?? _selectedCategory!.name,
                style: const TextStyle(fontSize: 16),
              ),
            ] else ...[
              Icon(Icons.category, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Text('选择分类', style: TextStyle(color: Colors.grey.shade500)),
            ],
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Text(
              '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInput() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: '备注（可选）',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.edit_note),
      ),
      maxLines: 2,
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
