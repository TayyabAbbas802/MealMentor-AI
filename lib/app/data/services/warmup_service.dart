import '../models/warmup_exercise.dart';

/// Service for managing warmup exercises
class WarmupService {
  /// Get universal warmup routine suitable for all workouts
  static List<WarmupExercise> getUniversalWarmup() {
    return [
      // Phase 1: Light Cardio (2.5 minutes total)
      WarmupExercise(
        name: 'Marching in Place',
        description: 'March in place, lifting knees to hip height. Keep a steady pace.',
        durationSeconds: 60,
        category: 'cardio',
      ),
      WarmupExercise(
        name: 'Jumping Jacks',
        description: 'Classic jumping jacks to elevate heart rate. Jump feet apart while raising arms overhead.',
        durationSeconds: 60,
        category: 'cardio',
      ),
      WarmupExercise(
        name: 'High Knees',
        description: 'Run in place, bringing knees up high towards your chest.',
        durationSeconds: 30,
        category: 'cardio',
      ),

      // Phase 2: Dynamic Stretching (5 minutes total)
      WarmupExercise(
        name: 'Arm Circles',
        description: 'Extend arms straight out to sides. Make small circles, gradually increasing size. Do 30s forward, 30s backward.',
        durationSeconds: 60,
        category: 'dynamic_stretch',
      ),
      WarmupExercise(
        name: 'Arm Swings',
        description: 'Swing arms across chest and back out to sides. Keep movement fluid and controlled.',
        durationSeconds: 30,
        category: 'dynamic_stretch',
      ),
      WarmupExercise(
        name: 'Leg Swings',
        description: 'Hold onto support. Swing one leg forward and back. Keep leg straight and controlled.',
        reps: 20,
        durationSeconds: 40,
        category: 'dynamic_stretch',
      ),
      WarmupExercise(
        name: 'Walking Lunges',
        description: 'Step forward into lunge position, alternating legs. Keep front knee over ankle.',
        reps: 20,
        durationSeconds: 60,
        category: 'dynamic_stretch',
      ),
      WarmupExercise(
        name: 'Butt Kicks',
        description: 'Jog in place while kicking heels up towards glutes. Maintain upright posture.',
        reps: 20,
        durationSeconds: 30,
        category: 'dynamic_stretch',
      ),
      WarmupExercise(
        name: 'Torso Twists',
        description: 'Stand with feet shoulder-width apart. Rotate torso side to side, keeping hips stable.',
        reps: 20,
        durationSeconds: 30,
        category: 'dynamic_stretch',
      ),
      WarmupExercise(
        name: 'Inchworms',
        description: 'Bend down, walk hands out to plank position, then walk hands back to feet. Stand up.',
        reps: 5,
        durationSeconds: 45,
        category: 'dynamic_stretch',
      ),
      WarmupExercise(
        name: 'Squat-to-Stand',
        description: 'Touch toes, sit back into deep squat, then stand up. Repeat smoothly.',
        reps: 10,
        durationSeconds: 45,
        category: 'dynamic_stretch',
      ),
    ];
  }

  /// Get total warmup duration in seconds
  static int getTotalWarmupDuration() {
    return getUniversalWarmup()
        .fold(0, (sum, exercise) => sum + exercise.durationSeconds);
  }

  /// Get warmup duration in minutes (formatted)
  static String getWarmupDurationMinutes() {
    final seconds = getTotalWarmupDuration();
    final minutes = (seconds / 60).ceil();
    return '$minutes min';
  }

  /// Get warmup exercises by category
  static List<WarmupExercise> getWarmupByCategory(String category) {
    return getUniversalWarmup()
        .where((exercise) => exercise.category == category)
        .toList();
  }

  /// Get cardio warmup exercises
  static List<WarmupExercise> getCardioWarmup() {
    return getWarmupByCategory('cardio');
  }

  /// Get dynamic stretching exercises
  static List<WarmupExercise> getDynamicStretches() {
    return getWarmupByCategory('dynamic_stretch');
  }
}
