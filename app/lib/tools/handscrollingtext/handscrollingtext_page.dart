import 'package:flutter/material.dart';
import 'models/danmaku_models.dart';
import 'widgets/config_panel.dart';
import 'widgets/danmaku_player.dart';
import 'widgets/preset_text_grid.dart';
import 'danmaku_player_page.dart';

class HandScrollingTextPage extends StatefulWidget {
  const HandScrollingTextPage({super.key});

  @override
  State<HandScrollingTextPage> createState() => _HandScrollingTextPageState();
}

class _HandScrollingTextPageState extends State<HandScrollingTextPage> {
  late DanmakuConfig _config;
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _config = DanmakuConfig(text: '');
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _config = _config.copyWith(text: _textController.text);
    });
  }

  void _onPresetSelected(String value) {
    if (value.startsWith('__category__')) {
      setState(() {
        _selectedCategory = value.replaceFirst('__category__', '');
      });
    } else {
      _textController.text = value;
    }
  }

  void _onConfigChanged(DanmakuConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
  }

  bool _canPlay() => _config.text.trim().isNotEmpty;

  void _startDanmaku() {
    if (!_canPlay()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DanmakuPlayerPage(config: _config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手持弹幕'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _canPlay() ? _startDanmaku : null,
            tooltip: '播放',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: _config.text.isEmpty
                  ? Center(
                      child: Text(
                        '输入文字预览效果',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : DanmakuPlayer(
                      config: _config,
                      isPreview: true,
                    ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: '文案',
                hintText: '输入要显示的文字',
                border: const OutlineInputBorder(),
                suffixIcon: _config.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _textController.clear(),
                      )
                    : null,
              ),
              maxLength: 100,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),
            Text(
              '预设文案',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            PresetTextGrid(
              selectedCategory: _selectedCategory,
              onTextSelected: _onPresetSelected,
            ),
            const SizedBox(height: 24),
            Text(
              '设置',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ConfigPanel(
              config: _config,
              onConfigChanged: _onConfigChanged,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canPlay() ? _startDanmaku : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始播放'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
