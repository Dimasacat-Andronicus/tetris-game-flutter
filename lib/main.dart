import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './tetris/tetris_cubit.dart';
import './tetris/tetris_screen.dart';

void main() {
  runApp(
    BlocProvider(
        create: (_) => TetrisCubit(),
        child: const TetrisApp()
    )
  );
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