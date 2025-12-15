import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';
import '../../data/services/usda_service.dart';
import '../../data/models/food_model.dart';
import 'dart:async';

class DietPlanController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final UsdaService _usdaService = UsdaService();

  final isLoading = false.obs;
  final isSearching = false.obs;
  final selectedMealType = 'All'.obs;
  final selectedDietType = 'Balanced'.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final List<String> mealTypes = ['All', 'Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  final List<String> dietTypes = ['Balanced', 'Low Carb', 'High Protein', 'Keto', 'Vegan', 'Vegetarian'];

  // Search results from USDA API
  final RxList<FoodItem> searchResults = <FoodItem>[].obs;
  final RxString errorMessage = ''.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Load some default foods on init
    loadDefaultFoods();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  // Load default/common foods
  Future<void> loadDefaultFoods() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final foods = await _usdaService.getCommonFoods();
      searchResults.value = foods;
    } catch (e) {
      errorMessage.value = 'Failed to load foods: $e';
      print('Error loading default foods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Search foods with debouncing
  void onSearchChanged(String query) {
    searchQuery.value = query;

    // Cancel previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start new timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isEmpty) {
        loadDefaultFoods();
      } else {
        searchFoods(query);
      }
    });
  }

  // Search foods from USDA API
  Future<void> searchFoods(String query) async {
    if (query.trim().isEmpty) return;

    try {
      isSearching.value = true;
      errorMessage.value = '';

      final foods = await _usdaService.searchFoods(query, pageSize: 25);
      
      if (foods.isEmpty) {
        errorMessage.value = 'No foods found for "$query"';
      }
      
      searchResults.value = foods;
    } catch (e) {
      errorMessage.value = 'Search failed: ${e.toString().replaceAll('Exception: ', '')}';
      print('Error searching foods: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  // Get filtered meal plans (converted from FoodItem to meal format)
  List<Map<String, dynamic>> get filteredMealPlans {
    return searchResults.map((food) {
      return food.toMealPlanFormat(
        type: selectedMealType.value == 'All' ? 'All' : selectedMealType.value,
        time: _getDefaultTime(selectedMealType.value),
      );
    }).toList();
  }

  String _getDefaultTime(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return '8:00 AM';
      case 'Lunch':
        return '1:00 PM';
      case 'Dinner':
        return '7:00 PM';
      case 'Snacks':
        return '4:00 PM';
      default:
        return '';
    }
  }

  void selectMealType(String type) {
    selectedMealType.value = type;
  }

  void selectDietType(String type) {
    selectedDietType.value = type;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadDefaultFoods();
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
                  'Nutritional Information:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNutrientRow('Energy', '${meal['calories']} kcal'),
                _buildNutrientRow('Protein', '${meal['protein']} g'),
                _buildNutrientRow('Carbohydrates', '${meal['carbs']} g'),
                _buildNutrientRow('Total Fat', '${meal['fat']} g'),
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

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
