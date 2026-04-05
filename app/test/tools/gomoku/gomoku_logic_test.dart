import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/gomoku/gomoku_models.dart';
import 'package:littlegrid/tools/gomoku/gomoku_logic.dart';

void main() {
  group('GomokuLogic', () {
    test('initial state should have empty board and black player first', () {
      final logic = GomokuLogic();
      expect(logic.state.currentPlayer, Stone.black);
      expect(logic.state.history.isEmpty, true);
      expect(logic.state.isGameOver, false);
    });

    test('placeStone should place stone and switch player', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);

      expect(logic.state.board[50][50], Stone.black);
      expect(logic.state.currentPlayer, Stone.white);
      expect(logic.state.history.length, 1);
    });

    test('placeStone should not work on occupied cell', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);
      logic.placeStone(50, 50);

      expect(logic.state.board[50][50], Stone.black);
      expect(logic.state.currentPlayer, Stone.white);
    });

    test('undo should remove last stone', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);
      logic.undo();

      expect(logic.state.board[50][50], Stone.empty);
      expect(logic.state.currentPlayer, Stone.black);
      expect(logic.state.history.isEmpty, true);
    });

    test('detect horizontal win', () {
      final logic = GomokuLogic();
      // Black places 5 stones horizontally
      for (int i = 0; i < 5; i++) {
        logic.placeStone(50, 50 + i);
        if (i < 4) logic.placeStone(51, 50 + i); // White places elsewhere
      }

      expect(logic.state.isGameOver, true);
      expect(logic.state.winner, Stone.black);
    });

    test('detect vertical win', () {
      final logic = GomokuLogic();
      for (int i = 0; i < 5; i++) {
        logic.placeStone(50 + i, 50);
        if (i < 4) logic.placeStone(50 + i, 51);
      }

      expect(logic.state.isGameOver, true);
      expect(logic.state.winner, Stone.black);
    });

    test('detect diagonal win', () {
      final logic = GomokuLogic();
      for (int i = 0; i < 5; i++) {
        logic.placeStone(50 + i, 50 + i);
        if (i < 4) logic.placeStone(50 + i, 52);
      }

      expect(logic.state.isGameOver, true);
      expect(logic.state.winner, Stone.black);
    });

    test('reset should clear the board', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);
      logic.reset();

      expect(logic.state.board[50][50], Stone.empty);
      expect(logic.state.currentPlayer, Stone.black);
      expect(logic.state.history.isEmpty, true);
      expect(logic.state.isGameOver, false);
    });
  });
}