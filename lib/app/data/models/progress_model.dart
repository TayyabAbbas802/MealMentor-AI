// lib/data/models/progress_model.dart

class ProgressModel {
  final DateTime date;
  final int exerciseWgerId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int sets;
  final double totalVolume; // weight * reps * sets

  ProgressModel({
    required this.date,
    required this.exerciseWgerId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.totalVolume,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      exerciseWgerId: json['exerciseWgerId'] ?? 0,
      exerciseName: json['exerciseName'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] ?? 0,
      sets: json['sets'] ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'exerciseWgerId': exerciseWgerId,
    'exerciseName': exerciseName,
    'weight': weight,
    'reps': reps,
    'sets': sets,
    'totalVolume': totalVolume,
  };
}
