import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());  // Changed from lazyPut to put
  }
}
