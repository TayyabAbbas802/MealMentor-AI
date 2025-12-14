import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'active_workout_controller.dart';
import '../../theme/app_colors.dart';

class ActiveWorkoutScreen extends GetView<ActiveWorkoutController> {
  const ActiveWorkoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                if (controller.currentExerciseIndex.value >= controller.exercises.length) {
                  return const Center(child: Text("Workout Complete!"));
                }
                final exercise = controller.exercises[controller.currentExerciseIndex.value];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildExerciseDisplay(exercise),
                      const SizedBox(height: 32),
                      _buildSetLogging(exercise),
                    ],
                  ),
                );
              }),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Get.back(),
          ),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(controller.workoutDuration.value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monospace',
                  ),
                ),
              ],
            ),
          )),
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
            onPressed: controller.endWorkout,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDisplay(dynamic exercise) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Icon(
              Icons.fitness_center_rounded,
              size: 64,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          exercise.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Target: 3 Sets • 12 Reps', // Dynamic later
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSetLogging(dynamic exercise) {
    return Column(
      children: [
        for (int i = 0; i < 3; i++) // Dynamic sets later
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set ${i + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    _buildInputBox('lbs', '0'),
                    const SizedBox(width: 12),
                    _buildInputBox('reps', '12'),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_rounded, color: AppColors.success, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInputBox(String label, String placeholder) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            placeholder,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: controller.previousExercise,
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.nextExercise,
              child: const Text('Next Exercise'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
