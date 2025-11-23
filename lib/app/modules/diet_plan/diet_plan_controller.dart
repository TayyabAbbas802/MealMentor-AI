import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';

class DietPlanController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final isLoading = false.obs;
  final selectedMealType = 'All'.obs;
  final selectedDietType = 'Balanced'.obs;

  final List<String> mealTypes = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  final List<String> dietTypes = ['Balanced', 'Low Carb', 'High Protein', 'Keto', 'Vegan', 'Vegetarian'];

  // Sample meal plans
  final RxList<Map<String, dynamic>> allMealPlans = <Map<String, dynamic>>[
    {
      'id': '1',
      'name': 'Oatmeal with Berries',
      'type': 'Breakfast',
      'calories': 350,
      'protein': 12,
      'carbs': 58,
      'fat': 8,
      'time': '8:00 AM',
      'description': 'A nutritious breakfast to start your day',
      'ingredients': ['Oats', 'Blueberries', 'Strawberries', 'Honey', 'Almond milk'],
      'dietType': 'Balanced',
    },
    {
      'id': '2',
      'name': 'Grilled Chicken Salad',
      'type': 'Lunch',
      'calories': 450,
      'protein': 35,
      'carbs': 25,
      'fat': 18,
      'time': '1:00 PM',
      'description': 'Light and protein-rich lunch',
      'ingredients': ['Chicken breast', 'Mixed greens', 'Cherry tomatoes', 'Olive oil', 'Lemon'],
      'dietType': 'High Protein',
    },
    {
      'id': '3',
      'name': 'Salmon with Vegetables',
      'type': 'Dinner',
      'calories': 550,
      'protein': 40,
      'carbs': 35,
      'fat': 22,
      'time': '7:00 PM',
      'description': 'Omega-3 rich dinner option',
      'ingredients': ['Salmon fillet', 'Broccoli', 'Carrots', 'Brown rice', 'Garlic'],
      'dietType': 'Balanced',
    },
    {
      'id': '4',
      'name': 'Greek Yogurt with Nuts',
      'type': 'Snacks',
      'calories': 200,
      'protein': 15,
      'carbs': 18,
      'fat': 8,
      'time': '4:00 PM',
      'description': 'Healthy afternoon snack',
      'ingredients': ['Greek yogurt', 'Almonds', 'Walnuts', 'Honey'],
      'dietType': 'High Protein',
    },
    {
      'id': '5',
      'name': 'Protein Smoothie',
      'type': 'Breakfast',
      'calories': 320,
      'protein': 25,
      'carbs': 35,
      'fat': 10,
      'time': '8:30 AM',
      'description': 'Quick protein-packed breakfast',
      'ingredients': ['Protein powder', 'Banana', 'Spinach', 'Almond butter', 'Milk'],
      'dietType': 'High Protein',
    },
    {
      'id': '6',
      'name': 'Quinoa Buddha Bowl',
      'type': 'Lunch',
      'calories': 480,
      'protein': 18,
      'carbs': 62,
      'fat': 16,
      'time': '12:30 PM',
      'description': 'Balanced vegetarian lunch',
      'ingredients': ['Quinoa', 'Chickpeas', 'Avocado', 'Kale', 'Tahini dressing'],
      'dietType': 'Vegan',
    },
    {
      'id': '7',
      'name': 'Keto Egg Muffins',
      'type': 'Breakfast',
      'calories': 280,
      'protein': 20,
      'carbs': 5,
      'fat': 22,
      'time': '7:30 AM',
      'description': 'Low-carb breakfast option',
      'ingredients': ['Eggs', 'Cheese', 'Bell peppers', 'Spinach', 'Bacon'],
      'dietType': 'Keto',
    },
    {
      'id': '8',
      'name': 'Tofu Stir Fry',
      'type': 'Dinner',
      'calories': 420,
      'protein': 22,
      'carbs': 45,
      'fat': 18,
      'time': '7:30 PM',
      'description': 'Plant-based protein dinner',
      'ingredients': ['Tofu', 'Mixed vegetables', 'Soy sauce', 'Ginger', 'Brown rice'],
      'dietType': 'Vegan',
    },
  ].obs;

  List<Map<String, dynamic>> get filteredMealPlans {
    return allMealPlans.where((meal) {
      bool matchesMealType = selectedMealType.value == 'All' || meal['type'] == selectedMealType.value;
      bool matchesDietType = selectedDietType.value == 'Balanced' || meal['dietType'] == selectedDietType.value;
      return matchesMealType && matchesDietType;
    }).toList();
  }

  void selectMealType(String type) {
    selectedMealType.value = type;
  }

  void selectDietType(String type) {
    selectedDietType.value = type;
  }

  void viewMealDetails(Map<String, dynamic> meal) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        meal['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  meal['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientInfo('Calories', '${meal['calories']}', Icons.local_fire_department),
                    _buildNutrientInfo('Protein', '${meal['protein']}g', Icons.egg),
                    _buildNutrientInfo('Carbs', '${meal['carbs']}g', Icons.rice_bowl),
                    _buildNutrientInfo('Fat', '${meal['fat']}g', Icons.water_drop),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ingredients:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...(meal['ingredients'] as List).map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8),
                      const SizedBox(width: 8),
                      Text(ingredient),
                    ],
                  ),
                )),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      addMealToPlan(meal);
                    },
                    child: const Text('Add to My Plan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.green),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void addMealToPlan(Map<String, dynamic> meal) {
    Get.snackbar(
      'Success',
      '${meal['name']} added to your meal plan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void generateAIPlan() {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              const Text(
                'AI Meal Plan Generator',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Our AI will create a personalized meal plan based on your preferences and goals.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  _showAIGenerating();
                },
                child: const Text('Generate Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAIGenerating() async {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your personalized meal plan...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(seconds: 3));
    Get.back();

    Get.snackbar(
      'Success',
      'Your AI-generated meal plan is ready!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
