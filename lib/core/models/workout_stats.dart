import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class WorkoutStats {
  final int totalWorkouts;
  final double averageBmi;

  WorkoutStats({
    required this.totalWorkouts,
    required this.averageBmi,
  });

  // Load stats from storage
  static WorkoutStats loadFromStorage() {
    final box = Hive.box('appSettings');
    return WorkoutStats(
      totalWorkouts: box.get('totalWorkouts', defaultValue: 0),
      averageBmi: box.get('averageBmi', defaultValue: 0.0),
    );
  }

  // Save stats to storage
  Future<void> saveToStorage() async {
    final box = Hive.box('appSettings');
    await box.put('totalWorkouts', totalWorkouts);
    await box.put('averageBmi', averageBmi);
  }

  // Create a copy with updated values
  WorkoutStats copyWith({
    int? totalWorkouts,
    double? averageBmi,
  }) {
    return WorkoutStats(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      averageBmi: averageBmi ?? this.averageBmi,
    );
  }
}

// Provider for workout stats
final workoutStatsProvider = StateProvider<WorkoutStats>((ref) {
  return WorkoutStats.loadFromStorage();
});

// Function to update workout stats
void updateWorkoutStats(WidgetRef ref, {int? workouts, double? bmi}) {
  final currentStats = ref.read(workoutStatsProvider);
  
  final updatedStats = currentStats.copyWith(
    totalWorkouts: workouts != null ? currentStats.totalWorkouts + workouts : null,
    averageBmi: bmi != null ? bmi : null,
  );
  
  ref.read(workoutStatsProvider.notifier).state = updatedStats;
  updatedStats.saveToStorage();
}
