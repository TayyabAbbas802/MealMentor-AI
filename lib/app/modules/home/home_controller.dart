import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final currentIndex = 0.obs;
  final currentUser = Rxn<UserModel>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      isLoading.value = true;
      User? user = _firebaseService.currentUser;

      if (user != null) {
        print('Current user ID: ${user.uid}'); // Debug
        print('Current user email: ${user.email}'); // Debug
        print('Current user displayName: ${user.displayName}'); // Debug

        // Try to get user document
        UserModel? userData = await _firebaseService.getUserDocument(user.uid);

        if (userData != null) {
          currentUser.value = userData;
          print('User data loaded successfully'); // Debug
        } else {
          // If no user document exists, create a basic one from auth data
          print('No user document found, using auth data'); // Debug
          currentUser.value = UserModel(
            id: user.uid,
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            age: 0,
            weight: 0.0,
            height: 0.0,
            goal: '',
          );
        }
      }
    } catch (e) {
      print('Error loading user data: $e'); // Debug
      print('Error type: ${e.runtimeType}'); // Debug

      // Use fallback data from Firebase Auth
      User? user = _firebaseService.currentUser;
      if (user != null) {
        currentUser.value = UserModel(
          id: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          age: 0,
          weight: 0.0,
          height: 0.0,
          goal: '',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }


  void changeTab(int index) {
    currentIndex.value = index;
  }

  void navigateToMealScan() {
    Get.toNamed(AppRoutes.MEAL_SCAN);
  }

  void navigateToNutrition() {
    Get.toNamed(AppRoutes.NUTRITION);
  }

  void navigateToDietPlan() {
    Get.toNamed(AppRoutes.DIET_PLAN);
  }

  void navigateToExercise() {
    Get.toNamed(AppRoutes.EXERCISE);
  }

  void navigateToProfile() {
    Get.toNamed(AppRoutes.PROFILE);
  }

  void showLogoutConfirmation() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFD50000),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        logout(); // Perform logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD50000),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logout() async {
    try {
      await _firebaseService.signOut();
      Get.offAllNamed(AppRoutes.LOGIN);
      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String get userName => currentUser.value?.name ?? 'User';
  String get userEmail => currentUser.value?.email ?? '';
}
