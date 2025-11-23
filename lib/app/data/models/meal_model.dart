class MealModel {
  final String id;
  final String name;
  final String imageUrl;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime timestamp;

  MealModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      calories: (json['calories'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
