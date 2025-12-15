class FoodItem {
  final int fdcId;
  final String description;
  final String dataType;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? brandOwner;
  final String? ingredients;

  FoodItem({
    required this.fdcId,
    required this.description,
    required this.dataType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.brandOwner,
    this.ingredients,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Extract nutrients from the foodNutrients array
    double calories = 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;

    if (json['foodNutrients'] != null) {
      for (var nutrient in json['foodNutrients']) {
        int? nutrientId = nutrient['nutrientId'];
        double? value = nutrient['value']?.toDouble();

        if (value != null) {
          switch (nutrientId) {
            case 1008: // Energy (kcal)
              calories = value;
              break;
            case 1003: // Protein
              protein = value;
              break;
            case 1005: // Carbohydrate
              carbs = value;
              break;
            case 1004: // Total lipid (fat)
              fat = value;
              break;
          }
        }
      }
    }

    return FoodItem(
      fdcId: json['fdcId'] ?? 0,
      description: json['description'] ?? 'Unknown Food',
      dataType: json['dataType'] ?? '',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      brandOwner: json['brandOwner'],
      ingredients: json['ingredients'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fdcId': fdcId,
      'description': description,
      'dataType': dataType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'brandOwner': brandOwner,
      'ingredients': ingredients,
    };
  }

  // Convert to meal plan format for compatibility with existing UI
  Map<String, dynamic> toMealPlanFormat({String type = 'All', String time = ''}) {
    return {
      'id': fdcId.toString(),
      'name': description,
      'type': type,
      'calories': calories.round(),
      'protein': protein.round(),
      'carbs': carbs.round(),
      'fat': fat.round(),
      'time': time,
      'description': brandOwner ?? 'USDA Food Database',
      'ingredients': ingredients?.split(',').take(5).toList() ?? [description],
      'dietType': 'Balanced',
    };
  }
}
