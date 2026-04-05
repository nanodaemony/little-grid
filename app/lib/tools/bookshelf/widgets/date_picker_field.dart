// app/lib/tools/bookshelf/widgets/date_picker_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;
  final String? hintText;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.hintText,
    this.required = false,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
              color: selectedDate != null
                  ? null
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? _formatDate(selectedDate!)
                        : (hintText ?? '选择日期'),
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                    ),
                  ),
                ),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => onDateSelected(null),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDate ?? now;
    final first = firstDate ?? DateTime(now.year - 50);
    final last = lastDate ?? DateTime(now.year + 10);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: first,
      lastDate: last,
      locale: const Locale('zh', 'CN'),
      helpText: hintText ?? '选择日期',
    );

    if (picked != null) {
      onDateSelected(DateTime(picked.year, picked.month, picked.day));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
}

// 日期范围选择器
class DateRangePickerField extends StatelessWidget {
  final String label;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<DateTime?> onStartDateChanged;
  final ValueChanged<DateTime?> onEndDateChanged;
  final String? startHint;
  final String? endHint;
  final bool required;

  const DateRangePickerField({
    super.key,
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.startHint,
    this.endHint,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: '开始日期',
                selectedDate: startDate,
                onDateSelected: onStartDateChanged,
                hintText: startHint ?? '开始日期',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DatePickerField(
                label: '结束日期',
                selectedDate: endDate,
                onDateSelected: onEndDateChanged,
                hintText: endHint ?? '结束日期',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 纯文本日期输入框（用于手动输入或编辑）
class DateTextField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateChanged;
  final String? hintText;
  final bool required;
  final bool enabled;

  const DateTextField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onDateChanged,
    this.hintText,
    this.required = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: selectedDate != null ? _formatDateForInput(selectedDate!) : '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                inputFormatters: [_DateInputFormatter()],
                decoration: InputDecoration(
                  hintText: hintText ?? 'YYYY-MM-DD',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  suffixIcon: selectedDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => onDateChanged(null),
                        )
                      : null,
                ),
                onChanged: (value) {
                  final parsed = _parseDate(value);
                  if (parsed != null) {
                    onDateChanged(parsed);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: enabled ? () => _selectDate(context) : null,
              tooltip: '选择日期',
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: DateTime(now.year + 10),
      locale: const Locale('zh', 'CN'),
    );

    if (picked != null) {
      onDateChanged(DateTime(picked.year, picked.month, picked.day));
    }
  }

  String _formatDateForInput(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String value) {
    if (value.length == 10 && value.contains('-')) {
      final parts = value.split('-');
      if (parts.length == 3) {
        try {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          if (year >= 1900 && year <= 2100 &&
              month >= 1 && month <= 12 &&
              day >= 1 && day <= 31) {
            return DateTime(year, month, day);
          }
        } catch (_) {}
      }
    }
    return null;
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 只允许数字和横杠
    if (newValue.text.isNotEmpty &&
        RegExp(r'[^0-9-]').hasMatch(newValue.text)) {
      return oldValue;
    }

    // 自动添加横杠
    var text = newValue.text.replaceAll('-', '');
    var formatted = '';

    for (var i = 0; i < text.length && i < 8; i++) {
      if (i == 4 || i == 6) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
