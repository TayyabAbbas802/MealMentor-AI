// lib/presentation/screens/progress_dashboard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meal_mentor_ai/app/modules/progress/progress_controller.dart';
import 'package:meal_mentor_ai/app/widgets/progress_calendar.dart';
import '../../theme/app_colors.dart';

class ProgressDashboard extends GetView<ProgressController> {
  final String userId;
  final String planId;

  const ProgressDashboard({
    required this.userId,
    required this.planId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load stats when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.calculateStats(userId, planId);
      controller.loadProgressMetrics(userId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildSummaryCards(),
              const SizedBox(height: 24),

              // Streak & Stats
              _buildStreakSection(),
              const SizedBox(height: 24),

              // Calendar Heatmap
              _buildCalendarSection(),
              const SizedBox(height: 24),

              // Top Exercises
              _buildTopExercisesSection(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              'Total Workouts',
              controller.totalWorkouts.value.toString(),
              Icons.fitness_center,
              AppColors.primary,
            ),
            _buildStatCard(
              'This Week',
              controller.thisWeekWorkouts.value.toString(),
              Icons.calendar_today,
              AppColors.success,
            ),
            _buildStatCard(
              'Total Hours',
              '${controller.totalDurationHours.value.toStringAsFixed(1)}h',
              Icons.access_time,
              AppColors.info,
            ),
            _buildStatCard(
              'This Month',
              controller.currentMonthWorkouts.value.toString(),
              Icons.calendar_month,
              AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Streak',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  controller.workoutStreak.value > 0
                      ? Icons.local_fire_department
                      : Icons.sentiment_dissatisfied,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${controller.workoutStreak.value} Days',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Keep going to extend your streak!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Workout Calendar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ProgressCalendar(
          userId: userId,
          planId: planId,
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildTopExercisesSection() {
    final topExercises = controller.getTopExercisesByVolume(limit: 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Exercises by Volume',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (topExercises.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No exercise data yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...topExercises.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final exerciseId = entry.value.key;
            final volume = entry.value.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildExerciseProgressCard(
                index,
                exerciseId,
                volume,
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildExerciseProgressCard(
      int rank,
      int exerciseWgerId,
      double totalVolume,
      ) {
    final trend = controller.getExerciseProgressTrend(exerciseWgerId);
    final personalRecord = controller.getPersonalRecord(exerciseWgerId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      personalRecord?.exerciseName ?? 'Exercise',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${trend.length} sessions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${totalVolume.toStringAsFixed(0)} lbs',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (personalRecord != null)
                    Text(
                      'PR: ${personalRecord.weight.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(0xFFFFD700); // Gold
      case 2:
        return Color(0xFFC0C0C0); // Silver
      case 3:
        return Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final csv = await controller.exportProgressCSV(userId, planId);
              // Share CSV (implement based on your sharing mechanism)
              Get.snackbar('Success', 'Progress exported');
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Progress'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Workout'),
          ),
        ),
      ],
    );
  }
}
