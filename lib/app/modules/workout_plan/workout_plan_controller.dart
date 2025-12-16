// lib/presentation/controllers/workout_plan_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:meal_mentor_ai/app/data/models/workout_plan_model.dart';
import 'package:meal_mentor_ai/app/data/models/user_model.dart';
import 'package:meal_mentor_ai/app/data/services/wgerservices.dart';
import 'package:meal_mentor_ai/app/data/services/firebase_service.dart';
import 'package:meal_mentor_ai/app/data/services/exercise_safety_manager.dart';
import 'package:meal_mentor_ai/app/data/services/warmup_service.dart';
import '../../routes/app_routes.dart';


class WorkoutPlanController extends GetxController {
  late FirebaseService _firebaseService;  // ✅ Fixed: was WorkoutFirebaseService
  FirebaseService get firebaseService => _firebaseService;
  late WgerService _wgerService;

  final isLoading = false.obs;
  final selectedDifficulty = 'Beginner'.obs;
  final selectedDaysPerWeek = 5.obs;
  final userGoal = 'maintenance'.obs;

  final currentPlanId = Rx<String?>(null);
  final currentPlan = Rx<WorkoutPlanModel?>(null);
  final weeklyProgress = <int>[].obs;

  // Muscle group mapping for different goals
  static const Map<String, List<String>> _goalMuscles = {
    'muscle_gain': ['chest', 'back', 'shoulders', 'legs', 'biceps', 'triceps'],
    'weight_loss': ['cardio', 'legs', 'back', 'core'],
    'maintenance': ['chest', 'back', 'legs', 'shoulders', 'core'],
  };

  // ✅ FIXED: Proper type structure for split patterns
  static const Map<String, Map<int, List<Map<String, dynamic>>>> _splitPatterns = {
    'Beginner': {
      5: [
        {'day': 'Monday', 'focus': ['chest', 'shoulders'], 'isRest': false},
        {'day': 'Tuesday', 'focus': ['back', 'biceps'], 'isRest': false},
        {'day': 'Wednesday', 'focus': [], 'isRest': true},
        {'day': 'Thursday', 'focus': ['legs'], 'isRest': false},
        {'day': 'Friday', 'focus': ['core', 'triceps'], 'isRest': false},
        {'day': 'Saturday', 'focus': [], 'isRest': true},
        {'day': 'Sunday', 'focus': [], 'isRest': true},
      ],
      6: [
        {'day': 'Monday', 'focus': ['chest'], 'isRest': false},
        {'day': 'Tuesday', 'focus': ['back'], 'isRest': false},
        {'day': 'Wednesday', 'focus': ['legs'], 'isRest': false},
        {'day': 'Thursday', 'focus': ['shoulders'], 'isRest': false},
        {'day': 'Friday', 'focus': ['arms'], 'isRest': false},
        {'day': 'Saturday', 'focus': ['core'], 'isRest': false},
        {'day': 'Sunday', 'focus': [], 'isRest': true},
      ],
    },
    'Intermediate': {
      5: [
        {'day': 'Monday', 'focus': ['chest', 'triceps'], 'isRest': false},
        {'day': 'Tuesday', 'focus': ['back', 'biceps'], 'isRest': false},
        {'day': 'Wednesday', 'focus': ['legs'], 'isRest': false},
        {'day': 'Thursday', 'focus': [], 'isRest': true},
        {'day': 'Friday', 'focus': ['shoulders', 'core'], 'isRest': false},
        {'day': 'Saturday', 'focus': [], 'isRest': true},
        {'day': 'Sunday', 'focus': [], 'isRest': true},
      ],
      6: [
        {'day': 'Monday', 'focus': ['chest', 'shoulders'], 'isRest': false},
        {'day': 'Tuesday', 'focus': ['back', 'core'], 'isRest': false},
        {'day': 'Wednesday', 'focus': [], 'isRest': true},
        {'day': 'Thursday', 'focus': ['legs'], 'isRest': false},
        {'day': 'Friday', 'focus': ['chest', 'back'], 'isRest': false},
        {'day': 'Saturday', 'focus': ['shoulders', 'arms'], 'isRest': false},
        {'day': 'Sunday', 'focus': [], 'isRest': true},
      ],
    },
    'Advanced': {
      5: [
        {'day': 'Monday', 'focus': ['chest', 'shoulders'], 'isRest': false},
        {'day': 'Tuesday', 'focus': ['back', 'biceps'], 'isRest': false},
        {'day': 'Wednesday', 'focus': ['legs'], 'isRest': false},
        {'day': 'Thursday', 'focus': ['arms', 'core'], 'isRest': false},
        {'day': 'Friday', 'focus': ['full_body'], 'isRest': false},
        {'day': 'Saturday', 'focus': [], 'isRest': true},
        {'day': 'Sunday', 'focus': [], 'isRest': true},
      ],
      6: [
        {'day': 'Monday', 'focus': ['chest', 'shoulders'], 'isRest': false},
        {'day': 'Tuesday', 'focus': ['back', 'core'], 'isRest': false},
        {'day': 'Wednesday', 'focus': ['legs'], 'isRest': false},
        {'day': 'Thursday', 'focus': ['chest', 'triceps'], 'isRest': false},
        {'day': 'Friday', 'focus': ['back', 'biceps'], 'isRest': false},
        {'day': 'Saturday', 'focus': ['legs', 'shoulders'], 'isRest': false},
        {'day': 'Sunday', 'focus': [], 'isRest': true},
      ],
    },
  };

