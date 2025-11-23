import 'package:get/get.dart';
import 'diet_plan_controller.dart';

class DietPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DietPlanController>(() => DietPlanController());
  }
}
