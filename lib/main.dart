import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ),
      home: const TetrisGame(),
    );
  }
}

class TetrisGame extends StatefulWidget {
  const TetrisGame({super.key});

  @override
  State<TetrisGame> createState() => _TetrisGameState();
}

class _TetrisGameState extends State<TetrisGame> {
  static const int rows = 20;
  static const int columns = 10;
  List<List<Color?>> grid = List.generate(
    rows,
    (_) => List.generate(columns, (_) => null),
  );

  Timer? gameTimer;
  Timer? holdTimer;
  List<List<int>> currentTetromino = [];
  int currentRow = 0;
  int currentColumn = columns ~/ 2;
  int score = 0;
  bool isGameOver = false;
  bool isGameStarted = false;
  int highScore = 0;

  final tetrominoes = [
    // I shape
    [
      [1, 1, 1, 1],
    ],

    // O shape
    [
      [1, 1],
      [1, 1],
    ],

    // T shape
    [
      [0, 1, 0],
      [1, 1, 1],
    ],

    // S shape
    [
      [0, 1, 1],
      [1, 1, 0],
    ],

    // Z shape
    [
      [1, 1, 0],
      [0, 1, 1],
    ],

    // J shape
    [
      [1, 0, 0],
      [1, 1, 1],
    ],

    // L shape
    [
      [0, 0, 1],
      [1, 1, 1],
    ],
  ];

  final tetrominoColors = [
    Colors.cyan, // I shape
    Colors.yellow, // O shape
    Colors.purple, // T shape
    Colors.green, // S shape
    Colors.red, // Z shape
    Colors.blue, // J shape
    Colors.orange, // L shape
  ];

