import 'package:flutter/material.dart';
import '../models/city_config.dart';

class InsuranceSection extends StatefulWidget {
  final CityConfig cityConfig;
  final bool useCustom;
  final ValueChanged<bool> onUseCustomChanged;
  final ValueChanged<CityConfig> onConfigChanged;

  const InsuranceSection({
    super.key,
    required this.cityConfig,
    required this.useCustom,
    required this.onUseCustomChanged,
    required this.onConfigChanged,
  });

  @override
  State<InsuranceSection> createState() => _InsuranceSectionState();
}

class _InsuranceSectionState extends State<InsuranceSection> {
  bool _isExpanded = false;

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
              '五险一金配置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: widget.useCustom,
                  onChanged: widget.onUseCustomChanged,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
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
              child: widget.useCustom ? _buildCustomConfig() : _buildDefaultDisplay(),
            ),
          if (_isExpanded) const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDefaultDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('养老保险: ${(widget.cityConfig.pensionRate * 100).toStringAsFixed(1)}%'),
        Text('医疗保险: ${(widget.cityConfig.medicalRate * 100).toStringAsFixed(1)}%'),
        Text('失业保险: ${(widget.cityConfig.unemploymentRate * 100).toStringAsFixed(1)}%'),
        Text('公积金: ${(widget.cityConfig.housingFundRate * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildCustomConfig() {
    return Column(
      children: [
        _buildRateField(
          '养老保险',
          widget.cityConfig.pensionRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(pensionRate: value));
          },
        ),
        const SizedBox(height: 12),
        _buildRateField(
          '医疗保险',
          widget.cityConfig.medicalRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(medicalRate: value));
          },
        ),
        const SizedBox(height: 12),
        _buildRateField(
          '失业保险',
          widget.cityConfig.unemploymentRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(unemploymentRate: value));
          },
        ),
        const SizedBox(height: 12),
        _buildRateField(
          '公积金',
          widget.cityConfig.housingFundRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(housingFundRate: value));
          },
        ),
      ],
    );
  }

  Widget _buildRateField(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label),
        ),
        Expanded(
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: '%',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(text: (value * 100).toStringAsFixed(1)),
            onChanged: (text) {
              final parsed = double.tryParse(text) ?? 0;
              onChanged(parsed / 100);
            },
          ),
        ),
      ],
    );
  }
}
