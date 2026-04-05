import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'package:flutter/material.dart';
import 'gomoku_board.dart';
import 'gomoku_logic.dart';
import 'gomoku_models.dart';

class GomokuPage extends StatefulWidget {
  const GomokuPage({super.key});

  @override
  State<GomokuPage> createState() => _GomokuPageState();
}

class _GomokuPageState extends State<GomokuPage> {
  late GomokuLogic _logic;
  late TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _logic = GomokuLogic();
    _transformController = TransformationController();
    _centerBoard();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// 将视图定位到棋盘中心
  void _centerBoard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final boardPixelSize = GomokuBoard.boardPixelSize;

      final offsetX = (boardPixelSize - screenSize.width) / 2;
      final offsetY = (boardPixelSize - screenSize.height + kToolbarHeight) / 2;

      _transformController.value = Matrix4.translation(
        Vector3(-offsetX, -offsetY, 0),
      );
    });
  }

  void _placeStone(int row, int col) {
    setState(() {
      _logic.placeStone(row, col);
    });

    if (_logic.state.isGameOver) {
      _showWinDialog();
    }
  }

  void _undo() {
    setState(() {
      _logic.undo();
    });
  }

  void _reset() {
    setState(() {
      _logic.reset();
    });
    _centerBoard();
  }

  void _showWinDialog() {
    final winner = _logic.state.winner == Stone.black ? '黑棋' : '白棋';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('游戏结束'),
        content: Text('$winner 获胜!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reset();
            },
            child: const Text('再来一局'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('五子棋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _logic.state.history.isEmpty || _logic.state.isGameOver
                ? null
                : _undo,
            tooltip: '悔棋',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: '重新开始',
          ),
        ],
      ),
      body: Column(
        children: [
          // 当前玩家指示
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _logic.state.currentPlayer == Stone.black
                        ? Colors.black
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black38),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_logic.state.currentPlayer == Stone.black ? "黑棋" : "白棋"} 轮流',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // 棋盘
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 2.0,
              child: GomokuBoard(
                state: _logic.state,
                onPlaceStone: _placeStone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}