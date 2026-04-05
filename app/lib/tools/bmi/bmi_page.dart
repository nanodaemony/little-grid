import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/bmi_result.dart';
import 'services/bmi_service.dart';
import 'widgets/result_card.dart';
import 'widgets/height_input.dart';
import 'widgets/weight_input.dart';

class BMIPage extends StatefulWidget {
  const BMIPage({super.key});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  double _height = 170.0;
  double _weight = 65.0;
  BMIResult? _result;

  @override
  void initState() {
    super.initState();
    _loadLastValues();
  }

  Future<void> _loadLastValues() async {
    final prefs = await SharedPreferences.getInstance();
    final lastHeight = prefs.getDouble('bmi_last_height');
    final lastWeight = prefs.getDouble('bmi_last_weight');

    if (mounted) {
      setState(() {
        if (lastHeight != null) _height = lastHeight!;
        if (lastWeight != null) _weight = lastWeight!;
        _calculateBMI();
      });
    }
  }

  Future<void> _saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bmi_last_height', _height);
    await prefs.setDouble('bmi_last_weight', _weight);
  }

  void _calculateBMI() {
    try {
      setState(() {
        _result = BMIService.calculate(_height, _weight);
      });
      _saveValues();
    } catch (e) {
      setState(() {
        _result = null;
      });
    }
  }

  void _applyPreset(double height, double weight) {
    setState(() {
      _height = height;
      _weight = weight;
      _calculateBMI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI 计算器'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 结果卡片
            ResultCard(result: _result),
            const SizedBox(height: 24),

            // 输入区域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  HeightInput(
                    value: _height,
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                        _calculateBMI();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  WeightInput(
                    value: _weight,
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                        _calculateBMI();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 快速预设
            const Text(
              '快速预设',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _PresetButton(
                  label: '160cm / 50kg',
                  onTap: () => _applyPreset(160, 50),
                ),
                _PresetButton(
                  label: '165cm / 55kg',
                  onTap: () => _applyPreset(165, 55),
                ),
                _PresetButton(
                  label: '170cm / 60kg',
                  onTap: () => _applyPreset(170, 60),
                ),
                _PresetButton(
                  label: '175cm / 70kg',
                  onTap: () => _applyPreset(175, 70),
                ),
                _PresetButton(
                  label: '180cm / 75kg',
                  onTap: () => _applyPreset(180, 75),
                ),
                _PresetButton(
                  label: '185cm / 80kg',
                  onTap: () => _applyPreset(185, 80),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 单位说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'BMI = 体重kg / 身高m²',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
        foregroundColor: Colors.blue[700],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
