class UserInfoModel {
  final String userId;
  final int age;
  final String gender; // e.g., "Male", "Female", "Other", "Prefer not to say"
  final double weight; // stored in kg
  final double height; // stored in cm
  final String goal; // e.g., "Lose Weight", "Gain Muscle", "Maintain"
  final String weightUnit; // e.g., "kg", "lbs", "stone"
  final String heightUnit; // e.g., "cm", "ft/in", "m"
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserInfoModel({
    required this.userId,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.goal,
    this.weightUnit = 'kg',
    this.heightUnit = 'cm',
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'goal': goal,
      'weightUnit': weightUnit,
      'heightUnit': heightUnit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firebase JSON
  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      userId: json['userId'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      goal: json['goal'] ?? '',
      weightUnit: json['weightUnit'] ?? 'kg',
      heightUnit: json['heightUnit'] ?? 'cm',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  UserInfoModel copyWith({
    String? userId,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? goal,
    String? weightUnit,
    String? heightUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserInfoModel(
      userId: userId ?? this.userId,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
