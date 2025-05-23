part of 'tetris_cubit.dart';

class TetrisState {
  final List<List<Color?>> grid;
  final List<List<int>> currentTetromino;
  final int currentRow;
  final int currentColumn;
  final int score;
  final int highScore;
  final bool isGameOver;
  final bool isGameStarted;
  final Color currentColor;
  final List<List<int>>? nextTetromino;
  final Color? nextColor;
  final bool showAnimation;
  final bool isMusicPlaying;

  TetrisState({
    required this.grid,
    required this.currentTetromino,
    required this.currentRow,
    required this.currentColumn,
    required this.score,
    required this.highScore,
    required this.isGameOver,
    required this.isGameStarted,
    required this.currentColor,
    this.nextTetromino,
    this.nextColor,
    required this.showAnimation,
    required this.isMusicPlaying,
  });

  TetrisState copyWith({
    List<List<Color?>>? grid,
    List<List<int>>? currentTetromino,
    int? currentRow,
    int? currentColumn,
    int? score,
    int? highScore,
    bool? isGameOver,
    bool? isGameStarted,
    Color? currentColor,
    List<List<int>>? nextTetromino,
    Color? nextColor,
    bool? showAnimation,
    bool? isMusicPlaying,
  }) {
    return TetrisState(
      grid: grid ?? this.grid,
      currentTetromino: currentTetromino ?? this.currentTetromino,
      currentRow: currentRow ?? this.currentRow,
      currentColumn: currentColumn ?? this.currentColumn,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      isGameOver: isGameOver ?? this.isGameOver,
      isGameStarted: isGameStarted ?? this.isGameStarted,
      currentColor: currentColor ?? this.currentColor,
      nextTetromino: nextTetromino ?? this.nextTetromino,
      nextColor: nextColor ?? this.nextColor,
      showAnimation: showAnimation ?? this.showAnimation,
      isMusicPlaying: isMusicPlaying ?? this.isMusicPlaying,
    );
  }
}
