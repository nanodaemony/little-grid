/// 棋子状态
enum Stone { empty, black, white }

/// 坐标位置
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);
}

/// 游戏状态
class GomokuState {
  final List<List<Stone>> board;
  final Stone currentPlayer;
  final List<Position> history;
  final bool isGameOver;
  final Stone? winner;

  GomokuState({
    required this.board,
    required this.currentPlayer,
    required this.history,
    this.isGameOver = false,
    this.winner,
  });

  /// 创建初始状态（100×100 空棋盘）
  factory GomokuState.initial() {
    const boardSize = 100;
    final board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => Stone.empty),
    );
    return GomokuState(
      board: board,
      currentPlayer: Stone.black,
      history: [],
    );
  }

  /// 复制并修改状态
  GomokuState copyWith({
    List<List<Stone>>? board,
    Stone? currentPlayer,
    List<Position>? history,
    bool? isGameOver,
    Stone? winner,
  }) {
    return GomokuState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      history: history ?? this.history,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
    );
  }
}