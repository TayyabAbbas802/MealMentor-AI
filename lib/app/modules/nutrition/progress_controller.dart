import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/user_model.dart';
import '../../theme/app_colors.dart';

class ProgressController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final isLoading = true.obs;
  final Rx<UserModel?> userData = Rx<UserModel?>(null);
  
  // Workout Statistics
  final workoutsThisWeek = 0.obs;
  final workoutsThisMonth = 0.obs;
  final totalWorkouts = 0.obs;
  final currentStreak = 0.obs;
  final totalMinutesExercised = 0.obs;
  
  // Body Measurements
  final currentWeight = 0.0.obs;
  final currentBMI = 0.0.obs;
  final weightHistory = <Map<String, dynamic>>[].obs;
  
  // Achievements
  final unlockedAchievements = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      isLoading.value = true;

      String? userId = _firebaseService.currentUser?.uid;
      if (userId != null) {
        // Load user data
        final userDoc = await _firebaseService.getUserDocument(userId);
        if (userDoc != null) {
          userData.value = userDoc;
          currentWeight.value = userDoc.weight;
          currentBMI.value = userDoc.bmi;
        }

        // Load workout statistics
        await _loadWorkoutStats(userId);
        
        // Load weight history
        await _loadWeightHistory(userId);
        
        // Check achievements
        _checkAchievements();
      }
    } catch (e) {
      print('Error loading progress data: $e');
      Get.snackbar(
        'Error',
        'Failed to load progress data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadWorkoutStats(String userId) async {
    try {
      // Get workout plans from Firebase
      final workoutPlans = await _firebaseService.getWorkoutPlans(userId);
      
      if (workoutPlans.isEmpty) {
        print('No workout plans found');
        return;
      }

      // Calculate statistics
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final monthAgo = now.subtract(const Duration(days: 30));

      int weekCount = 0;
      int monthCount = 0;
      int total = 0;
      int streak = 0;
      int totalMinutes = 0;

      // For now, use created workout plans as proxy
      // TODO: Track actual completed workouts
      for (var plan in workoutPlans) {
        final createdAt = plan['createdAt'] as DateTime?;
        if (createdAt != null) {
          total++;
          totalMinutes += 45; // Assume 45 min per workout
          
          if (createdAt.isAfter(weekAgo)) {
            weekCount++;
          }
          if (createdAt.isAfter(monthAgo)) {
            monthCount++;
          }
        }
      }

      // Simple streak calculation (days with workouts)
      streak = weekCount > 0 ? weekCount : 0;

      workoutsThisWeek.value = weekCount;
      workoutsThisMonth.value = monthCount;
      totalWorkouts.value = total;
      currentStreak.value = streak;
      totalMinutesExercised.value = totalMinutes;

      print('📊 Workout Stats: Week=$weekCount, Month=$monthCount, Total=$total');
    } catch (e) {
      print('Error loading workout stats: $e');
    }
  }

  Future<void> _loadWeightHistory(String userId) async {
    try {
      // For now, use current weight
      // TODO: Implement weight tracking history in Firebase
      if (userData.value != null) {
        weightHistory.value = [
          {
            'date': DateTime.now().subtract(const Duration(days: 30)),
            'weight': currentWeight.value + 2,
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 15)),
            'weight': currentWeight.value + 1,
          },
          {
            'date': DateTime.now(),
            'weight': currentWeight.value,
          },
        ];
      }
    } catch (e) {
      print('Error loading weight history: $e');
    }
  }

  void _checkAchievements() {
    unlockedAchievements.clear();
    
    // First Workout
    if (totalWorkouts.value >= 1) {
      unlockedAchievements.add('first_workout');
    }
    
    // Milestone achievements
    if (totalWorkouts.value >= 10) {
      unlockedAchievements.add('10_workouts');
    }
    if (totalWorkouts.value >= 25) {
      unlockedAchievements.add('25_workouts');
    }
    if (totalWorkouts.value >= 50) {
      unlockedAchievements.add('50_workouts');
    }
    if (totalWorkouts.value >= 100) {
      unlockedAchievements.add('100_workouts');
    }
    
    // Streak achievements
    if (currentStreak.value >= 3) {
      unlockedAchievements.add('3_day_streak');
    }
    if (currentStreak.value >= 7) {
      unlockedAchievements.add('7_day_streak');
    }
    if (currentStreak.value >= 14) {
      unlockedAchievements.add('14_day_streak');
    }
    if (currentStreak.value >= 30) {
      unlockedAchievements.add('30_day_streak');
    }
  }

  // Get weight trend data for chart
  List<FlSpot> getWeightTrendData() {
    if (weightHistory.isEmpty) return [];
    
    return weightHistory.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['weight'].toDouble());
    }).toList();
  }

  // Get achievement info
  Map<String, dynamic> getAchievementInfo(String achievementId) {
    final achievements = {
      'first_workout': {
        'title': 'First Step',
        'description': 'Complete your first workout',
        'icon': Icons.fitness_center,
        'color': Colors.blue,
      },
      '10_workouts': {
        'title': 'Getting Started',
        'description': 'Complete 10 workouts',
        'icon': Icons.star,
        'color': Colors.orange,
      },
      '25_workouts': {
        'title': 'Committed',
        'description': 'Complete 25 workouts',
        'icon': Icons.star,
        'color': Colors.purple,
      },
      '50_workouts': {
        'title': 'Dedicated',
        'description': 'Complete 50 workouts',
        'icon': Icons.star,
        'color': Colors.red,
      },
      '100_workouts': {
        'title': 'Century Club',
        'description': 'Complete 100 workouts',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      },
      '3_day_streak': {
        'title': 'On Fire',
        'description': '3 day workout streak',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
      '7_day_streak': {
        'title': 'Week Warrior',
        'description': '7 day workout streak',
        'icon': Icons.local_fire_department,
        'color': Colors.deepOrange,
      },
      '14_day_streak': {
        'title': 'Unstoppable',
        'description': '14 day workout streak',
        'icon': Icons.local_fire_department,
        'color': Colors.red,
      },
      '30_day_streak': {
        'title': 'Legend',
        'description': '30 day workout streak',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      },
    };
    
    return achievements[achievementId] ?? {
      'title': 'Unknown',
      'description': '',
      'icon': Icons.help,
      'color': Colors.grey,
    };
  }

  Future<void> refreshData() async {
    await _loadProgressData();
  }
}
