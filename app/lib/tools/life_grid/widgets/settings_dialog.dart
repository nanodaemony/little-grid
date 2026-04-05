import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/life_grid_settings.dart';
import '../services/life_grid_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final LifeGridService _service = LifeGridService();
  LifeGridSettings _settings = LifeGridSettings();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _service.loadSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _settings.birthDate ?? DateTime(now.year - 25, now.month, now.day);
    final firstDate = DateTime(1900, 1, 1);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('zh', 'CN'),
    );

    if (picked != null) {
      setState(() {
        _settings = _settings.copyWith(birthDate: picked);
      });
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置所有设置吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('重置'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _settings = LifeGridSettings();
      });
      await _service.saveSettings(_settings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('设置已重置')),
        );
      }
    }
  }

  bool get _hasAtLeastOneTabVisible {
    return _settings.showWeekMonth ||
        _settings.showYear ||
        _settings.showLife ||
        _settings.showCustom;
  }

  Future<void> _saveSettings() async {
    if (!_hasAtLeastOneTabVisible) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('警告'),
          content: const Text('请至少显示一个标签页。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
      return;
    }

    await _service.saveSettings(_settings);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '未设置';
    return '${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('加载中...'),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      title: const Text('设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('标签页显示'),
            _buildSwitchTile(
              title: '周/月视图',
              subtitle: '显示本周进度和本月进度',
              value: _settings.showWeekMonth,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showWeekMonth: value);
                });
              },
            ),
            _buildSwitchTile(
              title: '年视图',
              subtitle: '显示本年度进度',
              value: _settings.showYear,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showYear: value);
                });
              },
            ),
            _buildSwitchTile(
              title: '人生视图',
              subtitle: '显示人生进度（需要设置出生日期）',
              value: _settings.showLife,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showLife: value);
                });
              },
            ),
            _buildSwitchTile(
              title: '自定义进度',
              subtitle: '显示自定义进度追踪',
              value: _settings.showCustom,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(showCustom: value);
                });
              },
            ),
            if (!_hasAtLeastOneTabVisible)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '警告：请至少显示一个标签页',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            _buildSectionTitle('出生日期'),
            ListTile(
              title: Text(_formatDate(_settings.birthDate)),
              subtitle: const Text('用于计算人生进度'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectBirthDate,
            ),
            _buildSectionTitle('目标年龄'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _settings.targetAge.toDouble(),
                      min: 1,
                      max: 120,
                      divisions: 119,
                      label: '${_settings.targetAge}岁',
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(targetAge: value.round());
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${_settings.targetAge}岁',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _resetSettings,
                icon: const Icon(Icons.restore),
                label: const Text('重置所有设置'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
