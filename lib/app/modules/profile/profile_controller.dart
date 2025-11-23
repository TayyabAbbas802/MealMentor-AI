import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';

class ProfileController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final isLoading = true.obs;
  final isEditing = false.obs;
  final currentUser = Rxn<UserModel>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final goalController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      isLoading.value = true;
      String? userId = _firebaseService.currentUser?.uid;

      if (userId != null) {
        UserModel? userData = await _firebaseService.getUserDocument(userId);
        if (userData != null) {
          currentUser.value = userData;
          _populateControllers(userData);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _populateControllers(UserModel user) {
    nameController.text = user.name;
    emailController.text = user.email;
    ageController.text = user.age.toString();
    weightController.text = user.weight.toString();
    heightController.text = user.height.toString();
    goalController.text = user.goal;
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value && currentUser.value != null) {
      _populateControllers(currentUser.value!);
    }
  }

  void saveProfile() async {
    try {
      String? userId = _firebaseService.currentUser?.uid;
      if (userId == null) return;

      isLoading.value = true;

      Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'age': int.tryParse(ageController.text.trim()) ?? 0,
        'weight': double.tryParse(weightController.text.trim()) ?? 0.0,
        'height': double.tryParse(heightController.text.trim()) ?? 0.0,
        'goal': goalController.text.trim(),
      };

      await _firebaseService.updateUserDocument(
        userId: userId,
        data: updateData,
      );

      // Fix: Call _loadUserData without await since it's void
      _loadUserData();
      isEditing.value = false;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


  void logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _firebaseService.signOut();
                Get.offAllNamed(AppRoutes.LOGIN);
                Get.snackbar(
                  'Success',
                  'Logged out successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to logout: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                await _firebaseService.deleteAccount();
                Get.offAllNamed(AppRoutes.LOGIN);
                Get.snackbar(
                  'Success',
                  'Account deleted successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete account: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  double get bmi {
    if (currentUser.value == null) return 0.0;
    double weight = currentUser.value!.weight;
    double height = currentUser.value!.height / 100;

    if (weight == 0 || height == 0) return 0.0;
    return weight / (height * height);
  }

  String get bmiCategory {
    double bmiValue = bmi;
    if (bmiValue == 0) return 'Not set';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    goalController.dispose();
    super.onClose();
  }
}
