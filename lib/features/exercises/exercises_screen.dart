import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach/core/models/exercise.dart';
import 'package:fitness_coach/core/services/exercise_service.dart';
import 'package:fitness_coach/features/exercises/exercise_detail_screen.dart';
import 'package:fitness_coach/shared/widgets/exercise_card.dart';

// Selected body part filter provider
final selectedBodyPartProvider = StateProvider<String?>((ref) => null);

// List of body parts for filter
final bodyPartsProvider = Provider<List<String>>((ref) {
  return [
    'Chest',
    'Back',
    'Legs',
    'Arms',
    'Shoulders',
    'Core',
  ];
});

class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBodyPart = ref.watch(selectedBodyPartProvider);
    final bodyParts = ref.watch(bodyPartsProvider);
    final exercisesAsync = ref.watch(exercisesProvider(selectedBodyPart));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                // Search functionality would go here
                // For simplicity, we're not implementing full search
              },
            ),
          ),
          
          // Body part filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: selectedBodyPart == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(selectedBodyPartProvider.notifier).state = null;
                      }
                    },
                  ),
                ),
                ...bodyParts.map((bodyPart) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(bodyPart),
                      selected: selectedBodyPart == bodyPart,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedBodyPartProvider.notifier).state = bodyPart;
                        } else if (selectedBodyPart == bodyPart) {
                          ref.read(selectedBodyPartProvider.notifier).state = null;
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          
          // Exercise list
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                return RefreshIndicator(
                  onRefresh: () async {
                    // Clear cache and refresh
                    await ref.read(exerciseServiceProvider).clearCache();
                    ref.refresh(exercisesProvider(selectedBodyPart));
                  },
                  child: exercises.isEmpty
                      ? const Center(
                          child: Text('No exercises found'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ExerciseCard(
                                exercise: exercise,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExerciseDetailScreen(
                                        exerciseId: exercise.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
