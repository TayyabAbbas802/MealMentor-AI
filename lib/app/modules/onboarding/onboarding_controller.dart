import 'package:get/get.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  void navigateToLogin() {
    Get.toNamed(AppRoutes.LOGIN);
  }

  void navigateToSignup() {
    Get.toNamed(AppRoutes.TUTORIAL);  // CHANGE THIS LINE
  }
}
