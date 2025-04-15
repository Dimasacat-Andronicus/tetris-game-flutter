import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

part 'tetris_state.dart';

class TetrisCubit extends Cubit<TetrisState> {
  static const int rows = 20;
  static const int columns = 10;
  bool isMovingDown = false;

  Timer? gameTimer;
  Timer? holdTimer;

  final tetrominoes = [
    [
      [1, 1, 1, 1],
    ], // I shape
    [
      [1, 1],
      [1, 1],
    ], // O shape
    [
      [0, 1, 0],
      [1, 1, 1],
    ], // T shape
    [
      [0, 1, 1],
      [1, 1, 0],
    ], // S shape
    [
      [1, 1, 0],
      [0, 1, 1],
    ], // Z shape
    [
      [1, 0, 0],
      [1, 1, 1],
    ], // J shape
    [
      [0, 0, 1],
      [1, 1, 1],
    ], // L shape
  ];

  final tetrominoColors = [
    Colors.teal[300]!,
    Colors.amber[300]!,
    Colors.green[300]!,
    Colors.cyan[300]!,
    Colors.pink[300]!,
    Colors.lime[300]!,
    Colors.orange[300]!,
  ];

  TetrisCubit()
    : super(
        TetrisState(
          grid: List.generate(rows, (_) => List.generate(columns, (_) => null)),
          currentTetromino: [],
          currentRow: 0,
          currentColumn: columns ~/ 2,
          score: 0,
          highScore: 0,
          isGameOver: false,
          isGameStarted: false,
          currentColor: Colors.blue,
          showAnimation: false,
        ),
      ) {
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(highScore: prefs.getInt('highScore') ?? 0));
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', state.highScore);
  }

  void startGame() {
    emit(
      state.copyWith(
        grid: List.generate(rows, (_) => List.generate(columns, (_) => null)),
        score: 0,
        isGameOver: false,
        isGameStarted: true,
      ),
    );
    holdTimer?.cancel();
    spawnTetromino();
    gameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      moveDown();
    });
  }

  void spawnTetromino() {
    final newTetromino = state.nextTetromino ?? tetrominoes[0];
    final newColor = state.nextColor ?? tetrominoColors[0];

    final nextIndex =
        DateTime.now().millisecondsSinceEpoch % tetrominoes.length;
    final nextTetromino = tetrominoes[nextIndex];
    final nextColor = tetrominoColors[nextIndex];

    final newRow = 0;
    final newColumn = columns ~/ 2 - newTetromino[0].length ~/ 2;

    if (checkCollision(newRow, newColumn)) {
      gameOver();
    } else {
      emit(
        state.copyWith(
          currentTetromino: newTetromino,
          currentColor: newColor,
          currentRow: newRow,
          currentColumn: newColumn,
          nextTetromino: nextTetromino,
          nextColor: nextColor,
        ),
      );
    }
  }

  void checkLinesDestroyed(int linesDestroyed) {
    if (linesDestroyed == 3 || linesDestroyed == 4) {
      emit(state.copyWith(showAnimation: true));
      Future.delayed(const Duration(seconds: 2), () {
        emit(state.copyWith(showAnimation: false));
      });
    }
  }

  void moveDown() {
    if (isMovingDown) return;
    isMovingDown = true;

    if (!checkCollision(state.currentRow + 1, state.currentColumn)) {
      emit(state.copyWith(currentRow: state.currentRow + 1));
    } else {
      lockPiece();
    }

    isMovingDown = false;
  }

  void moveLeft() {
    if (!checkCollision(state.currentRow, state.currentColumn - 1)) {
      emit(state.copyWith(currentColumn: state.currentColumn - 1));
    }
  }

  void moveRight() {
    if (!checkCollision(state.currentRow, state.currentColumn + 1)) {
      emit(state.copyWith(currentColumn: state.currentColumn + 1));
    }
  }

  void rotateTetromino() {
    final rotated = List.generate(
      state.currentTetromino[0].length,
      (i) => List.generate(
        state.currentTetromino.length,
        (j) => state.currentTetromino[state.currentTetromino.length - j - 1][i],
      ),
    );

    int newRow = state.currentRow;
    int newColumn = state.currentColumn;

    while (newColumn < 0) {
      newColumn++;
    }
    while (newColumn + rotated[0].length > columns) {
      newColumn--;
    }
    while (newRow + rotated.length > rows) {
      newRow--;
    }

    if (!checkCollision(newRow, newColumn, rotated)) {
      emit(
        state.copyWith(
          currentTetromino: rotated,
          currentRow: newRow,
          currentColumn: newColumn,
        ),
      );
    }
  }

  bool checkCollision(int newRow, int newColumn, [List<List<int>>? tetromino]) {
    final piece = tetromino ?? state.currentTetromino;

    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] == 1) {
          int gridRow = newRow + i;
          int gridColumn = newColumn + j;
          if (gridRow >= rows ||
              gridColumn < 0 ||
              gridColumn >= columns ||
              (gridRow >= 0 && state.grid[gridRow][gridColumn] != null)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void lockPiece() {
    final newGrid = List<List<Color?>>.from(state.grid);
    for (int i = 0; i < state.currentTetromino.length; i++) {
      for (int j = 0; j < state.currentTetromino[i].length; j++) {
        if (state.currentTetromino[i][j] == 1) {
          newGrid[state.currentRow + i][state.currentColumn + j] =
              state.currentColor;
        }
      }
    }
    clearFullLines(newGrid);
    spawnTetromino();
  }

  void clearFullLines(List<List<Color?>> grid) {
    int linesCleared = 0;

    for (int row = rows - 1; row >= 0; row--) {
      if (grid[row].every((cell) => cell != null)) {
        grid.removeAt(row);
        grid.insert(0, List.generate(columns, (_) => null));
        linesCleared++;
        row++;
      }
    }

    int newScore = state.score;
    switch (linesCleared) {
      case 1:
        newScore += 100;
        break;
      case 2:
        newScore += 250;
        break;
      case 3:
        newScore += 375;
        break;
      case 4:
        newScore += 500;
        break;
    }

    emit(state.copyWith(grid: grid, score: newScore));

    if (newScore > state.highScore) {
      emit(state.copyWith(highScore: newScore));
      _saveHighScore();
    }

    checkLinesDestroyed(linesCleared);
  }

  void gameOver() {
    emit(state.copyWith(isGameOver: true, isGameStarted: false));
    gameTimer?.cancel();
    holdTimer?.cancel();
  }

  void pauseGame(BuildContext context) {
    gameTimer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Paused'),
          content: const Text('What would you like to do?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                resumeGame();
              },
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                startGame(); // Restart the game
              },
              child: const Text('Restart'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                emit(state.copyWith(isGameStarted: false, isGameOver: false));
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const TetrisApp()),
                  (route) => false, // Remove all previous routes
                );
              },
              child: const Text('Quit'),
            ),
          ],
        );
      },
    );
  }

  void resumeGame() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      moveDown();
    });
  }

  @override
  Future<void> close() {
    gameTimer?.cancel();
    holdTimer?.cancel();
    return super.close();
  }
}
