class Exercise {
  final int id;
  final String name;
  final String description;
  final String category;
  final String primaryMuscle;
  final String difficulty;
  final String imageUrl;
  final String? videoUrl;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.primaryMuscle,
    required this.difficulty,
    required this.imageUrl,
    this.videoUrl,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      primaryMuscle: json['muscles'][0]['name'] ?? 'Unknown',
      difficulty: _mapDifficulty(json['difficulty'] ?? 1),
      imageUrl: json['images'].isNotEmpty 
          ? json['images'][0]['image'] 
          : 'https://wger.de/static/images/placeholder.png',
      videoUrl: null,
      instructions: _parseInstructions(json['description'] ?? ''),
    );
  }

  static String _mapDifficulty(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      case 3:
        return 'Advanced';
      default:
        return 'Beginner';
    }
  }

  static List<String> _parseInstructions(String description) {
    // Simple parsing of instructions from description
    final steps = description.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    
    if (steps.isEmpty) {
      return ['No instructions available.'];
    }
    
    return steps;
  }

  // Mock data for offline mode
  static List<Exercise> getMockExercises() {
    return [
      Exercise(
        id: 1,
        name: 'Push-up',
        description: 'A classic bodyweight exercise for upper body strength.',
        category: 'Strength',
        primaryMuscle: 'Chest',
        difficulty: 'Beginner',
        imageUrl: 'https://wger.de/static/images/placeholder.png',
        instructions: [
          'Start in a plank position with hands shoulder-width apart.',
          'Lower your body until your chest nearly touches the floor.',
          'Push back up to the starting position.',
          'Repeat for desired reps.'
        ],
      ),
      Exercise(
        id: 2,
        name: 'Squat',
        description: 'A fundamental lower body exercise.',
        category: 'Strength',
        primaryMuscle: 'Legs',
        difficulty: 'Beginner',
        imageUrl: 'https://wger.de/static/images/placeholder.png',
        instructions: [
          'Stand with feet shoulder-width apart.',
          'Bend knees and lower your hips as if sitting in a chair.',
          'Keep chest up and back straight.',
          'Return to standing position.',
          'Repeat for desired reps.'
        ],
      ),
      Exercise(
        id: 3,
        name: 'Plank',
        description: 'An isometric core exercise that strengthens the abdominals and back.',
        category: 'Strength',
        primaryMuscle: 'Core',
        difficulty: 'Beginner',
        imageUrl: 'https://wger.de/static/images/placeholder.png',
        instructions: [
          'Start in a forearm plank position with elbows under shoulders.',
          'Keep body in a straight line from head to heels.',
          'Engage core and hold the position.',
          'Hold for desired time.'
        ],
      ),
    ];
  }
}