  @override
  void onInit() {
    super.onInit();
    _firebaseService = Get.find<FirebaseService>();  // ✅ Fixed
    _wgerService = Get.find<WgerService>();
    
    // Load existing workout plan if available
    loadUserWorkoutPlan();
  }
  
  /// Load user's existing workout plan from Firebase
  Future<void> loadUserWorkoutPlan() async {
    try {
      final userId = _firebaseService.currentUser?.uid;
      if (userId == null) {
        print('⚠️ No user logged in, cannot load workout plan');
        return;
      }
      
      isLoading.value = true;
      print('📥 Loading workout plan for user: $userId');
      
      // Fetch user's workout plans (returns List<Map<String, dynamic>>)
      final plansData = await _firebaseService.getWorkoutPlans(userId);
      
      if (plansData.isNotEmpty) {
        // Convert the first (most recent) plan to WorkoutPlanModel
        final planData = plansData.first;
        currentPlan.value = WorkoutPlanModel.fromJson(planData);
        currentPlanId.value = planData['id'] as String?;
        print('✅ Loaded workout plan: ${currentPlan.value?.name}');
      } else {
        print('ℹ️ No existing workout plan found');
        currentPlan.value = null;
        currentPlanId.value = null;
      }
    } catch (e) {
      print('❌ Error loading workout plan: $e');
      currentPlan.value = null;
      currentPlanId.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  void selectDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
  }

  void selectDaysPerWeek(int days) {
    selectedDaysPerWeek.value = days;
  }

  /// Generate personalized workout plan based on user inputs
  Future<void> generateWorkoutPlan() async {
    try {
      isLoading.value = true;

      // Get userId and user data
      final userId = _firebaseService.currentUser!.uid;
      print('🏋️ Generating workout plan for user: $userId');

      // Verify user document exists and get full user data
      UserModel? userDoc;
      try {
        userDoc = await _firebaseService.getUserDocument(userId);
        if (userDoc == null) {
          print('⚠️ User document not found. Creating...');
          final currentUser = _firebaseService.currentUser!;
          await _firebaseService.createUserDocument(
            userId: userId,
            name: currentUser.displayName ?? 'User',
            email: currentUser.email ?? '',
          );
          // Fetch again after creation
          userDoc = await _firebaseService.getUserDocument(userId);
        }
        
        if (userDoc != null) {
          // Update userGoal from Firebase
          userGoal.value = userDoc.goal ?? 'maintenance';
          print('✅ User goal: ${userGoal.value}');
          print('📊 User BMI: ${userDoc.bmi.toStringAsFixed(1)} (${userDoc.bmiCategory})');
          print('💪 Fitness Level: ${userDoc.fitnessLevel ?? selectedDifficulty.value}');
        }
      } catch (e) {
        print('❌ Error checking user document: $e');
        Get.snackbar(
          'Error',
          'Failed to load user data. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // If user data is incomplete, show warning
      if (userDoc == null || userDoc.weight == 0 || userDoc.height == 0) {
        Get.snackbar(
          'Incomplete Profile',
          'Please update your weight and height in profile settings for personalized workout plans.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }

      // Fetch ALL exercises from Wger API
      print('📥 Fetching exercises from Wger API...');
      final allExercises = await _wgerService.getExercises();
      
      if (allExercises.isEmpty) {
        throw Exception('No exercises available from API');
      }

      print('✅ Fetched ${allExercises.length} exercises');

      // Filter exercises with GIFs (prioritize visual guidance)
      final exercisesWithGifs = allExercises.where((ex) {
        final hasGif = ex['gifUrl'] != null && ex['gifUrl'].toString().isNotEmpty;
        return hasGif;
      }).toList();

      print('🎬 ${exercisesWithGifs.length} exercises have GIFs');

      // Use exercises with GIFs if available, otherwise use all
      final exercisesToUse = exercisesWithGifs.isNotEmpty ? exercisesWithGifs : allExercises;

      // Get split pattern based on selection
      final splitPattern = _splitPatterns[selectedDifficulty.value]![selectedDaysPerWeek.value]!;

      // Create workout days with research-based exercise selection
      final daysSchedule = <WorkoutDayModel>[];
      int dayIndex = 0;

      for (var dayPattern in splitPattern) {
        if (dayPattern['isRest'] as bool) {
          // Rest day
          daysSchedule.add(WorkoutDayModel(
            dayIndex: dayIndex,
            dayName: dayPattern['day'] as String,
            isRest: true,
            focusMuscles: [],
            exercises: [],
          ));
        } else {
          // Workout day - select exercises based on difficulty and goal
          final focusMuscles = List<String>.from(dayPattern['focus'] as List);
          
          print('📅 ${dayPattern['day']}: Selecting exercises for $focusMuscles');
          
          final dayExercises = await _selectExercisesForDay(
            exercisesToUse,
            focusMuscles,
            selectedDifficulty.value,
            userGoal.value,
            userDoc, // Pass user data for personalization
          );

          if (dayExercises.isEmpty) {
            print('⚠️ No exercises found for ${dayPattern['day']}');
          } else {
            print('✅ Selected ${dayExercises.length} exercises for ${dayPattern['day']}');
          }

          // Add universal warmup for workout days
          final warmupExercises = WarmupService.getUniversalWarmup();
          print('🔥 Added ${warmupExercises.length} warmup exercises (${WarmupService.getWarmupDurationMinutes()})');

          daysSchedule.add(WorkoutDayModel(
            dayIndex: dayIndex,
            dayName: dayPattern['day'] as String,
            isRest: false,
            focusMuscles: focusMuscles,
            exercises: dayExercises,
            warmupExercises: warmupExercises, // Add warmup
          ));
        }
        dayIndex++;
      }

      // Verify we have at least some exercises
      final totalExercises = daysSchedule
          .where((day) => !day.isRest)
          .fold<int>(0, (sum, day) => sum + day.exercises.length);

      if (totalExercises == 0) {
        throw Exception('Could not generate workout plan. No suitable exercises found.');
      }

      // Create plan object
      final planName = 'My ${selectedDifficulty.value} ${selectedDaysPerWeek.value}-Day Plan';

      print('💾 Saving workout plan to Firebase...');

      // Save to Firebase
      final planId = await _firebaseService.createWorkoutPlan(
        userId: userId,
        name: planName,
        difficulty: selectedDifficulty.value,
        daysPerWeek: selectedDaysPerWeek.value,
        goal: userGoal.value,
        daysSchedule: daysSchedule.map((day) => day.toJson()).toList(),
      );

      currentPlanId.value = planId;

      // Load the created plan
      await loadWorkoutPlan(userId, planId);

      print('✅ Workout plan created successfully!');

      Get.snackbar(
        'Success',
        'Your personalized workout plan is ready!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to weekly plan
      Get.offNamed(AppRoutes.WEEKLY_PLAN);
      
    } catch (e, stackTrace) {
      print('❌ Error generating workout plan: $e');
      print('Stack trace: $stackTrace');
      
      String errorMessage = 'Failed to generate workout plan';
      
      if (e.toString().contains('No exercises available')) {
        errorMessage = 'Unable to fetch exercises. Please check your internet connection.';
      } else if (e.toString().contains('No suitable exercises')) {
        errorMessage = 'Could not find appropriate exercises. Please try different settings.';
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Select exercises for a specific day based on research-based principles
  Future<List<ExerciseSessionModel>> _selectExercisesForDay(
    List<Map<String, dynamic>> allExercises,
    List<String> targetMuscles,
    String difficulty,
    String goal,
    UserModel? user, // Add user parameter for personalization
  ) async {
    final selectedExercises = <ExerciseSessionModel>[];
    
    // Get BMI-based recommendations if user data available
    Map<String, dynamic>? bmiRecs;
    Map<String, dynamic>? ageAdjustments;
    
    if (user != null && user.weight > 0 && user.height > 0) {
      bmiRecs = ExerciseSafetyManager.getBMIRecommendations(user.bmi);
      ageAdjustments = ExerciseSafetyManager.getAgeAdjustments(user.age);
      
      print('  📊 BMI-based filtering: ${bmiRecs['focus']} focus');
      if (bmiRecs['jointProtection'] == true) {
        print('  🦴 Joint protection enabled - filtering high-impact exercises');
      }
    }
    
    // Determine number of exercises per muscle based on difficulty
    final exercisesPerMuscle = _getExercisesPerMuscle(difficulty);
    
    for (var muscle in targetMuscles) {
      print('  🎯 Finding exercises for: $muscle');
      
      // Find exercises that target this muscle
      var muscleExercises = allExercises.where((ex) {
        final muscleNames = ex['muscle_names'] as List<dynamic>?;
        if (muscleNames == null || muscleNames.isEmpty) return false;
        
        // Apply BMI-based filtering if available
        if (bmiRecs != null) {
          final avoidExercises = bmiRecs['avoidExercises'] as List<dynamic>;
          final exerciseName = (ex['name'] ?? '').toString().toLowerCase();
          
          // Check if exercise should be avoided
          for (final avoid in avoidExercises) {
            if (exerciseName.contains(avoid.toString().toLowerCase())) {
              return false;
            }
          }
          
          // For high BMI, prefer low-impact exercises
          if (bmiRecs['jointProtection'] == true) {
            // Skip exercises with jumping, high-impact movements
            if (exerciseName.contains('jump') || 
                exerciseName.contains('plyometric') ||
                exerciseName.contains('box')) {
              return false;
            }
          }
        }
        
        // Check if any muscle name matches
        return muscleNames.any((m) {
          final muscleName = m.toString().toLowerCase();
          final targetMuscle = muscle.toLowerCase();
          
          // Handle muscle name variations (Wger uses anatomical names)
          if (targetMuscle == 'chest') {
            return muscleName.contains('pectoral') || 
                   muscleName.contains('chest');
          }
          if (targetMuscle == 'shoulders') {
            return muscleName.contains('deltoid') || 
                   muscleName.contains('shoulder');
          }
          if (targetMuscle == 'back') {
            return muscleName.contains('latissimus') || 
                   muscleName.contains('trapezius') ||
                   muscleName.contains('rhomboid') ||
                   muscleName.contains('back');
          }
          if (targetMuscle == 'arms') {
            return muscleName.contains('bicep') || 
                   muscleName.contains('tricep') ||
                   muscleName.contains('brachialis');
          }
          if (targetMuscle == 'legs') {
            return muscleName.contains('quad') || 
                   muscleName.contains('glute') || 
                   muscleName.contains('hamstring') || 
                   muscleName.contains('leg') ||
                   muscleName.contains('gastrocnemius') ||
                   muscleName.contains('soleus');
          }
          if (targetMuscle == 'core') {
            return muscleName.contains('abs') || 
                   muscleName.contains('abdominal') ||
                   muscleName.contains('oblique') ||
                   muscleName.contains('core');
          }
          
          return muscleName.contains(targetMuscle) || targetMuscle.contains(muscleName);
        });
      }).toList();

      if (muscleExercises.isEmpty) {
        print('    ⚠️ No exercises found for $muscle, trying broader search...');
        // Fallback: search in exercise name
        muscleExercises = allExercises.where((ex) {
          final name = (ex['name'] ?? '').toString().toLowerCase();
          
          // Apply same muscle variations to name search
          if (muscle.toLowerCase() == 'chest') {
            return name.contains('chest') || name.contains('press') || name.contains('fly');
          }
          if (muscle.toLowerCase() == 'shoulders') {
            return name.contains('shoulder') || name.contains('raise') || name.contains('press');
          }
          if (muscle.toLowerCase() == 'back') {
            return name.contains('back') || name.contains('row') || name.contains('pull');
          }
          if (muscle.toLowerCase() == 'core') {
            return name.contains('crunch') || name.contains('plank') || name.contains('ab');
          }
          
          return name.contains(muscle.toLowerCase());
        }).toList();
      }

      print('    📊 Found ${muscleExercises.length} exercises for $muscle');

      // Prioritize compound movements for beginners and strength goals
      if (difficulty == 'Beginner' || goal.contains('muscle')) {
        muscleExercises.sort((a, b) {
          final aIsCompound = _isCompoundMovement(a['name'] ?? '');
          final bIsCompound = _isCompoundMovement(b['name'] ?? '');
          if (aIsCompound && !bIsCompound) return -1;
          if (!aIsCompound && bIsCompound) return 1;
          return 0;
        });
      }
      
      // Shuffle and take required number
      muscleExercises.shuffle();
      final exercisesToAdd = muscleExercises.take(exercisesPerMuscle).toList();
      
      // Get personalized sets, reps, and rest time
      final setsReps = user != null 
          ? ExerciseSafetyManager.getSetsAndReps(
              goal: goal,
              fitnessLevel: user.fitnessLevel ?? difficulty,
              bmi: user.bmi,
            )
          : {'sets': _getSetsForDifficulty(difficulty), 
             'reps': _getRepsForDifficulty(difficulty)};
      
      final restTime = user != null
          ? ExerciseSafetyManager.getRestTime(
              goal: goal,
              fitnessLevel: user.fitnessLevel ?? difficulty,
            )
          : _getRestForDifficulty(difficulty);
      
      for (var ex in exercisesToAdd) {
        selectedExercises.add(ExerciseSessionModel(
          wgerId: ex['id'] ?? 0,
          name: ex['name'] ?? 'Unknown Exercise',
          targetSets: setsReps['sets'] as int,
          targetReps: '${setsReps['reps']}',
          restSeconds: restTime,
          equipment: (ex['equipment_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? ['Body Weight'],
          muscleGroup: muscle,
          gifUrl: ex['gifUrl']?.toString(),
        ));
      }
      
      print('    ✅ Added ${exercisesToAdd.length} exercises for $muscle');
    }
    
    return selectedExercises;
  }

  /// Check if exercise is a compound movement
  bool _isCompoundMovement(String name) {
    final nameLower = name.toLowerCase();
    final compoundKeywords = [
      'squat', 'deadlift', 'bench press', 'pull up', 'chin up',
      'row', 'press', 'lunge', 'dip', 'clean', 'snatch'
    ];
    return compoundKeywords.any((keyword) => nameLower.contains(keyword));
  }

  /// Get number of exercises per muscle based on difficulty
  int _getExercisesPerMuscle(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return 2; // 2 exercises per muscle group
      case 'Intermediate':
        return 3; // 3 exercises per muscle group
      case 'Advanced':
        return 4; // 4 exercises per muscle group
      default:
        return 2;
    }
  }

  /// Get sets based on difficulty (ACSM guidelines)
  int _getSetsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return 3; // 3 sets for beginners
      case 'Intermediate':
        return 4; // 3-4 sets for intermediate
      case 'Advanced':
        return 5; // 4-5 sets for advanced
      default:
        return 3;
    }
  }

  /// Get reps based on difficulty (ACSM guidelines)
  String _getRepsForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return '12-15'; // Higher reps for beginners (muscular endurance)
      case 'Intermediate':
        return '8-12'; // Moderate reps for hypertrophy
      case 'Advanced':
        return '6-10'; // Lower reps for strength
      default:
        return '10-12';
    }
  }

  /// Get rest time based on difficulty (ACSM guidelines)
  int _getRestForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return 75; // 60-90 seconds (using 75 as middle)
      case 'Intermediate':
        return 52; // 45-60 seconds (using 52 as middle)
      case 'Advanced':
        return 37; // 30-45 seconds (using 37 as middle)
      default:
        return 60;
    }
  }


  /// Load existing workout plan
  Future<void> loadWorkoutPlan(String userId, String planId) async {
    try {
      isLoading.value = true;
      final planData = await _firebaseService.getWorkoutPlan(userId, planId);

      if (planData != null) {
        currentPlan.value = WorkoutPlanModel.fromJson(planData);
        currentPlanId.value = planId;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load plan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get all user's workout plans
  Future<List<WorkoutPlanModel>> getAllWorkoutPlans() async {
    try {
      isLoading.value = true;
      final userId = _firebaseService.currentUser!.uid;
      final plans = await _firebaseService.getWorkoutPlans(userId);
      return plans.map((plan) => WorkoutPlanModel.fromJson(plan)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load plans: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Swap workout days
  Future<void> swapWorkoutDays(int dayIndex1, int dayIndex2) async {
    try {
      if (currentPlan.value == null) return;

      final userId = _firebaseService.currentUser!.uid;
      final plan = currentPlan.value!;
      final days = [...plan.daysSchedule];

      // Swap
      final temp = days[dayIndex1];
      days[dayIndex1] = days[dayIndex2];
      days[dayIndex2] = temp;

      await _firebaseService.updateWorkoutPlan(
        userId: userId,
        planId: currentPlanId.value!,
        updateData: {
          'daysSchedule': days.map((d) => d.toJson()).toList(),
        },
      );

      currentPlan.value = WorkoutPlanModel(
        id: plan.id,
        name: plan.name,
        difficulty: plan.difficulty,
        daysPerWeek: plan.daysPerWeek,
        goal: plan.goal,
        createdAt: plan.createdAt,
        daysSchedule: days,
      );

      Get.snackbar('Success', 'Workout days swapped!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to swap days: $e');
    }
  }

  /// Delete workout plan
  Future<void> deleteWorkoutPlan(String planId) async {
    try {
      final userId = _firebaseService.currentUser!.uid;
      await _firebaseService.deleteWorkoutPlan(userId, planId);
      if (currentPlanId.value == planId) {
        currentPlanId.value = null;
        currentPlan.value = null;
      }
      Get.snackbar('Success', 'Workout plan deleted!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete plan: $e');
    }
  }
}
