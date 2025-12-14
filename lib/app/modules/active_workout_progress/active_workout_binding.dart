// lib/app/modules/active_workout_progress/active_workout_binding.dart
import 'package:get/get.dart';
import 'active_workout_controller.dart';

class ActiveWorkoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActiveWorkoutController>(() => ActiveWorkoutController());
  }
}
