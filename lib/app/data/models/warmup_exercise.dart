/// Represents a single warmup exercise
class WarmupExercise {
  final String name;
  final String description;
  final int durationSeconds;
  final int? reps;
  final String? gifUrl;
  final String category; // 'cardio' or 'dynamic_stretch'

  WarmupExercise({
    required this.name,
    required this.description,
    required this.durationSeconds,
    this.reps,
    this.gifUrl,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'durationSeconds': durationSeconds,
        if (reps != null) 'reps': reps,
        if (gifUrl != null) 'gifUrl': gifUrl,
        'category': category,
      };

  factory WarmupExercise.fromJson(Map<String, dynamic> json) {
    return WarmupExercise(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 30,
      reps: json['reps'],
      gifUrl: json['gifUrl'],
      category: json['category'] ?? 'dynamic_stretch',
    );
  }
}
