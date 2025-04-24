import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fitness_coach/core/services/exercise_service.dart';
import 'package:fitness_coach/core/models/workout_stats.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final int exerciseId;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseDetailsProvider(exerciseId));
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
      ),
      body: exerciseAsync.when(
        data: (exercise) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise image with hero animation
                Hero(
                  tag: 'exercise-image-${exercise.id}',
                  child: SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: exercise.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise name
                      Text(
                        exercise.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Target muscle and difficulty
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            exercise.primaryMuscle,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(exercise.difficulty, theme),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              exercise.difficulty,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        'Description',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        exercise.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      
                      // Instructions
                      Text(
                        'Instructions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...exercise.instructions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  step,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      
                      // YouTube tutorial button
                      ElevatedButton.icon(
                        onPressed: () {
                          // Launch YouTube search for this exercise
                          final url = Uri.parse(
                            'https://www.youtube.com/results?search_query=${Uri.encodeComponent('${exercise.name} exercise tutorial')}',
                          );
                          launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.play_circle),
                        label: const Text('Watch Tutorial on YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Start a timer for this exercise
          _showTimerDialog(context, ref);
        },
        icon: const Icon(Icons.timer),
        label: const Text('Start Timer'),
      ),
    );
  }
  
  Color _getDifficultyColor(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }
  
  void _showTimerDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => TimerDialog(
        onComplete: () {
          // Update workout stats when timer completes
          updateWorkoutStats(ref, workouts: 1);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout completed! Stats updated.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}

class TimerDialog extends StatefulWidget {
  final VoidCallback onComplete;

  const TimerDialog({
    super.key,
    required this.onComplete,
  });

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _duration = 60; // Default 60 seconds
  bool _isRunning = false;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _duration),
    );
    
    _controller.addListener(() {
      setState(() {
        _remainingSeconds = (_duration * (1 - _controller.value)).ceil();
      });
      
      if (_controller.isCompleted) {
        _isRunning = false;
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _controller.forward(from: 0);
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _controller.stop();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = _duration;
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Exercise Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Timer display
          Text(
            '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          
          // Progress indicator
          LinearProgressIndicator(
            value: 1 - _controller.value,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 16),
          
          // Duration selector
          if (!_isRunning)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _duration > 30 ? () {
                    setState(() {
                      _duration -= 30;
                      _remainingSeconds = _duration;
                    });
                    _controller.duration = Duration(seconds: _duration);
                  } : null,
                  child: const Text('-30s'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _duration += 30;
                      _remainingSeconds = _duration;
                    });
                    _controller.duration = Duration(seconds: _duration);
                  },
                  child: const Text('+30s'),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        if (_isRunning)
          TextButton(
            onPressed: _pauseTimer,
            child: const Text('Pause'),
          )
        else
          TextButton(
            onPressed: _startTimer,
            child: Text(_controller.value > 0 ? 'Resume' : 'Start'),
          ),
        TextButton(
          onPressed: _resetTimer,
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
