import 'dart:math';
import 'package:flutter/material.dart';

class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  // 状态
  int _minValue = 1;
  int _maxValue = 100;
  int _count = 1;
  bool _allowDuplicate = true;
  bool _isSettingsExpanded = false;
  List<int> _results = [];

  // 错误信息
  String? _minError;
  String? _maxError;
  String? _countError;

  final Random _random = Random();
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
  final TextEditingController _countController = TextEditingController(text: '1');

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _validateMin(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) {
      setState(() => _minError = '请输入有效的整数');
      return;
    }
    if (intValue < 1) {
      setState(() => _minError = '最小值不能小于1');
      return;
    }
    if (intValue >= _maxValue) {
      setState(() => _minError = '最小值必须小于最大值');
      return;
    }
    setState(() {
      _minError = null;
      _minValue = intValue;
    });
  }

  void _validateMax(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) {
      setState(() => _maxError = '请输入有效的整数');
      return;
    }
    if (intValue > 999999999) {
      setState(() => _maxError = '最大值不能超过999999999');
      return;
    }
    if (intValue <= _minValue) {
      setState(() => _maxError = '最大值必须大于最小值');
      return;
    }
    setState(() {
      _maxError = null;
      _maxValue = intValue;
    });
  }

  void _validateCount(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) {
      setState(() => _countError = '请输入有效的整数');
      return;
    }
    if (intValue < 1 || intValue > 100) {
      setState(() => _countError = '数量必须在1-100之间');
      return;
    }
    if (!_allowDuplicate && intValue > (_maxValue - _minValue + 1)) {
      setState(() => _countError = '范围不足以生成${intValue}个不重复的数');
      return;
    }
    setState(() {
      _countError = null;
      _count = intValue;
    });
  }

  bool _hasError() {
    return _minError != null || _maxError != null || _countError != null;
  }

  void _generateRandomNumbers() {
    if (_hasError()) return;

    setState(() {
      if (_allowDuplicate) {
        // 允许重复：直接随机生成
        _results = List.generate(
          _count,
          (_) => _minValue + _random.nextInt(_maxValue - _minValue + 1),
        );
      } else {
        // 不允许重复：使用 Fisher-Yates 洗牌
        final range = List.generate(
          _maxValue - _minValue + 1,
          (i) => _minValue + i,
        );
        for (int i = range.length - 1; i > 0; i--) {
          final j = _random.nextInt(i + 1);
          final temp = range[i];
          range[i] = range[j];
          range[j] = temp;
        }
        _results = range.take(_count).toList();
      }
    });
  }

  void _resetToDefaults() {
    setState(() {
      _minValue = 1;
      _maxValue = 100;
      _count = 1;
      _allowDuplicate = true;
      _results = [];
      _minError = null;
      _maxError = null;
      _countError = null;
      _minController.text = '1';
      _maxController.text = '100';
      _countController.text = '1';
    });
  }

  Widget _buildSettingsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最小值
          Row(
            children: [
              const SizedBox(width: 80, child: Text('最小值:')),
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  onChanged: _validateMin,
                  decoration: InputDecoration(
                    errorText: _minError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 最大值
          Row(
            children: [
              const SizedBox(width: 80, child: Text('最大值:')),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  onChanged: _validateMax,
                  decoration: InputDecoration(
                    errorText: _maxError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 数量
          Row(
            children: [
              const SizedBox(width: 80, child: Text('数量:')),
              Expanded(
                child: TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  onChanged: _validateCount,
                  decoration: InputDecoration(
                    errorText: _countError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                    suffixText: '个',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 允许重复
          Row(
            children: [
              const SizedBox(width: 80, child: Text('选项:')),
              Checkbox(
                value: _allowDuplicate,
                onChanged: (value) {
                  setState(() {
                    _allowDuplicate = value ?? true;
                    _validateCount(_countController.text);
                  });
                },
              ),
              const Text('允许重复'),
            ],
          ),
          const SizedBox(height: 8),
          // 重置按钮
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetToDefaults,
              child: const Text('重置为默认值'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('随机数'),
        actions: [
          IconButton(
            icon: Icon(_isSettingsExpanded ? Icons.expand_less : Icons.expand_more),
            tooltip: _isSettingsExpanded ? '收起设置' : '展开设置',
            onPressed: () {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 设置摘要
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '范围: $_minValue - $_maxValue  数量: $_count个  ${_allowDuplicate ? "" : "(不重复)"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          // 设置面板（可展开）
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSettingsPanel(),
            crossFadeState: _isSettingsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          // 结果展示区域
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shuffle,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '点击下方按钮生成随机数',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: _results.map((number) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$number',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
          // 生成按钮
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _hasError() ? null : _generateRandomNumbers,
                icon: const Icon(Icons.shuffle),
                label: const Text(
                  '生成随机数',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
