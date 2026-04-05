import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/usage_service.dart';
import 'services/rmb_converter.dart';

class RmbConvertorPage extends StatefulWidget {
  const RmbConvertorPage({super.key});

  @override
  State<RmbConvertorPage> createState() => _RmbConvertorPageState();
}

class _RmbConvertorPageState extends State<RmbConvertorPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('rmbconvertor');
  }

  @override
  void dispose() {
    _controller.dispose();
    UsageService.recordExit('rmbconvertor');
    super.dispose();
  }

  void _onInputChanged(String value) {
    // 格式化输入
    String formatted = RmbConverter.formatInput(value);
    if (formatted != value) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {
      _errorMessage = '';
    });
  }

  void _convert() {
    String input = _controller.text.replaceAll(',', '');
    double? amount = double.tryParse(input);

    if (amount == null) {
      setState(() {
        _errorMessage = '请输入有效的金额';
        _result = '';
      });
      return;
    }

    if (amount < 0) {
      setState(() {
        _errorMessage = '金额不能为负数';
        _result = '';
      });
      return;
    }

    if (!RmbConverter.isValidAmount(amount)) {
      setState(() {
        _errorMessage = '金额过大，最大支持9亿9999万元';
        _result = '';
      });
      return;
    }

    setState(() {
      _result = RmbConverter.convert(amount);
      _errorMessage = '';
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _result = '';
      _errorMessage = '';
    });
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制到剪贴板'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人民币大写转换'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            _buildInputSection(),
            const SizedBox(height: 24),
            // 结果显示区域
            _buildResultSection(),
            const SizedBox(height: 32),
            // 分隔线
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 24),
            // 对照表
            _buildReferenceTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '输入金额',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: _onInputChanged,
          decoration: InputDecoration(
            prefixText: '¥ ',
            prefixStyle: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
            hintText: '请输入金额',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clear,
                  )
                : null,
            errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
          ),
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _convert,
          icon: const Icon(Icons.currency_exchange),
          label: const Text('转换'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '转换结果',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (_result.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: _copyResult,
                  tooltip: '复制结果',
                  color: Colors.blue,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _result.isNotEmpty ? _result : '等待转换...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _result.isNotEmpty ? Colors.black87 : Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.table_chart, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              '数字与人民币大写对照表',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 数字对照
        _buildDigitTable(),
        const SizedBox(height: 16),
        // 单位对照
        _buildUnitTable(),
      ],
    );
  }

  Widget _buildDigitTable() {
    final digits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数字',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(10, (index) {
                return Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$index',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        digits[index],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitTable() {
    final units = [
      {'name': '拾', 'value': '十'},
      {'name': '佰', 'value': '百'},
      {'name': '仟', 'value': '千'},
      {'name': '万', 'value': '万'},
      {'name': '亿', 'value': '亿'},
      {'name': '元', 'value': '元'},
      {'name': '角', 'value': '角'},
      {'name': '分', 'value': '分'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '单位',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: units.map((unit) {
                return Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    children: [
                      Text(
                        unit['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        unit['value']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
