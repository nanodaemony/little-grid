// lib/tools/drink_plan/pages/settings_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../services/drink_plan_service.dart';

class DrinkPlanSettingsPage extends StatefulWidget {
  const DrinkPlanSettingsPage({super.key});

  @override
  State<DrinkPlanSettingsPage> createState() => _DrinkPlanSettingsPageState();
}

class _DrinkPlanSettingsPageState extends State<DrinkPlanSettingsPage> {
  double _opacity = 0.3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final opacity = await DrinkPlanService.getBackgroundOpacity();
    if (mounted) {
      setState(() {
        _opacity = opacity;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOpacity(double opacity) async {
    await DrinkPlanService.saveSettings(opacity);
    if (mounted) {
      setState(() {
        _opacity = opacity;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  '背景透明度',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '调整日期单元格背景图的透明程度',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                _OpacityOption(
                  label: '100%（不透明）',
                  value: 1.0,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                _OpacityOption(
                  label: '75%（轻微透明）',
                  value: 0.75,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                _OpacityOption(
                  label: '50%（半透明）',
                  value: 0.5,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                _OpacityOption(
                  label: '25%（高度透明）',
                  value: 0.25,
                  currentValue: _opacity,
                  onSelected: _saveOpacity,
                ),
                const SizedBox(height: 24),
                // 预览
                const Text(
                  '预览',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: _opacity,
                          child: const Center(
                            child: Text(
                              '🧋',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            '24',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _OpacityOption extends StatelessWidget {
  final String label;
  final double value;
  final double currentValue;
  final Function(double) onSelected;

  const _OpacityOption({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = (currentValue - value).abs() < 0.01;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : const Icon(Icons.radio_button_unchecked),
      onTap: () => onSelected(value),
    );
  }
}
