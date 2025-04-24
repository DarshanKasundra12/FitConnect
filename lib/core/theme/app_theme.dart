import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Color schemes
class AppTheme {
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.dark,
  );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.primaryContainer,
      foregroundColor: _lightColorScheme.onPrimaryContainer,
    ),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: _lightColorScheme.surface,
      selectedIconTheme: IconThemeData(color: _lightColorScheme.primary),
      indicatorColor: _lightColorScheme.primaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      indicatorColor: _lightColorScheme.primaryContainer,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.primaryContainer,
      foregroundColor: _darkColorScheme.onPrimaryContainer,
    ),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: _darkColorScheme.surface,
      selectedIconTheme: IconThemeData(color: _darkColorScheme.primary),
      indicatorColor: _darkColorScheme.primaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _darkColorScheme.surface,
      indicatorColor: _darkColorScheme.primaryContainer,
    ),
  );
}
