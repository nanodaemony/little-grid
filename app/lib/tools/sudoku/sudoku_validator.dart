// app/lib/tools/sudoku/sudoku_validator.dart
/// 数独验证工具类
class SudokuValidator {
  /// 检查在指定位置放置数字是否有效
  static bool isValidPlacement(List<List<int>> board, int row, int col, int num) {
    // 检查行
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }

    // 检查列
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }

    // 检查 3x3 宫
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[boxRow + i][boxCol + j] == num) return false;
      }
    }

    return true;
  }

  /// 验证整个棋盘是否有效
  static bool isValidBoard(List<List<int>> board) {
    for (int i = 0; i < 9; i++) {
      // 检查每行
      final rowSet = <int>{};
      for (int j = 0; j < 9; j++) {
        final val = board[i][j];
        if (val < 1 || val > 9 || !rowSet.add(val)) return false;
      }

      // 检查每列
      final colSet = <int>{};
      for (int j = 0; j < 9; j++) {
        final val = board[j][i];
        if (val < 1 || val > 9 || !colSet.add(val)) return false;
      }
    }

    // 检查每个 3x3 宫
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final boxSet = <int>{};
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            final val = board[boxRow * 3 + i][boxCol * 3 + j];
            if (val < 1 || val > 9 || !boxSet.add(val)) return false;
          }
        }
      }
    }

    return true;
  }
}