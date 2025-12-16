import '../models/user_model.dart';

/// Manages exercise safety protocols including starting weights,
/// progressive overload, and injury prevention based on user metrics
class ExerciseSafetyManager {
  // Beginner starting weights (in kg)
  static const Map<String, Map<String, double>> beginnerWeights = {
    'upper_body': {
      'male': 5.0, // 10-12 lbs
      'female': 2.5, // 5-8 lbs
    },
    'lower_body': {
      'male': 10.0, // 20-25 lbs
      'female': 5.0, // 10-15 lbs
    },
  };

  /// Get starting weight recommendation for a beginner
  static double getStartingWeight({
    required String gender,
    required String muscleGroup,
    required String fitnessLevel,
  }) {
    if (fitnessLevel != 'Beginner') {
      // For intermediate/advanced, use higher starting weights
      final multiplier = fitnessLevel == 'Intermediate' ? 2.0 : 3.0;
      final beginnerWeight = _getBeginnerWeight(gender, muscleGroup);
      return beginnerWeight * multiplier;
    }

    return _getBeginnerWeight(gender, muscleGroup);
  }

  static double _getBeginnerWeight(String gender, String muscleGroup) {
    final isLowerBody = ['legs', 'glutes', 'hamstrings', 'quads', 'calves']
        .any((m) => muscleGroup.toLowerCase().contains(m));

    final category = isLowerBody ? 'lower_body' : 'upper_body';
    final genderKey = gender.toLowerCase() == 'female' ? 'female' : 'male';

    return beginnerWeights[category]?[genderKey] ?? 5.0;
  }

  /// Get progressive overload plan based on fitness level
  static Map<String, dynamic> getProgressionPlan(String fitnessLevel) {
    switch (fitnessLevel) {
      case 'Beginner':
        return {
          'weeklyWeightIncrease': 2.5, // kg
          'weeklyRepIncrease': 2, // reps per week
          'formCheckWeeks': 2, // Master form before increasing
          'deloadWeek': 4, // Every 4th week reduce volume 40%
          'maxWeeklyIncrease': 0.05, // 5% max increase
        };
      case 'Intermediate':
        return {
          'weeklyWeightIncrease': 5.0,
          'weeklyRepIncrease': 1,
          'formCheckWeeks': 1,
          'deloadWeek': 6,
          'maxWeeklyIncrease': 0.10, // 10% max increase
        };
      case 'Advanced':
        return {
          'weeklyWeightIncrease': 5.0,
          'weeklyRepIncrease': 1,
          'formCheckWeeks': 0,
          'deloadWeek': 8,
          'maxWeeklyIncrease': 0.10,
        };
      default:
        return getProgressionPlan('Beginner');
    }
  }

  /// Get age-based exercise adjustments
  static Map<String, dynamic> getAgeAdjustments(int age) {
    if (age < 18) {
      return {
        'focusAreas': ['bodyweight', 'flexibility', 'coordination'],
        'avoidHeavyLifting': true,
        'emphasizeForm': true,
        'maxWeight': 'bodyweight_only',
      };
    } else if (age >= 65) {
      return {
        'balanceExercises': true,
        'fallPrevention': true,
        'lowerIntensity': true,
        'longerWarmup': true,
        'focusAreas': ['functional_fitness', 'balance', 'flexibility'],
        'avoidHighImpact': true,
      };
    } else if (age >= 50) {
      return {
        'jointProtection': true,
        'flexibilityEmphasis': true,
        'moderateIntensity': true,
        'avoidHighImpact': true,
      };
    }
    return {};
  }

  /// Get BMI-based exercise recommendations
  static Map<String, dynamic> getBMIRecommendations(double bmi) {
    if (bmi < 18.5) {
      // Underweight
      return {
        'cardioPercentage': 20,
        'strengthPercentage': 80,
        'preferredExercises': ['bodyweight', 'resistance_bands', 'light_weights'],
        'avoidExercises': ['high_intensity_cardio', 'long_distance_running'],
        'focus': 'muscle_building',
        'calorieAdjustment': 'surplus',
      };
    } else if (bmi >= 30) {
      // Obese
      return {
        'cardioPercentage': 70,
        'strengthPercentage': 30,
        'preferredExercises': [
          'swimming',
          'water_aerobics',
          'cycling',
          'chair_exercises',
          'walking'
        ],
        'avoidExercises': ['high_impact', 'jumping', 'running', 'plyometrics'],
        'intensity': 'low_to_moderate',
        'jointProtection': true,
        'focus': 'weight_loss',
      };
    } else if (bmi >= 25) {
      // Overweight
      return {
        'cardioPercentage': 60,
        'strengthPercentage': 40,
        'preferredExercises': ['walking', 'cycling', 'elliptical', 'swimming'],
        'avoidExercises': ['high_impact', 'heavy_jumping'],
        'intensity': 'moderate',
        'jointProtection': true,
        'focus': 'weight_loss',
      };
    } else {
      // Normal weight
      return {
        'cardioPercentage': 40,
        'strengthPercentage': 60,
        'preferredExercises': ['all'],
        'avoidExercises': [],
        'intensity': 'moderate_to_vigorous',
        'focus': 'balanced',
      };
    }
  }

  /// Check if an exercise is safe for the user
  static bool isExerciseSafe({
    required Map<String, dynamic> exercise,
    required UserModel user,
  }) {
    final bmiRecs = getBMIRecommendations(user.bmi);
    final ageAdjustments = getAgeAdjustments(user.age);

    // Check BMI-based restrictions
    final avoidExercises = bmiRecs['avoidExercises'] as List<dynamic>;
    final exerciseType = exercise['type']?.toString().toLowerCase() ?? '';
    
    for (final avoid in avoidExercises) {
      if (exerciseType.contains(avoid.toString().toLowerCase())) {
        return false;
      }
    }

    // Check age-based restrictions
    if (ageAdjustments['avoidHeavyLifting'] == true) {
      final requiresWeight = exercise['requiresWeight'] ?? false;
      if (requiresWeight) return false;
    }

    if (ageAdjustments['avoidHighImpact'] == true) {
      final isHighImpact = exercise['isHighImpact'] ?? false;
      if (isHighImpact) return false;
    }

    return true;
  }

  /// Get recommended sets and reps based on user profile
  static Map<String, int> getSetsAndReps({
    required String goal,
    required String fitnessLevel,
    required double bmi,
  }) {
    // Base recommendations from ACSM guidelines
    if (goal == 'weight_loss') {
      return {
        'sets': fitnessLevel == 'Beginner' ? 2 : 3,
        'reps': 12, // Higher reps for endurance
      };
    } else if (goal == 'muscle_gain') {
      return {
        'sets': fitnessLevel == 'Beginner' ? 3 : 4,
        'reps': fitnessLevel == 'Beginner' ? 10 : 8, // Hypertrophy range
      };
    } else {
      // Maintenance
      return {
        'sets': 2,
        'reps': 10,
      };
    }
  }

  /// Get recommended rest time between sets (in seconds)
  static int getRestTime({
    required String goal,
    required String fitnessLevel,
  }) {
    if (goal == 'muscle_gain') {
      return fitnessLevel == 'Beginner' ? 90 : 60;
    } else if (goal == 'weight_loss') {
      return 30; // Shorter rest for metabolic conditioning
    } else {
      return 60;
    }
  }
}
