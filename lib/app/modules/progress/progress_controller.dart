// lib/presentation/controllers/progress_controller.dart
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_mentor_ai/app/data/models/progress_model.dart';
import 'package:meal_mentor_ai/app/data/services/firebase_service.dart';

class ProgressController extends GetxController {
  late FirebaseService _firebaseService;

  final isLoading = false.obs;
  final workoutStreak = 0.obs;
  final totalWorkouts = 0.obs;
  final thisWeekWorkouts = 0.obs;
  final currentMonthWorkouts = 0.obs;
  final totalDurationHours = 0.0.obs;

  final progressMetrics = <ProgressModel>[].obs;
  final exerciseProgressMap = <int, List<ProgressModel>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _firebaseService = Get.find<FirebaseService>();
  }

  /// Load all progress metrics
  Future<void> loadProgressMetrics(String userId) async {
    try {
      isLoading.value = true;
      final metrics = await _firebaseService.getAllProgressMetrics(userId);
      progressMetrics.value = metrics
          .map((m) => ProgressModel.fromJson(m))
          .toList();

      // Group by exercise
      final grouped = <int, List<ProgressModel>>{};
      for (var metric in progressMetrics) {
        if (!grouped.containsKey(metric.exerciseWgerId)) {
          grouped[metric.exerciseWgerId] = [];
        }
        grouped[metric.exerciseWgerId]!.add(metric);
      }
      exerciseProgressMap.value = grouped;
    } catch (e) {
      print('Error loading progress metrics: $e');
      Get.snackbar('Error', 'Failed to load progress metrics');
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate workout statistics
  Future<void> calculateStats(String userId, String planId) async {
    try {
      isLoading.value = true;

      final logs = await _firebaseService.getWorkoutLogs(userId, planId);
      totalWorkouts.value = logs.length;

      // Calculate this week's workouts
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      thisWeekWorkouts.value = logs
          .where((log) {
        final logDate = (log['date'] as Timestamp).toDate();
        return logDate.isAfter(weekStart);
      })
          .length;

      // Calculate this month's workouts
      final monthStart = DateTime(now.year, now.month, 1);
      currentMonthWorkouts.value = logs
          .where((log) {
        final logDate = (log['date'] as Timestamp).toDate();
        return logDate.isAfter(monthStart);
      })
          .length;

      // Calculate total duration
      totalDurationHours.value = logs.fold(0, (sum, log) {
        return sum + (log['durationMinutes'] as int? ?? 0);
      }) / 60.0;

      // Calculate streak
      workoutStreak.value = await _firebaseService.getWorkoutStreak(userId, planId);
    } catch (e) {
      print('Error calculating stats: $e');
      Get.snackbar('Error', 'Failed to calculate statistics');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get exercise progress trend
  List<ProgressModel> getExerciseProgressTrend(int exerciseWgerId) {
    return exerciseProgressMap[exerciseWgerId] ?? [];
  }

  /// Calculate personal record
  ProgressModel? getPersonalRecord(int exerciseWgerId) {
    final metrics = exerciseProgressMap[exerciseWgerId];
    if (metrics == null || metrics.isEmpty) return null;

    return metrics.reduce((a, b) {
      return a.weight > b.weight ? a : b;
    });
  }

  /// Get workout completion percentage for a date range
  Future<double> getCompletionPercentage({
    required String userId,
    required String planId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final logs = await _firebaseService.getWorkoutLogsDateRange(
        userId: userId,
        planId: planId,
        startDate: startDate,
        endDate: endDate,
      );

      final completedCount = logs.where((log) => log['isCompleted'] == true).length;
      final totalDays = endDate.difference(startDate).inDays + 1;

      return completedCount / totalDays;
    } catch (e) {
      print('Error calculating completion: $e');
      return 0;
    }
  }

  /// Stream real-time progress updates
  Stream<List<Map<String, dynamic>>> streamWorkoutLogs(
      String userId,
      String planId,
      ) {
    return _firebaseService.streamWorkoutLogs(userId, planId);
  }

  /// Get calendar data for heatmap
  Future<Map<DateTime, int>> getCalendarData(
      String userId,
      String planId,
      ) async {
    try {
      return await _firebaseService.getCalendarData(userId, planId);
    } catch (e) {
      print('Error getting calendar data: $e');
      return {};
    }
  }

  /// Export progress as CSV
  Future<String> exportProgressCSV(
      String userId,
      String planId,
      ) async {
    try {
      final logs = await _firebaseService.getWorkoutLogs(userId, planId);

      StringBuffer csv = StringBuffer();
      csv.writeln('Date,Exercise,Sets,Reps,Weight,Duration(min)');

      for (var log in logs) {
        final date = (log['date'] as Timestamp).toDate();
        for (var exerciseLog in log['exerciseLogs'] ?? []) {
          csv.writeln(
            '${date.toIso8601String()},${exerciseLog['name']},'
                '${exerciseLog['setLogs']?.length ?? 0},'
                '${exerciseLog['setLogs']?[0]?['reps'] ?? 0},'
                '${exerciseLog['setLogs']?[0]?['weight'] ?? 0},'
                '${log['durationMinutes'] ?? 0}',
          );
        }
      }

      return csv.toString();
    } catch (e) {
      print('Error exporting CSV: $e');
      return '';
    }
  }

  /// Get average volume per week
  double getAverageVolumePerWeek(int exerciseWgerId) {
    final metrics = exerciseProgressMap[exerciseWgerId];
    if (metrics == null || metrics.isEmpty) return 0;

    // Group by week
    final weeks = <int, List<ProgressModel>>{};
    for (var metric in metrics) {
      final weekNumber = getWeekNumber(metric.date);
      if (!weeks.containsKey(weekNumber)) {
        weeks[weekNumber] = [];
      }
      weeks[weekNumber]!.add(metric);
    }

    // Calculate average volume per week
    double totalVolume = 0;
    for (var weekLogs in weeks.values) {
      totalVolume += weekLogs.fold(0, (sum, m) => sum + m.totalVolume);
    }

    return weeks.isEmpty ? 0 : totalVolume / weeks.length;
  }

  /// Helper: Get week number from date
  int getWeekNumber(DateTime date) {
    final jan4 = DateTime(date.year, 1, 4);
    final dayOfWeek = jan4.weekday;
    final weekOne = jan4.subtract(Duration(days: dayOfWeek - 1));
    return ((date.difference(weekOne).inDays) / 7).floor() + 1;
  }

  /// Get top exercises by volume
  List<MapEntry<int, double>> getTopExercisesByVolume({int limit = 5}) {
    final exerciseVolumes = <int, double>{};

    for (var entry in exerciseProgressMap.entries) {
      final totalVolume = entry.value.fold<double>(
        0,
            (sum, metric) => sum + metric.totalVolume,
      );
      exerciseVolumes[entry.key] = totalVolume;
    }

    final sorted = exerciseVolumes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).toList();
  }
}
