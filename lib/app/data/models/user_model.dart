class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final double weight;
  final double height;
  final String goal;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.weight,
    required this.height,
    required this.goal,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: json['age'] ?? 0,
      weight: (json['weight'] ?? 0.0).toDouble(),
      height: (json['height'] ?? 0.0).toDouble(),
      goal: json['goal'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'weight': weight,
      'height': height,
      'goal': goal,
    };
  }
}
