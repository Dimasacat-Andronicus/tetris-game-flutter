import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import './tetris_cubit.dart';

class TetrisGame extends StatelessWidget {
  const TetrisGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tetris Game'),
        centerTitle: true,
        actions: [
          BlocBuilder<TetrisCubit, TetrisState>(
            builder: (context, state) {
              if (state.isGameStarted && !state.isGameOver) {
                return IconButton(
                  onPressed:
                      () => context.read<TetrisCubit>().pauseGame(context),
                  icon: const Icon(Icons.pause),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TetrisCubit, TetrisState>(
        builder: (context, state) {
          if (!state.isGameStarted && !state.isGameOver) {
            return Center(
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
                    onPressed: () => context.read<TetrisCubit>().startGame(),
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
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your Score: ${state.score}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    'High Score: ${state.highScore}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.read<TetrisCubit>().startGame(),
                    child: const Text('Play Again'),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cellSize = constraints.maxHeight / TetrisCubit.rows;
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            margin: const EdgeInsets.all(1),
                            color: color ?? Colors.grey[300],
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Score: ${state.score}',
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      'High Score: ${state.highScore}',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => context.read<TetrisCubit>().moveLeft(),
                      icon: const Icon(Icons.arrow_left),
                      iconSize: 36.0,
                    ),
                    IconButton(
                      onPressed: () => context.read<TetrisCubit>().moveRight(),
                      icon: const Icon(Icons.arrow_right),
                      iconSize: 36.0,
                    ),
                    IconButton(
                      onPressed:
                          () => context.read<TetrisCubit>().rotateTetromino(),
                      icon: const Icon(Icons.rotate_right),
                      iconSize: 36.0,
                    ),
                    GestureDetector(
                      onTapDown:
                          (_) =>
                              context
                                  .read<TetrisCubit>()
                                  .holdTimer = Timer.periodic(
                                const Duration(milliseconds: 100),
                                (_) => context.read<TetrisCubit>().moveDown(),
                              ),
                      onTapUp:
                          (_) =>
                              context.read<TetrisCubit>().holdTimer?.cancel(),
                      child: const Icon(Icons.arrow_downward, size: 36.0),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            );
          }
        },
      ),
    );
  }
}
