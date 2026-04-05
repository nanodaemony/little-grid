import 'package:flutter/material.dart';
import 'sudoku_storage.dart';
import 'sudoku_models.dart';

class SudokuSettingsPage extends StatefulWidget {
  const SudokuSettingsPage({super.key});

  @override
  State<SudokuSettingsPage> createState() => _SudokuSettingsPageState();
}

class _SudokuSettingsPageState extends State<SudokuSettingsPage> {
  late SudokuSettings _settings;
  Map<Difficulty, int?> _bestTimes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _settings = await SudokuStorage.loadSettings();
    for (final difficulty in Difficulty.values) {
      _bestTimes[difficulty] = await SudokuStorage.getBestTime(difficulty);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _clearAllRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有最佳成绩吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SudokuStorage.clearAllBestTimes();
      setState(() {
        for (final difficulty in Difficulty.values) {
          _bestTimes[difficulty] = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _buildSectionHeader('辅助功能'),
          SwitchListTile(
            title: const Text('错误标记'),
            subtitle: const Text('填入错误数字时，格子显示红色边框'),
            value: _settings.showErrorHighlight,
            onChanged: (v) async {
              _settings = _settings.copyWith(showErrorHighlight: v);
              await SudokuStorage.saveSettings(_settings);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('候选数提示'),
            subtitle: const Text('在空白格内显示可能的数字（小字）'),
            value: _settings.showCandidates,
            onChanged: (v) async {
              _settings = _settings.copyWith(showCandidates: v);
              await SudokuStorage.saveSettings(_settings);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('自动排除'),
            subtitle: const Text('自动移除已被同行/列/宫占用的候选数'),
            value: _settings.autoEliminate,
            onChanged: (v) async {
              _settings = _settings.copyWith(autoEliminate: v);
              await SudokuStorage.saveSettings(_settings);
              setState(() {});
            },
          ),
          SwitchListTile(
            title: const Text('提示功能'),
            subtitle: const Text('点击提示按钮，自动填入一个正确数字'),
            value: _settings.enableHint,
            onChanged: (v) async {
              _settings = _settings.copyWith(enableHint: v);
              await SudokuStorage.saveSettings(_settings);
              setState(() {});
            },
          ),
          const Divider(height: 32),
          _buildSectionHeader('游戏记录'),
          ...Difficulty.values.map((d) => ListTile(
                title: Text(_difficultyName(d)),
                trailing: Text(
                    '最佳: ${_bestTimes[d] != null ? _formatTime(_bestTimes[d]!) : '--:--'}'),
              )),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: _clearAllRecords,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('清除所有记录'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  String _difficultyName(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困难';
      case Difficulty.expert:
        return '专家';
    }
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}