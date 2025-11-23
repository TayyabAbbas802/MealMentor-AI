import 'package:get/get.dart';
import 'meal_scan_controller.dart';

class MealScanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MealScanController>(() => MealScanController());
  }
}
