// lib/presentation/controllers/active_workout_controller.dart
import 'package:get/get.dart';
import 'dart:async';
import 'package:meal_mentor_ai/app/data/models/workout_log_model.dart';
import 'package:meal_mentor_ai/app/data/models/workout_plan_model.dart';
import 'package:meal_mentor_ai/app/data/services/firebase_service.dart';

class ActiveWorkoutController extends GetxController {
  late FirebaseService _firebaseService;

  final isWorkoutStarted = false.obs;
  final currentExerciseIndex = 0.obs;
  final workoutDuration = 0.obs; // in seconds
  late Timer _workoutTimer;

  final currentSet = 0.obs;
  final restTimer = 0.obs;
  final isResting = false.obs;
  Timer? _restTimerInstance;

  final completedExercises = <int>[].obs;
  final exerciseLogs = <ExerciseLogModel>[].obs;

  // Current workout session data
  late WorkoutDayModel currentDay;
  late String planId;
  late String userId;
  late int dayIndex;

  @override
  void onInit() {
    super.onInit();
    _firebaseService = Get.find<FirebaseService>();
  }

  /// Initialize workout session
  void initializeWorkout({
    required WorkoutDayModel day,
    required String planId,
    required String userId,
    required int dayIndex,
  }) {
    currentDay = day;
    this.planId = planId;
    this.userId = userId;
    this.dayIndex = dayIndex;
    currentExerciseIndex.value = 0;
    completedExercises.clear();
    exerciseLogs.clear();

    // Initialize logs for each exercise
    for (var exercise in day.exercises) {
      exerciseLogs.add(ExerciseLogModel(
        wgerId: exercise.wgerId,
        name: exercise.name,
        completed: false,
        setLogs: [],
      ));
    }
  }

  /// Start workout
  void startWorkout() {
    isWorkoutStarted.value = true;
    workoutDuration.value = 0;
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      workoutDuration.value++;
    });
  }

  /// End workout and save to Firebase
  Future<void> endWorkout() async {
    try {
      isWorkoutStarted.value = false;
      _workoutTimer.cancel();
      if (_restTimerInstance != null) {
        _restTimerInstance!.cancel();
      }

      // Save workout log
      final logId = await _firebaseService.logWorkout(
        userId: userId,
        planId: planId,
        dayIndex: dayIndex,
        exerciseLogs: exerciseLogs.map((log) => {
          'wgerId': log.wgerId,
          'name': log.name,
          'completed': log.completed,
          'completedAt': log.completedAt?.toIso8601String(),
          'setLogs': log.setLogs.map((set) => set.toJson()).toList(),
          'notes': log.notes,
        }).toList(),
        durationMinutes: workoutDuration.value ~/ 60,
      );

      Get.snackbar(
        'Success',
        'Workout completed and saved!',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reset state
      reset();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save workout: $e');
    }
  }

  /// Mark current exercise set as completed
  void completeSet({
    required int reps,
    required double? weight,
    required int? rpe,
  }) {
    if (currentExerciseIndex.value >= exerciseLogs.length) return;

    final log = exerciseLogs[currentExerciseIndex.value];
    log.setLogs.add(SetLogModel(
      setNumber: currentSet.value + 1,
      reps: reps,
      weight: weight,
      rpe: rpe,
      completed: true,
    ));

    currentSet.value++;

    // Check if all sets done
    final exercise = currentDay.exercises[currentExerciseIndex.value];
    if (currentSet.value >= exercise.targetSets) {
      completeExercise();
    } else {
      // Start rest timer
      startRestTimer(exercise.restSeconds);
    }
  }

  /// Mark exercise as completed
  void completeExercise() {
    if (currentExerciseIndex.value >= exerciseLogs.length) return;

    final log = exerciseLogs[currentExerciseIndex.value];
    log.completed = true;
    log.completedAt = DateTime.now();

    completedExercises.add(currentExerciseIndex.value);
    currentSet.value = 0;

    // Move to next exercise
    if (currentExerciseIndex.value < currentDay.exercises.length - 1) {
      currentExerciseIndex.value++;
    }
  }

  /// Skip current exercise
  void skipExercise() {
    if (currentExerciseIndex.value < currentDay.exercises.length - 1) {
      currentExerciseIndex.value++;
      currentSet.value = 0;
    }
  }

  /// Start rest timer between sets
  void startRestTimer(int seconds) {
    isResting.value = true;
    restTimer.value = seconds;

    _restTimerInstance = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restTimer.value > 0) {
        restTimer.value--;
      } else {
        isResting.value = false;
        timer.cancel();
      }
    });
  }

  /// Cancel rest timer
  void cancelRestTimer() {
    if (_restTimerInstance != null) {
      _restTimerInstance!.cancel();
    }
    isResting.value = false;
  }

  /// Get progress percentage
  double getProgress() {
    if (currentDay.exercises.isEmpty) return 0;
    return completedExercises.length / currentDay.exercises.length;
  }

  /// Get remaining time in format MM:SS
  String getFormattedWorkoutTime() {
    final minutes = workoutDuration.value ~/ 60;
    final seconds = workoutDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Reset controller
  void reset() {
    isWorkoutStarted.value = false;
    currentExerciseIndex.value = 0;
    workoutDuration.value = 0;
    currentSet.value = 0;
    restTimer.value = 0;
    isResting.value = false;
    completedExercises.clear();
    exerciseLogs.clear();
  }

  /// Get list of exercises for current day
  List<ExerciseSessionModel> get exercises => currentDay.exercises;

  /// Move to previous exercise
  void previousExercise() {
    if (currentExerciseIndex.value > 0) {
      currentExerciseIndex.value--;
      currentSet.value = 0;
    }
  }

  /// Move to next exercise (wrapper for skip or just navigation)
  void nextExercise() {
    if (currentExerciseIndex.value < currentDay.exercises.length - 1) {
      currentExerciseIndex.value++;
      currentSet.value = 0;
    } else {
      // If last exercise, maybe prompt to finish?
      // For now, just do nothing or show snackbar
      Get.snackbar('Last Exercise', 'You are on the last exercise. Finish it to complete workout.');
    }
  }

  @override
  void onClose() {
    _workoutTimer.cancel();
    if (_restTimerInstance != null) {
      _restTimerInstance!.cancel();
    }
    super.onClose();
  }
}
