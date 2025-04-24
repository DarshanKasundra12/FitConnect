import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach/core/models/workout_stats.dart';
import 'package:fitness_coach/shared/widgets/stat_card.dart';
import 'package:fitness_coach/features/app_shell.dart';
import 'package:fitness_coach/features/home/home_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(workoutStatsProvider);
    final theme = Theme.of(context);
    
    // Motivational images
    final motivationalImages = [
      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FitConnect'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Motivational image carousel
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: HomeCarousel(imageUrls: motivationalImages),
            ),
            
            // Stats section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Stats',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total Workouts',
                          value: stats.totalWorkouts.toString(),
                          icon: Icons.fitness_center,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Average BMI',
                          value: stats.averageBmi > 0 
                              ? stats.averageBmi.toStringAsFixed(1) 
                              : 'N/A',
                          icon: Icons.monitor_weight,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Quick start section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Start',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: InkWell(
                      onTap: () {
                        // Navigate to exercises tab
                        ref.read(selectedTabProvider.notifier).state = 1;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              size: 48,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Workout',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    'Choose from our exercise library',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: InkWell(
                      onTap: () {
                        // Navigate to BMI tab
                        ref.read(selectedTabProvider.notifier).state = 2;
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calculate,
                              size: 48,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calculate BMI',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    'Check your Body Mass Index',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
