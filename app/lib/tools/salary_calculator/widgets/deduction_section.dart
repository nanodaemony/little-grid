import 'package:flutter/material.dart';

class DeductionSection extends StatefulWidget {
  final Map<String, double> deductions;
  final ValueChanged<Map<String, double>> onDeductionsChanged;

  const DeductionSection({
    super.key,
    required this.deductions,
    required this.onDeductionsChanged,
  });

  @override
  State<DeductionSection> createState() => _DeductionSectionState();
}

class _DeductionSectionState extends State<DeductionSection> {
  bool _isExpanded = false;

  static const Map<String, String> deductionLabels = {
    'childrenEducation': '子女教育',
    'continuingEducation': '继续教育',
    'seriousIllness': '大病医疗',
    'housingLoan': '住房贷款利息',
    'housingRent': '住房租金',
    'elderlyCare': '赡养老人',
    'infantCare': '3岁以下婴幼儿照护',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '专项附加扣除',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: deductionLabels.entries.map((entry) {
                  final key = entry.key;
                  final label = entry.value;
                  final value = widget.deductions[key] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(label),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: '¥ ',
                              hintText: '0',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            controller: TextEditingController(text: value > 0 ? value.toStringAsFixed(0) : ''),
                            onChanged: (text) {
                              final parsed = double.tryParse(text) ?? 0;
                              final newDeductions = Map<String, double>.from(widget.deductions);
                              newDeductions[key] = parsed;
                              widget.onDeductionsChanged(newDeductions);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_isExpanded) const SizedBox(height: 16),
        ],
      ),
    );
  }
}
