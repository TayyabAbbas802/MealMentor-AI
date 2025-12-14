
// lib/presentation/widgets/exercise_card_widget.dart
import 'package:flutter/material.dart';
import '../data/models/workout_plan_model.dart';
import '../theme/app_colors.dart';

class ExerciseCardWidget extends StatelessWidget {
  final ExerciseSessionModel exercise;
  final int exerciseNumber;
  final VoidCallback? onTap;
  final bool isCompleted;

  const ExerciseCardWidget({
    required this.exercise,
    required this.exerciseNumber,
    this.onTap,
    this.isCompleted = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? AppColors.success : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            // Exercise number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$exerciseNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Exercise details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCompleted)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.targetSets} sets × ${exercise.targetReps} reps',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (exercise.equipment.isNotEmpty)
                    Text(
                      'Equipment: ${exercise.equipment.join(", ")}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}