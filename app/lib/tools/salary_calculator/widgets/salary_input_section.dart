import 'package:flutter/material.dart';

class SalaryInputSection extends StatelessWidget {
  final double salary;
  final String selectedCityId;
  final List<String> cityNames;
  final List<String> cityIds;
  final ValueChanged<double> onSalaryChanged;
  final ValueChanged<String> onCityChanged;
  final VoidCallback onCalculate;
  final List<double> presetSalaries;

  const SalaryInputSection({
    super.key,
    required this.salary,
    required this.selectedCityId,
    required this.cityNames,
    required this.cityIds,
    required this.onSalaryChanged,
    required this.onCityChanged,
    required this.onCalculate,
    this.presetSalaries = const [5000, 8000, 10000, 15000, 20000, 30000, 50000],
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = cityIds.indexOf(selectedCityId);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '税前工资',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '请输入税前工资',
              prefixText: '¥ ',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: TextEditingController(text: salary > 0 ? salary.toStringAsFixed(0) : ''),
            onChanged: (value) {
              final parsed = double.tryParse(value) ?? 0;
              onSalaryChanged(parsed);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '快速预设',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presetSalaries.map((preset) {
              return ElevatedButton(
                onPressed: () => onSalaryChanged(preset),
                style: ElevatedButton.styleFrom(
                  backgroundColor: salary == preset
                      ? Theme.of(context).colorScheme.primary
                      : Colors.blue[100],
                  foregroundColor: salary == preset
                      ? Colors.white
                      : Colors.blue[700],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('¥${preset ~/ 1000}k'),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            '城市',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedIndex >= 0 ? selectedCityId : null,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            items: List.generate(cityIds.length, (index) {
              return DropdownMenuItem(
                value: cityIds[index],
                child: Text(cityNames[index]),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                onCityChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
