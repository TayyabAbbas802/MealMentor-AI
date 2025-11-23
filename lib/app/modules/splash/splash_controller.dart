import 'package:get/get.dart';
import '../../data/services/firebase_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    print('🔄 SplashController onReady called');
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    print('⏳ Starting navigation timer...');
    await Future.delayed(const Duration(seconds: 3));

    try {
      // Try to get FirebaseService
      final firebaseService = Get.find<FirebaseService>();

      // Check if user is logged in
      if (firebaseService.isLoggedIn) {
        print('✅ User is logged in, going to home');
        Get.offAllNamed(AppRoutes.HOME);
      } else {
        print('ℹ️ User not logged in, going to onboarding');
        Get.offAllNamed(AppRoutes.ONBOARDING);
      }
    } catch (e) {
      print('❌ Navigation error: $e');
      // If FirebaseService not found, go to onboarding anyway
      Get.offAllNamed(AppRoutes.ONBOARDING);
    }
  }
}
