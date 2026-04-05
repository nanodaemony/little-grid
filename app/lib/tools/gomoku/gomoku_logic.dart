import 'gomoku_models.dart';

class GomokuLogic {
  GomokuState _state = GomokuState.initial();

  GomokuState get state => _state;

  /// 落子
  void placeStone(int row, int col) {
    if (_state.isGameOver) return;
    if (_state.board[row][col] != Stone.empty) return;

    // 创建新棋盘
    final newBoard = _state.board.map((r) => r.toList()).toList();
    newBoard[row][col] = _state.currentPlayer;

    // 记录历史
    final newHistory = [..._state.history, Position(row, col)];

    // 检查胜负
    final winner = _checkWin(row, col, newBoard)
        ? _state.currentPlayer
        : null;

    _state = _state.copyWith(
      board: newBoard,
      currentPlayer: _state.currentPlayer == Stone.black
          ? Stone.white
          : Stone.black,
      history: newHistory,
      isGameOver: winner != null,
      winner: winner,
    );
  }

  /// 悔棋
  void undo() {
    if (_state.history.isEmpty) return;
    if (_state.isGameOver) return;

    final lastMove = _state.history.last;
    final newBoard = _state.board.map((r) => r.toList()).toList();
    newBoard[lastMove.row][lastMove.col] = Stone.empty;

    final newHistory = _state.history.sublist(0, _state.history.length - 1);

    _state = _state.copyWith(
      board: newBoard,
      currentPlayer: _state.currentPlayer == Stone.black
          ? Stone.white
          : Stone.black,
      history: newHistory,
    );
  }

  /// 重新开始
  void reset() {
    _state = GomokuState.initial();
  }

  /// 检查是否获胜
  bool _checkWin(int row, int col, List<List<Stone>> board) {
    final stone = board[row][col];

    // 四个方向：水平、垂直、主对角线、副对角线
    final directions = [
      [(0, 1), (0, -1)],   // 水平
      [(1, 0), (-1, 0)],   // 垂直
      [(1, 1), (-1, -1)],  // 主对角线
      [(1, -1), (-1, 1)],  // 副对角线
    ];

    for (final dir in directions) {
      int count = 1;

      // 正方向计数
      count += _countInDirection(row, col, dir[0].$1, dir[0].$2, stone, board);
      // 反方向计数
      count += _countInDirection(row, col, dir[1].$1, dir[1].$2, stone, board);

      if (count >= 5) return true;
    }

    return false;
  }

  /// 在指定方向上计数连续同色棋子
  int _countInDirection(
    int row,
    int col,
    int dRow,
    int dCol,
    Stone stone,
    List<List<Stone>> board,
  ) {
    int count = 0;
    int r = row + dRow;
    int c = col + dCol;

    while (r >= 0 && r < 100 && c >= 0 && c < 100 && board[r][c] == stone) {
      count++;
      r += dRow;
      c += dCol;
    }

    return count;
  }
}