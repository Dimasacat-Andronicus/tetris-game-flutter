import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import './tetris_cubit.dart';

class TetrisGame extends StatelessWidget {
  const TetrisGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BlocBuilder<TetrisCubit, TetrisState>(
          builder: (context, state) {
            if (state.isGameStarted && !state.isGameOver) {
              return IconButton(
                onPressed: () => context.read<TetrisCubit>().pauseGame(context),
                icon: const Icon(Icons.pause),
                iconSize: 32.0,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        actions: [
          BlocBuilder<TetrisCubit, TetrisState>(
            builder: (context, state) {
              if (state.isGameStarted && !state.isGameOver) {
                if (state.nextTetromino != null) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          state.nextTetromino!.map((row) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  row.map((cell) {
                                    return Container(
                                      width: 15,
                                      height: 15,
                                      margin: const EdgeInsets.all(1),
                                      color:
                                          cell == 1
                                              ? state.nextColor
                                              : Colors.transparent,
                                    );
                                  }).toList(),
                            );
                          }).toList(),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocBuilder<TetrisCubit, TetrisState>(
            builder: (context, state) {
              if (!state.isGameStarted && !state.isGameOver) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/tetris_plus.png',
                        width: 210,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Lottie.asset(
                        'assets/tetris_animation_two.json',
                        width: 275,
                        height: 275,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed:
                            () => context.read<TetrisCubit>().startGame(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 50),
                          textStyle: const TextStyle(fontSize: 26),
                        ),
                        child: const Text('Play'),
                      ),
                    ],
                  ),
                );
              } else if (!state.isGameStarted && state.isGameOver) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Your Score: ${state.score}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'High Score: ${state.highScore}',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed:
                            () => context.read<TetrisCubit>().startGame(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 50),
                          textStyle: const TextStyle(fontSize: 24),
                        ),
                        child: const Text('Play Again'),
                      ),
                    ],
                  ),
                );
              } else {
                return Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        // Add padding around the grid
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final cellSize =
                                constraints.maxHeight / TetrisCubit.rows;
                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: TetrisCubit.columns,
                                    childAspectRatio:
                                        constraints.maxWidth /
                                        (cellSize * TetrisCubit.columns),
                                  ),
                              itemCount: TetrisCubit.rows * TetrisCubit.columns,
                              itemBuilder: (context, index) {
                                int row = index ~/ TetrisCubit.columns;
                                int column = index % TetrisCubit.columns;
                                Color? color = state.grid[row][column];
                                if (row >= state.currentRow &&
                                    row <
                                        state.currentRow +
                                            state.currentTetromino.length &&
                                    column >= state.currentColumn &&
                                    column <
                                        state.currentColumn +
                                            state.currentTetromino[0].length &&
                                    state.currentTetromino[row -
                                            state.currentRow][column -
                                            state.currentColumn] ==
                                        1) {
                                  color = state.currentColor;
                                }
                                return Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color:
                                        color ??
                                        const Color.fromARGB(
                                          200,
                                          255,
                                          255,
                                          255,
                                        ),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                        128,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Score: ${state.score}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'High Score: ${state.highScore}',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            context.read<TetrisCubit>().holdTimer?.cancel();
                            context.read<TetrisCubit>().moveLeft();
                          },
                          icon: const Icon(
                            Icons.arrow_left,
                            color: Colors.white,
                          ),
                          iconSize: 36.0,
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<TetrisCubit>().holdTimer?.cancel();
                            context.read<TetrisCubit>().moveRight();
                          },
                          icon: const Icon(
                            Icons.arrow_right,
                            color: Colors.white,
                          ),
                          iconSize: 36.0,
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<TetrisCubit>().holdTimer?.cancel();
                            context.read<TetrisCubit>().rotateTetromino();
                          },
                          icon: const Icon(
                            Icons.rotate_right,
                            color: Colors.white,
                          ),
                          iconSize: 36.0,
                        ),
                        GestureDetector(
                          onTapDown: (_) {
                            context.read<TetrisCubit>().holdTimer?.cancel();
                            context
                                .read<TetrisCubit>()
                                .holdTimer = Timer.periodic(
                              const Duration(milliseconds: 100),
                              (_) => context.read<TetrisCubit>().moveDown(),
                            );
                          },
                          onTapUp: (_) {
                            context.read<TetrisCubit>().holdTimer?.cancel();
                          },
                          child: const Icon(
                            Icons.arrow_downward,
                            size: 36.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              }
            },
          ),
          BlocBuilder<TetrisCubit, TetrisState>(
            builder: (context, state) {
              if (state.showAnimation) {
                return Stack(
                  children: [
                    ConfettiWidget(
                      confettiController: ConfettiController(
                        duration: const Duration(seconds: 2),
                      )..play(),
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                    ),
                    Center(
                      child: Text(
                        'Animation',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
