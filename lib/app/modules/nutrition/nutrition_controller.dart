import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';
import '../../theme/app_colors.dart';

class NutritionController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final isLoading = true.obs;
  final selectedDate = DateTime.now().obs;

  // Daily nutrition data
  final caloriesConsumed = 0.0.obs;
  final caloriesGoal = 2000.0.obs;
  final proteinConsumed = 0.0.obs;
  final proteinGoal = 150.0.obs;
  final carbsConsumed = 0.0.obs;
  final carbsGoal = 250.0.obs;
  final fatConsumed = 0.0.obs;
  final fatGoal = 65.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNutritionData();
  }

  void _loadNutritionData() async {
    try {
      isLoading.value = true;

      String? userId = _firebaseService.currentUser?.uid;
      if (userId != null) {
        // Load user's nutrition logs from Firestore
        _firebaseService.getNutritionLogs(userId, date: selectedDate.value).listen((snapshot) {
          double totalCalories = 0;
          double totalProtein = 0;
          double totalCarbs = 0;
          double totalFat = 0;

          for (var doc in snapshot.docs) {
            var data = doc.data() as Map<String, dynamic>;
            totalCalories += (data['calories'] ?? 0).toDouble();
            totalProtein += (data['protein'] ?? 0).toDouble();
            totalCarbs += (data['carbs'] ?? 0).toDouble();
            totalFat += (data['fat'] ?? 0).toDouble();
          }

          caloriesConsumed.value = totalCalories;
          proteinConsumed.value = totalProtein;
          carbsConsumed.value = totalCarbs;
          fatConsumed.value = totalFat;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load nutrition data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeDate(DateTime date) {
    selectedDate.value = date;
    _loadNutritionData();
  }

  void previousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    _loadNutritionData();
  }

  void nextDay() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 1));
    _loadNutritionData();
  }

  // Calculate percentages
  double get caloriesPercentage => (caloriesConsumed.value / caloriesGoal.value * 100).clamp(0, 100);
  double get proteinPercentage => (proteinConsumed.value / proteinGoal.value * 100).clamp(0, 100);
  double get carbsPercentage => (carbsConsumed.value / carbsGoal.value * 100).clamp(0, 100);
  double get fatPercentage => (fatConsumed.value / fatGoal.value * 100).clamp(0, 100);

  // Get pie chart sections for macros
  List<PieChartSectionData> getPieChartSections() {
    final total = proteinConsumed.value + carbsConsumed.value + fatConsumed.value;

    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: 'No data',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ];
    }

    return [
      PieChartSectionData(
        color: AppColors.primary,
        value: proteinConsumed.value,
        title: 'Protein\n${proteinConsumed.value.toStringAsFixed(1)}g',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppColors.secondary,
        value: carbsConsumed.value,
        title: 'Carbs\n${carbsConsumed.value.toStringAsFixed(1)}g',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFE91E63),
        value: fatConsumed.value,
        title: 'Fat\n${fatConsumed.value.toStringAsFixed(1)}g',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  // Get weekly calorie data for bar chart
  List<BarChartGroupData> getWeeklyCalorieData() {
    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (index + 1) * 300.0, // Mock data - replace with actual
            color: AppColors.primary,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
