// lib/data/models/workout_plan_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutPlanModel {
  final String id;
  final String name;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int daysPerWeek; // 5 or 6
  final String goal; // 'muscle_gain', 'weight_loss', 'maintenance'
  final DateTime createdAt;
  final List<WorkoutDayModel> daysSchedule;

  WorkoutPlanModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.daysPerWeek,
    required this.goal,
    required this.createdAt,
    required this.daysSchedule,
  });

  factory WorkoutPlanModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return WorkoutPlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'My Workout Plan',
      difficulty: json['difficulty'] ?? 'Intermediate',
      daysPerWeek: json['daysPerWeek'] ?? 5,
      goal: json['goal'] ?? 'maintenance',
      createdAt: parseDate(json['createdAt']),
      daysSchedule: (json['daysSchedule'] as List?)
          ?.map((day) => WorkoutDayModel.fromJson(day))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'difficulty': difficulty,
    'daysPerWeek': daysPerWeek,
    'goal': goal,
    'createdAt': createdAt.toIso8601String(),
    'daysSchedule': daysSchedule.map((day) => day.toJson()).toList(),
  };
}

class WorkoutDayModel {
  final int dayIndex;
  final String dayName;
  final bool isRest;
  final List<String> focusMuscles;
  final List<ExerciseSessionModel> exercises;

  WorkoutDayModel({
    required this.dayIndex,
    required this.dayName,
    required this.isRest,
    required this.focusMuscles,
    required this.exercises,
  });

  factory WorkoutDayModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDayModel(
      dayIndex: json['dayIndex'] ?? 0,
      dayName: json['dayName'] ?? 'Rest Day',
      isRest: json['isRest'] ?? false,
      focusMuscles: List<String>.from(json['focusMuscles'] ?? []),
      exercises: (json['exercises'] as List?)
          ?.map((ex) => ExerciseSessionModel.fromJson(ex))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'dayIndex': dayIndex,
    'dayName': dayName,
    'isRest': isRest,
    'focusMuscles': focusMuscles,
    'exercises': exercises.map((ex) => ex.toJson()).toList(),
  };
}

class ExerciseSessionModel {
  final int wgerId;
  final String name;
  final int targetSets;
  final String targetReps;
  final int restSeconds;
  final List<String> equipment;
  final String? notes;
  final String? muscleGroup;
  final String? gifUrl;

  ExerciseSessionModel({
    required this.wgerId,
    required this.name,
    required this.targetSets,
    required this.targetReps,
    required this.restSeconds,
    required this.equipment,
    this.notes,
    this.muscleGroup,
    this.gifUrl,
  });

  factory ExerciseSessionModel.fromJson(Map<String, dynamic> json) {
    return ExerciseSessionModel(
      wgerId: json['wgerId'] ?? 0,
      name: json['name'] ?? '',
      targetSets: json['targetSets'] ?? 3,
      targetReps: json['targetReps'] ?? '10-12',
      restSeconds: json['restSeconds'] ?? 60,
      equipment: List<String>.from(json['equipment'] ?? []),
      notes: json['notes'],
      muscleGroup: json['muscleGroup'],
      gifUrl: json['gifUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'wgerId': wgerId,
    'name': name,
    'targetSets': targetSets,
    'targetReps': targetReps,
    'restSeconds': restSeconds,
    'equipment': equipment,
    'notes': notes,
    'muscleGroup': muscleGroup,
    'gifUrl': gifUrl,
  };
}