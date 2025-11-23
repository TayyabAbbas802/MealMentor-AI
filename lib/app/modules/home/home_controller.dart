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
