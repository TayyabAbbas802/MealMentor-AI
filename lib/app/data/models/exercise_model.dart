// lib/data/models/exercise_model.dart

class ExerciseModel {
  final int id;
  final String name;
  final String category;
  final String description;
  final List<int> muscles;
  final List<int> equipment;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int? duration; // in minutes
  final int? caloriesBurned;
  final String? videoUrl;
  final String? imageUrl;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.muscles,
    required this.equipment,
    required this.difficulty,
    this.duration,
    this.caloriesBurned,
    this.videoUrl,
    this.imageUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      description: json['description'] ?? '',
      muscles: List<int>.from(json['muscles'] ?? []),
      equipment: List<int>.from(json['equipment'] ?? []),
      difficulty: _calculateDifficulty(json),
      duration: json['duration'],
      caloriesBurned: json['caloriesBurned'],
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
    );
  }

  static String _calculateDifficulty(Map<String, dynamic> json) {
    // Map based on exercise characteristics
    final name = (json['name'] ?? '').toLowerCase();

    if (name.contains('beginner') || name.contains('basic')) {
      return 'Beginner';
    } else if (name.contains('advanced') || name.contains('complex')) {
      return 'Advanced';
    }
    return 'Intermediate';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'description': description,
    'muscles': muscles,
    'equipment': equipment,
    'difficulty': difficulty,
    'duration': duration,
    'caloriesBurned': caloriesBurned,
    'videoUrl': videoUrl,
    'imageUrl': imageUrl,
  };
}


