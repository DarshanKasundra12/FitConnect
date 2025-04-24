import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fitness_coach/core/theme/app_theme.dart';
import 'package:fitness_coach/features/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive for local storage
    await Hive.initFlutter();
    await Hive.openBox('appSettings');
    await Hive.openBox('exerciseCache');
  } catch (e) {
    // Handle initialization errors
    print('Error initializing Hive: $e');
    // Create default boxes if needed
    if (!Hive.isBoxOpen('appSettings')) {
      await Hive.openBox('appSettings');
    }
    if (!Hive.isBoxOpen('exerciseCache')) {
      await Hive.openBox('exerciseCache');
    }
  }
  
  runApp(
    const ProviderScope(
      child: FitnessCoachApp(),
    ),
  );
}

class FitnessCoachApp extends ConsumerWidget {
  const FitnessCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'FitConnect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}
