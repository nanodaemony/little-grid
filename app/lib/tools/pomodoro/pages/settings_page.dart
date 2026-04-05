import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/pomodoro_settings.dart';

class PomodoroSettingsPage extends StatefulWidget {
  final PomodoroSettings initialSettings;
  final Function(PomodoroSettings) onSaved;

  const PomodoroSettingsPage({
    super.key,
    required this.initialSettings,
    required this.onSaved,
  });

  @override
  State<PomodoroSettingsPage> createState() => _PomodoroSettingsPageState();
}

class _PomodoroSettingsPageState extends State<PomodoroSettingsPage> {
  late PomodoroSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        actions: [
          TextButton(
            onPressed: () {
              widget.onSaved(_settings);
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection('计时设置', [
            _buildNumberTile(
              title: '番茄时长',
              value: _settings.workDuration,
              unit: '分钟',
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(workDuration: v);
              }),
            ),
            _buildSwitchTile(
              title: '短休息',
              value: _settings.shortBreakEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(shortBreakEnabled: v);
              }),
            ),
            if (_settings.shortBreakEnabled)
              _buildNumberTile(
                title: '休息时长',
                value: _settings.shortBreakDuration,
                unit: '分钟',
                indent: true,
                onChanged: (v) => setState(() {
                  _settings = _settings.copyWith(shortBreakDuration: v);
                }),
              ),
            _buildSwitchTile(
              title: '长休息',
              value: _settings.longBreakEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(longBreakEnabled: v);
              }),
            ),
            if (_settings.longBreakEnabled) ...[
              _buildNumberTile(
                title: '休息时长',
                value: _settings.longBreakDuration,
                unit: '分钟',
                indent: true,
                onChanged: (v) => setState(() {
                  _settings = _settings.copyWith(longBreakDuration: v);
                }),
              ),
              _buildNumberTile(
                title: '长休息间隔',
                value: _settings.longBreakInterval,
                unit: '个',
                indent: true,
                onChanged: (v) => setState(() {
                  _settings = _settings.copyWith(longBreakInterval: v);
                }),
              ),
            ],
          ]),
          _buildSection('显示设置', [
            _buildEnumTile<DisplayStyle>(
              title: '显示样式',
              value: _settings.displayStyle,
              options: {
                DisplayStyle.timer: '计时器形态',
                DisplayStyle.independent: '独立元素',
                DisplayStyle.mixed: '混合形态',
              },
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(displayStyle: v);
              }),
            ),
          ]),
          _buildSection('提醒设置', [
            _buildEnumTile<CompleteAction>(
              title: '完成行为',
              value: _settings.completeAction,
              options: {
                CompleteAction.autoProceed: '自动进入休息',
                CompleteAction.waitConfirm: '等待用户确认',
              },
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(completeAction: v);
              }),
            ),
            _buildSwitchTile(
              title: '振动提醒',
              value: _settings.vibrationEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(vibrationEnabled: v);
              }),
            ),
            _buildSwitchTile(
              title: '提示音',
              value: _settings.soundEnabled,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(soundEnabled: v);
              }),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool indent = false,
  }) {
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ).copyWith(left: indent ? 32 : 16),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildNumberTile({
    required String title,
    required int value,
    required String unit,
    required ValueChanged<int> onChanged,
    bool indent = false,
  }) {
    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ).copyWith(left: indent ? 32 : 16),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Text(
            '$value $unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: value < 60 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEnumTile<T>({
    required String title,
    required T value,
    required Map<T, String> options,
    required ValueChanged<T> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        options[value]!,
        style: const TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(title),
            children: options.entries.map((e) {
              return RadioListTile<T>(
                title: Text(e.value),
                value: e.key,
                groupValue: value,
                onChanged: (v) {
                  if (v != null) {
                    onChanged(v);
                  }
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}