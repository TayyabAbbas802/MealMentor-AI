import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_mentor_ai/app/routes/app_routes.dart';

class UserInfoController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final weightController = TextEditingController();
  final heightController = TextEditingController();

  final selectedGoal = ''.obs;
  final isLoading = false.obs;
  final weightUnit = 'kg'.obs;
  final heightUnit = 'cm'.obs;

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

  @override
  void onClose() {
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }

  void selectGoal(String goal) {
    selectedGoal.value = goal;
  }

  bool validateInputs() {
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

      final weight = double.parse(weightController.text);
      final height = double.parse(heightController.text);

      await _firestore.collection('users').doc(user.uid).set({
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
