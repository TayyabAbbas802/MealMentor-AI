import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_mentor_ai/app/routes/app_routes.dart';

class UserInfoController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  final selectedGoal = ''.obs;
  final selectedGender = ''.obs;
  final isLoading = false.obs;
  final weightUnit = 'kg'.obs;
  final heightUnit = 'cm'.obs;

  // Store the actual values in standard units (kg for weight, cm for height)
  final _weightInKg = 0.0.obs;
  final _heightInCm = 0.0.obs;

  final List<Map<String, dynamic>> goals = [
    {
      'title': 'Lose Weight',
      'icon': Icons.trending_down,
      'description': 'Burn calories and lose fat',
    },
    {
      'title': 'Gain Muscle',
      'icon': Icons.fitness_center,
      'description': 'Build muscle and strength',
    },
    {
      'title': 'Maintain Weight',
      'icon': Icons.balance,
      'description': 'Stay healthy and fit',
    },
    {
      'title': 'Get Healthier',
      'icon': Icons.favorite,
      'description': 'Improve overall wellness',
    },
  ];

  final List<Map<String, dynamic>> genders = [
    {
      'title': 'Male',
      'icon': Icons.male,
    },
    {
      'title': 'Female',
      'icon': Icons.female,
    },
    {
      'title': 'Other',
      'icon': Icons.transgender,
    },
    {
      'title': 'Prefer not to say',
      'icon': Icons.person_outline,
    },
  ];

  @override
  void onClose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }

  void selectGoal(String goal) {
    selectedGoal.value = goal;
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // Toggle weight unit and convert the displayed value
  void toggleWeightUnit() {
    final currentValue = double.tryParse(weightController.text) ?? 0.0;
    
    if (currentValue > 0) {
      // Convert current displayed value to kg first
      if (weightUnit.value == 'lbs') {
        _weightInKg.value = currentValue * 0.453592;
      } else if (weightUnit.value == 'stone') {
        _weightInKg.value = currentValue * 6.35029;
      } else {
        _weightInKg.value = currentValue;
      }
    }

    // Cycle through units: kg -> lbs -> stone -> kg
    if (weightUnit.value == 'kg') {
      weightUnit.value = 'lbs';
      if (_weightInKg.value > 0) {
        weightController.text = (_weightInKg.value / 0.453592).toStringAsFixed(1);
      }
    } else if (weightUnit.value == 'lbs') {
      weightUnit.value = 'stone';
      if (_weightInKg.value > 0) {
        weightController.text = (_weightInKg.value / 6.35029).toStringAsFixed(1);
      }
    } else {
      weightUnit.value = 'kg';
      if (_weightInKg.value > 0) {
        weightController.text = _weightInKg.value.toStringAsFixed(1);
      }
    }
  }

  // Toggle height unit and convert the displayed value
  void toggleHeightUnit() {
    final currentValue = double.tryParse(heightController.text) ?? 0.0;
    
    if (currentValue > 0) {
      // Convert current displayed value to cm first
      if (heightUnit.value == 'm') {
        _heightInCm.value = currentValue * 100;
      } else if (heightUnit.value == 'ft/in') {
        // Assume input is in total inches for ft/in
        _heightInCm.value = currentValue * 2.54;
      } else {
        _heightInCm.value = currentValue;
      }
    }

    // Cycle through units: cm -> ft/in -> m -> cm
    if (heightUnit.value == 'cm') {
      heightUnit.value = 'ft/in';
      if (_heightInCm.value > 0) {
        // Convert cm to total inches
        final totalInches = _heightInCm.value / 2.54;
        heightController.text = totalInches.toStringAsFixed(1);
      }
    } else if (heightUnit.value == 'ft/in') {
      heightUnit.value = 'm';
      if (_heightInCm.value > 0) {
        heightController.text = (_heightInCm.value / 100).toStringAsFixed(2);
      }
    } else {
      heightUnit.value = 'cm';
      if (_heightInCm.value > 0) {
        heightController.text = _heightInCm.value.toStringAsFixed(1);
      }
    }
  }

  // Get weight in kg for saving to database
  double get weightInKg {
    final value = double.tryParse(weightController.text) ?? 0.0;
    if (weightUnit.value == 'lbs') {
      return value * 0.453592;
    } else if (weightUnit.value == 'stone') {
      return value * 6.35029;
    }
    return value;
  }

  // Get height in cm for saving to database
  double get heightInCm {
    final value = double.tryParse(heightController.text) ?? 0.0;
    if (heightUnit.value == 'm') {
      return value * 100;
    } else if (heightUnit.value == 'ft/in') {
      // Convert total inches to cm
      return value * 2.54;
    }
    return value;
  }

  bool validateInputs() {
    if (ageController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your age',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    
    final age = int.tryParse(ageController.text);
    if (age == null || age < 1 || age > 120) {
      Get.snackbar(
        'Error',
        'Please enter a valid age (1-120)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (selectedGender.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select your gender',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (weightController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your weight',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (heightController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your height',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (selectedGoal.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select your goal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  Future<void> saveUserInfo() async {
    if (!validateInputs()) return;

    try {
      isLoading.value = true;

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final age = int.parse(ageController.text);
      final weight = weightInKg; // Convert to kg
      final height = heightInCm; // Convert to cm

      await _firestore.collection('users').doc(user.uid).set({
        'age': age,
        'gender': selectedGender.value,
        'weight': weight,
        'height': height,
        'goal': selectedGoal.value,
        'weightUnit': weightUnit.value,
        'heightUnit': heightUnit.value,
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar(
        'Success',
        'Profile information saved successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.HOME);

    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save information: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void skipForNow() {
    Get.dialog(
      AlertDialog(
        title: const Text('Skip Profile Setup?'),
        content: const Text(
          'You can complete your profile later in settings. '
              'This helps us provide better meal recommendations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.HOME);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
