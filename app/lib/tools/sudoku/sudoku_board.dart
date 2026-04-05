import 'package:flutter/material.dart';
import 'sudoku_logic.dart';
import 'sudoku_storage.dart';

class SudokuBoard extends StatelessWidget {
  final SudokuState state;
  final int? selectedRow;
  final int? selectedCol;
  final SudokuSettings settings;
  final void Function(int row, int col) onCellTap;

  const SudokuBoard({
    super.key,
    required this.state,
    this.selectedRow,
    this.selectedCol,
    required this.settings,
    required this.onCellTap,
  });

  static const double cellSize = 44.0;
  static const double boardSize = cellSize * 9;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: CustomPaint(
        painter: _BoardPainter(
          state: state,
          selectedRow: selectedRow,
          selectedCol: selectedCol,
          settings: settings,
        ),
        child: GestureDetector(
          onTapUp: (details) {
            final col = (details.localPosition.dx / cellSize).floor();
            final row = (details.localPosition.dy / cellSize).floor();
            if (row >= 0 && row < 9 && col >= 0 && col < 9) {
              onCellTap(row, col);
            }
          },
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final SudokuState state;
  final int? selectedRow;
  final int? selectedCol;
  final SudokuSettings settings;

  _BoardPainter({
    required this.state,
    this.selectedRow,
    this.selectedCol,
    required this.settings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Draw highlights
    if (selectedRow != null && selectedCol != null) {
      final highlightPaint = Paint()..color = Colors.blue.withValues(alpha: 0.1);
      // Highlight row
      for (int c = 0; c < 9; c++) {
        canvas.drawRect(
          Rect.fromLTWH(
            c * SudokuBoard.cellSize,
            selectedRow! * SudokuBoard.cellSize,
            SudokuBoard.cellSize,
            SudokuBoard.cellSize,
          ),
          highlightPaint,
        );
      }
      // Highlight column
      for (int r = 0; r < 9; r++) {
        canvas.drawRect(
          Rect.fromLTWH(
            selectedCol! * SudokuBoard.cellSize,
            r * SudokuBoard.cellSize,
            SudokuBoard.cellSize,
            SudokuBoard.cellSize,
          ),
          highlightPaint,
        );
      }
      // Highlight box
      final boxRow = (selectedRow! ~/ 3) * 3;
      final boxCol = (selectedCol! ~/ 3) * 3;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          canvas.drawRect(
            Rect.fromLTWH(
              (boxCol + j) * SudokuBoard.cellSize,
              (boxRow + i) * SudokuBoard.cellSize,
              SudokuBoard.cellSize,
              SudokuBoard.cellSize,
            ),
            highlightPaint,
          );
        }
      }
    }

    // Draw grid lines
    final thinPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    final thickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Thin lines (non-box boundaries)
    for (int i = 0; i <= 9; i++) {
      final offset = i * SudokuBoard.cellSize;
      if (i % 3 != 0) {
        canvas.drawLine(
          Offset(offset, 0),
          Offset(offset, size.height),
          thinPaint,
        );
        canvas.drawLine(
          Offset(0, offset),
          Offset(size.width, offset),
          thinPaint,
        );
      }
    }

    // Thick lines (box boundaries)
    for (int i = 0; i <= 9; i += 3) {
      final offset = i * SudokuBoard.cellSize;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, size.height),
        thickPaint,
      );
      canvas.drawLine(
        Offset(0, offset),
        Offset(size.width, offset),
        thickPaint,
      );
    }

    // Draw cells
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        _drawCell(canvas, row, col);
      }
    }
  }

  void _drawCell(Canvas canvas, int row, int col) {
    final cell = state.cells[row][col];
    final x = col * SudokuBoard.cellSize;
    final y = row * SudokuBoard.cellSize;
    final center = Offset(
      x + SudokuBoard.cellSize / 2,
      y + SudokuBoard.cellSize / 2,
    );

    // Selected border
    if (row == selectedRow && col == selectedCol) {
      canvas.drawRect(
        Rect.fromLTWH(
          x + 1,
          y + 1,
          SudokuBoard.cellSize - 2,
          SudokuBoard.cellSize - 2,
        ),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Error border
    if (settings.showErrorHighlight && cell.isCorrect == false) {
      canvas.drawRect(
        Rect.fromLTWH(
          x + 2,
          y + 2,
          SudokuBoard.cellSize - 4,
          SudokuBoard.cellSize - 4,
        ),
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Number or notes
    // 显示规则: 用户填入的值优先，否则如果是提示数则显示答案
    final displayValue = cell.userValue ?? (cell.isFixed ? cell.answer : null);
    if (displayValue != null) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: displayValue.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cell.isFixed ? Colors.black : Colors.blue,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    } else if (settings.showCandidates && cell.notes.isNotEmpty) {
      _drawNotes(canvas, x, y, cell.notes);
    }
  }

  void _drawNotes(Canvas canvas, double x, double y, Set<int> notes) {
    final noteSize = SudokuBoard.cellSize / 3;
    for (final note in notes) {
      final noteRow = (note - 1) ~/ 3;
      final noteCol = (note - 1) % 3;
      final textPainter = TextPainter(
        text: TextSpan(
          text: note.toString(),
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final noteX = x + noteCol * noteSize + (noteSize - textPainter.width) / 2;
      final noteY = y + noteRow * noteSize + (noteSize - textPainter.height) / 2;
      textPainter.paint(canvas, Offset(noteX, noteY));
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return state != oldDelegate.state ||
        selectedRow != oldDelegate.selectedRow ||
        selectedCol != oldDelegate.selectedCol ||
        settings != oldDelegate.settings;
  }
}