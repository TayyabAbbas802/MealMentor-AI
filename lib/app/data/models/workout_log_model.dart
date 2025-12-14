

import 'package:cloud_firestore/cloud_firestore.dart';

// lib/data/models/workout_log_model.dart

class WorkoutLogModel {
  final String id;
  final String planId;
  final DateTime date;
  final int dayIndex;
  final List<ExerciseLogModel> exerciseLogs;
  final int durationMinutes;
  final bool isCompleted;

  WorkoutLogModel({
    required this.id,
    required this.planId,
    required this.date,
    required this.dayIndex,
    required this.exerciseLogs,
    required this.durationMinutes,
    required this.isCompleted,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return WorkoutLogModel(
      id: json['id'] ?? '',
      planId: json['planId'] ?? '',
      date: parseDate(json['date']),
      dayIndex: json['dayIndex'] ?? 0,
      exerciseLogs: (json['exerciseLogs'] as List?)
          ?.map((log) => ExerciseLogModel.fromJson(log))
          .toList() ?? [],
      durationMinutes: json['durationMinutes'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'planId': planId,
    'date': date.toIso8601String(),
    'dayIndex': dayIndex,
    'exerciseLogs': exerciseLogs.map((log) => log.toJson()).toList(),
    'durationMinutes': durationMinutes,
    'isCompleted': isCompleted,
  };
}

class ExerciseLogModel {
  final int wgerId;
  final String name;
  bool completed;           // ✅ Not final anymore
  DateTime? completedAt;    // ✅ Not final anymore
  final List<SetLogModel> setLogs;
  String? notes;            // ✅ Not final anymore

  ExerciseLogModel({
    required this.wgerId,
    required this.name,
    required this.completed,
    this.completedAt,
    required this.setLogs,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'wgerId': wgerId,
      'name': name,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'setLogs': setLogs.map((set) => set.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ExerciseLogModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.tryParse(date);
      }
      return null;
    }

    return ExerciseLogModel(
      wgerId: json['wgerId'] as int,
      name: json['name'] as String,
      completed: json['completed'] as bool,
      completedAt: parseDate(json['completedAt']),
      setLogs: (json['setLogs'] as List<dynamic>)
          .map((set) => SetLogModel.fromJson(set as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

class SetLogModel {
  final int setNumber;
  final int reps;
  final double? weight;
  final int? rpe; // Rate of Perceived Exertion 1-10
  final bool completed;

  SetLogModel({
    required this.setNumber,
    required this.reps,
    this.weight,
    this.rpe,
    required this.completed,
  });

  factory SetLogModel.fromJson(Map<String, dynamic> json) {
    return SetLogModel(
      setNumber: json['setNumber'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
      rpe: json['rpe'],
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'reps': reps,
    'weight': weight,
    'rpe': rpe,
    'completed': completed,
  };
}
