import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

class BibleTrackerApp extends StatelessWidget {
  const BibleTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Deep navy dark colour scheme
    const seed = Color(0xFF3B82F6); // blue-500
    final darkScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      // Force a true near-black navy surface so the background has a blue tinge
      surface: const Color(0xFF0D1117),
      onSurface: const Color(0xFFE2E8F0),
      surfaceContainerHighest: const Color(0xFF161D27),
    );

    return MaterialApp(
      title: 'BibleLog',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      ),
      darkTheme: ThemeData(
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: const Color(0xFF0D1117),
          foregroundColor: darkScheme.onSurface,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
