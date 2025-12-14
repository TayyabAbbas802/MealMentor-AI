import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'workout_plan_controller.dart';
import '../../theme/app_colors.dart';

class ExerciseSetupScreen extends GetView<WorkoutPlanController> {
  const ExerciseSetupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Exercise Plan'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating your personalized workout plan...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserGoalCard(),
              const SizedBox(height: 32),
              _buildSectionTitle('Step 1: Select Your Level'),
              const SizedBox(height: 16),
              _buildDifficultySelection(),
              const SizedBox(height: 32),
              _buildSectionTitle('Step 2: Choose Training Days'),
              const SizedBox(height: 16),
              _buildDaysSelection(),
              const SizedBox(height: 32),
              _buildPlanPreview(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'YOUR GOAL',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getGoalTitle(controller.userGoal.value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getGoalDescription(controller.userGoal.value),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDifficultySelection() {
    return Column(
      children: [
        _buildDifficultyCard(
          'Beginner',
          'New to working out',
          '12-15 reps • Single muscle focus',
          Icons.accessibility_new_rounded,
          AppColors.beginnerGreen,
        ),
        const SizedBox(height: 12),
        _buildDifficultyCard(
          'Intermediate',
          'Regular training experience',
          '8-12 reps • 2 muscle groups per day',
          Icons.fitness_center_rounded,
          AppColors.intermediateOrange,
        ),
        const SizedBox(height: 12),
        _buildDifficultyCard(
          'Advanced',
          'Experienced athlete',
          '6-10 reps • Multiple muscle groups',
          Icons.military_tech_rounded,
          AppColors.advancedRed,
        ),
      ],
    );
  }

  Widget _buildDifficultyCard(
    String level,
    String subtitle,
    String details,
    IconData icon,
    Color color,
  ) {
    final isSelected = controller.selectedDifficulty.value == level;

    return GestureDetector(
      onTap: () => controller.selectDifficulty(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.border.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    details,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? color : AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysSelection() {
    return Row(
      children: [
        Expanded(child: _buildDaysCard(5)),
        const SizedBox(width: 12),
        Expanded(child: _buildDaysCard(6)),
      ],
    );
  }

  Widget _buildDaysCard(int days) {
    final isSelected = controller.selectedDaysPerWeek.value == days;

    return GestureDetector(
      onTap: () => controller.selectDaysPerWeek(days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$days',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Days/Week',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              days == 5 ? '2 rest days' : '1 rest day',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanPreview() {
    return Obx(() {
      final difficulty = controller.selectedDifficulty.value;
      final days = controller.selectedDaysPerWeek.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Plan Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPreviewRow('Level', difficulty),
            const SizedBox(height: 8),
            _buildPreviewRow('Training Days', '$days days per week'),
            const SizedBox(height: 8),
            _buildPreviewRow('Sets & Reps', _getRepsRange(difficulty)),
            const SizedBox(height: 8),
            _buildPreviewRow('Rest Time', _getRestTime(difficulty)),
          ],
        ),
      );
    });
  }

  Widget _buildPreviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => controller.generateWorkoutPlan(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Generate My Plan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalTitle(String goal) {
    switch (goal.toLowerCase()) {
      case 'muscle_gain':
      case 'muscle gain':
        return 'Build Muscle Mass';
      case 'weight_loss':
      case 'weight loss':
        return 'Lose Weight';
      case 'maintenance':
        return 'Stay Fit & Healthy';
      default:
        return 'Achieve Your Goal';
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal.toLowerCase()) {
      case 'muscle_gain':
      case 'muscle gain':
        return 'Focus on compound movements and progressive overload';
      case 'weight_loss':
      case 'weight loss':
        return 'Combine strength training with cardio for optimal results';
      case 'maintenance':
        return 'Balanced training to maintain your current fitness level';
      default:
        return 'Personalized plan based on your fitness goals';
    }
  }

  String _getRepsRange(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return '3 sets × 12-15 reps';
      case 'Intermediate':
        return '3-4 sets × 8-12 reps';
      case 'Advanced':
        return '4-5 sets × 6-10 reps';
      default:
        return '3 sets × 10-12 reps';
    }
  }

  String _getRestTime(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return '60-90 seconds';
      case 'Intermediate':
        return '45-60 seconds';
      case 'Advanced':
        return '30-45 seconds';
      default:
        return '60 seconds';
    }
  }
}
