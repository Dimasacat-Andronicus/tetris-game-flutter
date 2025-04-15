import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './tetris/tetris_cubit.dart';
import './tetris/tetris_screen.dart';

void main() {
  runApp(BlocProvider(create: (_) => TetrisCubit(), child: const TetrisApp()));
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple[400],
        scaffoldBackgroundColor: Colors.deepPurple[400],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[400],
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.deepPurple[400],
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: const TetrisGame(),
    );
  }
}
