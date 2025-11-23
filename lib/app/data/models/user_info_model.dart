class UserInfoModel {
  final String userId;
  final double weight; // in kg
  final double height; // in cm
  final String goal; // e.g., "Lose Weight", "Gain Muscle", "Maintain"
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserInfoModel({
    required this.userId,
    required this.weight,
    required this.height,
    required this.goal,
    required this.createdAt,
    this.updatedAt,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'weight': weight,
      'height': height,
      'goal': goal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create from Firebase JSON
  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      userId: json['userId'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      goal: json['goal'] ?? '',
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
    double? weight,
    double? height,
    String? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserInfoModel(
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