  Color currentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  void startGame() {
    setState(() {
      grid = List.generate(rows, (_) => List.generate(columns, (_) => null));
      score = 0;
      isGameOver = false;
      isGameStarted = true;
    });
    holdTimer?.cancel(); // Cancel any existing holdTimer
    spawnTetromino();
    gameTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        moveDown();
      });
    });
  }

  void spawnTetromino() {
    final index = DateTime.now().millisecondsSinceEpoch % tetrominoes.length;
    currentTetromino = tetrominoes[index];
    currentColor = tetrominoColors[index];
    currentRow = 0;
    currentColumn = columns ~/ 2 - currentTetromino[0].length ~/ 2;

    if (checkCollision(currentRow, currentColumn)) {
      gameOver();
    }
  }

  void gameOver() {
    setState(() {
      isGameOver = true;
      isGameStarted = false;
    });

    if (score > highScore) {
      setState(() {
        highScore = score;
      });
      _saveHighScore();
    }

    gameTimer?.cancel();
    holdTimer?.cancel();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
  }

  bool checkCollision(int newRow, int newColumn) {
    for (int i = 0; i < currentTetromino.length; i++) {
      for (int j = 0; j < currentTetromino[i].length; j++) {
        if (currentTetromino[i][j] == 1) {
          int gridRow = newRow + i;
          int gridColumn = newColumn + j;
          if (gridRow >= rows ||
              gridColumn < 0 ||
              gridColumn >= columns ||
              (gridRow >= 0 && grid[gridRow][gridColumn] != null)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void moveDown() {
    if (!checkCollision(currentRow + 1, currentColumn)) {
      currentRow++;
    } else {
      lockPiece();
    }
  }

  void moveLeft() {
    if (!checkCollision(currentRow, currentColumn - 1)) {
      setState(() {
        currentColumn--;
      });
    }
  }

  void moveRight() {
    if (!checkCollision(currentRow, currentColumn + 1)) {
      setState(() {
        currentColumn++;
      });
    }
  }

  void pauseGame() {
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const TetrisGame()),
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
    gameTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        moveDown();
      });
    });
  }

  void rotateTetromino() {
    final rotated = List.generate(
      currentTetromino[0].length,
      (i) => List.generate(
        currentTetromino.length,
        (j) => currentTetromino[currentTetromino.length - j - 1][i],
      ),
    );

    // Save the current state in case rotation causes a collision
    final previousTetromino = currentTetromino;

    setState(() {
      currentTetromino = rotated;
    });

    // Check for collision after rotation
    if (checkCollision(currentRow, currentColumn)) {
      // Revert to the previous state if collision occurs
      setState(() {
        currentTetromino = previousTetromino;
      });
    }
  }

  void clearFullLines() {
    setState(() {
      int linesCleared = 0;

      for (int row = rows - 1; row >= 0; row--) {
        if (grid[row].every((cell) => cell != null)) {
          grid.removeAt(row);
          grid.insert(0, List.generate(columns, (_) => null));
          linesCleared++;
          row++;
        }
      }

      // Update the score based on the number of lines cleared
      switch (linesCleared) {
        case 1:
          score += 100;
          break;
        case 2:
          score += 250;
          break;
        case 3:
          score += 375;
          break;
        case 4:
          score += 500;
          break;
      }
    });
  }

  void lockPiece() {
    for (int i = 0; i < currentTetromino.length; i++) {
      for (int j = 0; j < currentTetromino[i].length; j++) {
        if (currentTetromino[i][j] == 1) {
          grid[currentRow + i][currentColumn + j] = currentColor;
        }
      }
    }
    clearFullLines();
    spawnTetromino();
  }

  void holdDownStart() {
    holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        moveDown();
      });
    });
  }

  void holdDownStop() {
    holdTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tetris Game'),
        centerTitle: true,
        actions:
            isGameStarted && !isGameOver
                ? [
                  IconButton(
                    onPressed: pauseGame,
                    icon: const Icon(Icons.pause),
                  ),
                ]
                : null,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isGameStarted && !isGameOver)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/tetris_animation_two.json',
                      width: 400,
                      height: 400,
                    ),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    onPressed: startGame,
                    child: const Text('Play'),
                  ),
                ],
              ),
            )
          else if (!isGameStarted && isGameOver)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGameOver)
                    Column(
                      children: [
                        const Text(
                          'Game Over',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Your Score: $score',
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          'High Score: $highScore',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ElevatedButton(
                    onPressed: startGame,
                    child: const Text('Play again'),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate the available height for the grid
                  final availableHeight = constraints.maxHeight;
                  final buttonHeight =
                      100.0; // Approximate height of the buttons
                  final gridHeight = availableHeight - buttonHeight;

                  // Calculate the size of each cell based on the grid height and number of rows
                  final cellSize = gridHeight / rows;

                  return Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    // Adjust the top padding to bring the grid down
                    child: SizedBox(
                      height: gridHeight,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        // Disable scrolling
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio:
                              constraints.maxWidth /
                              (cellSize * columns), // Adjust aspect ratio
                        ),
                        itemCount: rows * columns,
                        itemBuilder: (context, index) {
                          int row = index ~/ columns;
                          int column = index % columns;
                          Color? color = grid[row][column];
                          if (row >= currentRow &&
                              row < currentRow + currentTetromino.length &&
                              column >= currentColumn &&
                              column <
                                  currentColumn + currentTetromino[0].length &&
                              currentTetromino[row - currentRow][column -
                                      currentColumn] ==
                                  1) {
                            color = currentColor;
                          }
                          return Container(
                            margin: const EdgeInsets.all(1),
                            color: color ?? Colors.grey[300],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          if (isGameStarted && !isGameOver)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Score: $score', style: const TextStyle(fontSize: 24)),
                    Text(
                      'High Score: $highScore',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: moveLeft,
                      icon: const Icon(Icons.arrow_left),
                      iconSize: 36.0, // Increased icon size
                    ),
                    IconButton(
                      onPressed: moveRight,
                      icon: const Icon(Icons.arrow_right),
                      iconSize: 36.0, // Increased icon size
                    ),
                    IconButton(
                      onPressed: rotateTetromino,
                      icon: const Icon(Icons.rotate_right),
                      iconSize: 36.0, // Increased icon size
                    ),
                    GestureDetector(
                      onTapDown: (_) => holdDownStart(),
                      onTapUp: (_) => holdDownStop(),
                      child: const SizedBox(
                        width: 48.0, // Increased tap area width
                        height: 48.0, // Increased tap area height
                        child: Icon(
                          Icons.arrow_downward,
                          size: 36.0,
                        ), // Increased icon size
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    holdTimer?.cancel();
    super.dispose();
  }
}
