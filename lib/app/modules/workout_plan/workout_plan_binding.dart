import 'package:get/get.dart';
import 'workout_plan_controller.dart';

class WorkoutPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutPlanController>(
      () => WorkoutPlanController(),
    );
  }
}
