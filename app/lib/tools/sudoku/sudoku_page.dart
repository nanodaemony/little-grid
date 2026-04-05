import 'dart:async';
import 'package:flutter/material.dart';
import 'sudoku_models.dart';
import 'sudoku_logic.dart';
import 'sudoku_board.dart';
import 'sudoku_storage.dart';
import 'sudoku_settings_page.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  final SudokuLogic _logic = SudokuLogic();
  SudokuSettings _settings = const SudokuSettings();
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  int? _selectedRow;
  int? _selectedCol;
  bool _noteMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    _settings = await SudokuStorage.loadSettings();
    setState(() => _isLoading = false);
  }

  void _startGame(Difficulty difficulty) {
    _timer?.cancel();
    _logic.startGame(difficulty);
    _elapsedTime = Duration.zero;
    _selectedRow = null;
    _selectedCol = null;
    _noteMode = false;
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_logic.isInProgress && mounted) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
          _logic.updateElapsedTime(_elapsedTime);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _selectCell(int row, int col) {
    final cell = _logic.state?.cells[row][col];
    if (cell == null) return;

    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _inputNumber(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_logic.state == null) return;

    final cell = _logic.state!.cells[_selectedRow!][_selectedCol!];
    if (cell.isFixed) return;

    setState(() {
      if (_noteMode) {
        _logic.toggleNote(_selectedRow!, _selectedCol!, number);
      } else {
        _logic.setValue(_selectedRow!, _selectedCol!, number);
        _checkCompletion();
      }
    });
  }

  void _clearCell() {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_logic.state == null) return;

    final cell = _logic.state!.cells[_selectedRow!][_selectedCol!];
    if (cell.isFixed || cell.userValue == null) return;

    setState(() {
      _logic.clearValue(_selectedRow!, _selectedCol!);
    });
  }

  void _toggleNoteMode() {
    setState(() {
      _noteMode = !_noteMode;
    });
  }

  void _getHint() {
    if (!_settings.enableHint) return;
    if (_logic.state == null) return;

    final result = _logic.getHint();
    if (result != null) {
      setState(() {
        _selectedRow = result.$1;
        _selectedCol = result.$2;
      });
      _checkCompletion();
    }
  }

  void _undo() {
    if (_logic.history.isEmpty) return;
    setState(() {
      _logic.undo();
    });
  }

  void _checkCompletion() {
    if (_logic.isComplete()) {
      _stopTimer();
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final difficulty = _logic.state!.difficulty;
    final seconds = _elapsedTime.inSeconds;

    // Save best time
    SudokuStorage.saveBestTime(difficulty, seconds);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('恭喜完成!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              '用时: ${_formatTime(seconds)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('难度: ${_difficultyName(difficulty)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('返回首页'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showNewGameDialog();
            },
            child: const Text('再来一局'),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择难度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((d) => ListTile(
            title: Text(_difficultyName(d)),
            onTap: () {
              Navigator.of(context).pop();
              _startGame(d);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _resetGame() {
    _timer?.cancel();
    _logic.reset();
    setState(() {
      _elapsedTime = Duration.zero;
      _selectedRow = null;
      _selectedCol = null;
      _noteMode = false;
    });
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SudokuSettingsPage()),
    );
    _loadSettings();
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _logic.isInProgress
            ? Text(_formatTime(_elapsedTime.inSeconds))
            : const Text('数独'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: '设置',
          ),
        ],
      ),
      body: _logic.isInProgress ? _buildGameScreen() : _buildWelcomeScreen(),
    );
  }

  Widget _buildWelcomeScreen() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.grid_on,
                size: 60,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '数独',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '选择难度开始游戏',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 32),
            // Difficulty buttons
            ...Difficulty.values.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _startGame(d),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _difficultyName(d),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SudokuBoard(
              state: _logic.state!,
              selectedRow: _selectedRow,
              selectedCol: _selectedCol,
              settings: _settings,
              onCellTap: _selectCell,
            ),
          ),
        ),
        // Note mode indicator
        if (_noteMode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 16, color: Theme.of(context).colorScheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  '笔记模式',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        // Number keyboard
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(9, (i) => _buildNumberButton(i + 1)),
          ),
        ),
        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.backspace,
                label: '清除',
                onPressed: _clearCell,
              ),
              _buildActionButton(
                icon: Icons.edit,
                label: '笔记',
                onPressed: _toggleNoteMode,
                isActive: _noteMode,
              ),
              _buildActionButton(
                icon: Icons.lightbulb_outline,
                label: '提示',
                onPressed: _settings.enableHint ? _getHint : null,
              ),
              _buildActionButton(
                icon: Icons.undo,
                label: '撤销',
                onPressed: _logic.history.isNotEmpty ? _undo : null,
              ),
              _buildActionButton(
                icon: Icons.refresh,
                label: '新局',
                onPressed: () => _showNewGameDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _inputNumber(number),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 48,
        alignment: Alignment.center,
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          color: isActive ? colorScheme.primary : null,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? colorScheme.primary : colorScheme.outline,
          ),
        ),
      ],
    );
  }
}