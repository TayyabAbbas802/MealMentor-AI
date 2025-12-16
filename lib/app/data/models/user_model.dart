class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final String goal;
  final String? fitnessLevel; // Beginner, Intermediate, Advanced

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    this.gender = '',
    required this.weight,
    required this.height,
    required this.goal,
    this.fitnessLevel,
  });

  /// Calculate BMI (Body Mass Index)
  /// Formula: weight (kg) / (height (m))^2
  double get bmi {
    if (height <= 0 || weight <= 0) return 0.0;
    // Assuming height is in cm, convert to meters
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Check if user needs low-impact exercises
  bool get needsLowImpact => bmi >= 25;

  /// Check if user should prioritize cardio
  bool get shouldPrioritizeCardio => bmi >= 25;

  /// Get recommended cardio percentage based on BMI
  int get recommendedCardioPercentage {
    if (bmi < 18.5) return 20;
    if (bmi < 25) return 40;
    if (bmi < 30) return 60;
    return 70;
  }

  /// Get recommended strength percentage based on BMI
  int get recommendedStrengthPercentage {
    return 100 - recommendedCardioPercentage;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      goal: json['goal'] ?? '',
      fitnessLevel: json['fitnessLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'goal': goal,
      if (fitnessLevel != null) 'fitnessLevel': fitnessLevel,
    };
  }
}
