import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'workout_plan_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/exercise_video_player.dart';

class WeeklyPlanScreen extends GetView<WorkoutPlanController> {
  const WeeklyPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if user came from home screen
    final fromHome = Get.arguments?['fromHome'] ?? false;
    
    return WillPopScope(
      onWillPop: () async {
        // Skip save prompt if coming from home screen
        if (fromHome) {
          return true;
        }
        
        if (controller.currentPlan.value != null) {
          return await _showSavePrompt() ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Weekly Plan'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => Get.offNamed(AppRoutes.EXERCISE_SETUP),
              tooltip: 'Create New Plan',
            ),
          ],
        ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your workout plan...'),
              ],
            ),
          );
        }

        if (controller.currentPlan.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fitness_center_rounded, size: 64, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                const Text(
                  'No plan generated yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your personalized workout plan',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.offNamed(AppRoutes.EXERCISE_SETUP),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          );
        }

        final plan = controller.currentPlan.value!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPlanHeader(plan),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: plan.daysSchedule.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final day = plan.daysSchedule[index];
                  return _buildDayCard(day, index + 1);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
      ),
    );
  }

  Future<bool?> _showSavePrompt() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.save_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Save Workout Plan?'),
          ],
        ),
        content: const Text(
          'Would you like to save this workout plan? You can access it later from the home screen.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: true); // Don't save, just go back
            },
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await controller.saveWorkoutPlan();
              Get.back(result: true); // Save and go back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(dynamic plan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name ?? 'My Workout Plan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildHeaderChip(Icons.calendar_today_rounded, '${plan.daysPerWeek} days/week'),
                _buildHeaderChip(Icons.speed_rounded, plan.difficulty ?? 'Intermediate'),
                _buildHeaderChip(Icons.flag_rounded, _formatGoal(plan.goal ?? 'maintenance')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(dynamic day, int dayNumber) {
    if (day.isRest) {
      return _buildRestDayCard(day.dayName, dayNumber);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Day $dayNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.dayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatFocusMuscles(day.focusMuscles),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${day.exercises.length} exercises',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Warmup Section
          if (day.warmupExercises.isNotEmpty)
            _buildWarmupSection(day.warmupExercises),
          // Exercises List
          if (day.exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No exercises for this day',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: day.exercises.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final exercise = day.exercises[index];
                return _buildExerciseItem(exercise, index + 1);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRestDayCard(String dayName, int dayNumber) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.flexibilityGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.flexibilityGreen,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayNumber - $dayName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rest & Recovery',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Focus on stretching, light activity, and proper nutrition',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(dynamic exercise, int exerciseNumber) {
    final hasGif = exercise.gifUrl != null && exercise.gifUrl.toString().isNotEmpty;

    return GestureDetector(
      onTap: () => _showExerciseDetailDialog(exercise, exerciseNumber),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$exerciseNumber',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // GIF/Image
          if (hasGif)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                exercise.gifUrl.toString(),
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.fitness_center_rounded, color: AppColors.textSecondary),
                  );
                },
              ),
            )
          else
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.3)),
              ),
              child: const Center(
                child: Icon(Icons.fitness_center_rounded, color: AppColors.textSecondary, size: 32),
              ),
            ),
          const SizedBox(width: 16),
          // Exercise Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name ?? 'Unknown Exercise',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildExerciseChip(
                      Icons.repeat_rounded,
                      '${exercise.targetSets} sets',
                      AppColors.primary,
                    ),
                    _buildExerciseChip(
                      Icons.fitness_center_rounded,
                      '${exercise.targetReps} reps',
                      AppColors.intermediateOrange,
                    ),
                    _buildExerciseChip(
                      Icons.timer_rounded,
                      '${exercise.restSeconds}s rest',
                      AppColors.flexibilityGreen,
                    ),
                    if (exercise.equipment != null && exercise.equipment.isNotEmpty)
                      _buildExerciseChip(
                        Icons.build_rounded,
                        exercise.equipment.first.length > 15 
                            ? '${exercise.equipment.first.substring(0, 15)}...'
                            : exercise.equipment.first,
                        AppColors.textSecondary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExerciseDetailDialog(dynamic exercise, int exerciseNumber) {
    final hasVideo = exercise.youtubeVideoId != null && exercise.youtubeVideoId.toString().isNotEmpty;
    final hasGif = exercise.gifUrl != null && exercise.gifUrl.toString().isNotEmpty;
    
    showDialog(
      context: Get.context!,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$exerciseNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        exercise.name ?? 'Unknown Exercise',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Video Player or Image/GIF
              if (hasVideo)
                Container(
                  width: double.infinity,
                  height: 300,
                  color: AppColors.background,
                  child: _buildVideoPlayer(exercise.youtubeVideoId.toString(), exercise.name ?? 'Exercise'),
                )
              else if (hasGif)
                Container(
                  width: double.infinity,
                  height: 300,
                  color: AppColors.background,
                  child: Image.network(
                    exercise.gifUrl.toString(),
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center_rounded, 
                                color: AppColors.textSecondary, size: 64),
                            SizedBox(height: 8),
                            Text('Image not available',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  color: AppColors.background,
                  child: const Center(
                    child: Icon(Icons.fitness_center_rounded, 
                        color: AppColors.textSecondary, size: 80),
                  ),
                ),
              // Exercise Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exercise Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.repeat_rounded,
                      'Sets',
                      '${exercise.targetSets}',
                      AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.fitness_center_rounded,
                      'Reps',
                      '${exercise.targetReps}',
                      AppColors.intermediateOrange,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.timer_rounded,
                      'Rest Time',
                      '${exercise.restSeconds} seconds',
                      AppColors.flexibilityGreen,
                    ),
                    if (exercise.equipment != null && exercise.equipment.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.build_rounded,
                        'Equipment',
                        exercise.equipment.join(', '),
                        AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(String videoId, String exerciseName) {
    // Import the ExerciseVideoPlayer widget
    return ExerciseVideoPlayer(
      youtubeVideoId: videoId,
      exerciseName: exerciseName,
      autoPlay: true,
      showControls: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

  }

  Widget _buildExerciseChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFocusMuscles(List<dynamic> muscles) {
    if (muscles.isEmpty) return 'Rest Day';
    return muscles.map((m) => _capitalize(m.toString())).join(' • ');
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'muscle_gain':
      case 'muscle gain':
        return 'Build Muscle';
      case 'weight_loss':
      case 'weight loss':
        return 'Lose Weight';
      case 'maintenance':
        return 'Maintain';
      default:
        return goal;
    }
  }

  Widget _buildWarmupSection(List<dynamic> warmups) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Warmup Routine',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '7-8 min',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete this warmup before starting your workout',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          ...warmups.map((warmup) => _buildWarmupItem(warmup)),
        ],
      ),
    );
  }

  Widget _buildWarmupItem(dynamic warmup) {
    final name = warmup.name ?? '';
    final reps = warmup.reps;
    final duration = warmup.durationSeconds ?? 30;
    final category = warmup.category ?? 'dynamic_stretch';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            category == 'cardio' ? Icons.favorite : Icons.accessibility_new,
            size: 18,
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              reps != null ? '$reps reps' : '${duration}s',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
