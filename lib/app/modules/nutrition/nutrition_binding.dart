import 'package:get/get.dart';
import 'progress_controller.dart';

class NutritionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgressController>(() => ProgressController());
  }
}
