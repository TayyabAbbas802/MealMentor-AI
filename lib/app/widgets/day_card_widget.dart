// lib/presentation/widgets/day_card_widget.dart
import 'package:flutter/material.dart';
import '../data/models/workout_plan_model.dart';
import '../theme/app_colors.dart';

class DayCardWidget extends StatelessWidget {
  final WorkoutDayModel day;
  final int dayIndex;
  final VoidCallback? onTap;
  final bool isSelected;

  const DayCardWidget({
    required this.day,
    required this.dayIndex,
    this.onTap,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: day.isRest ? AppColors.surfaceVariant : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (day.isRest ? AppColors.border : AppColors.primary),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day.dayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (day.isRest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Rest',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (day.isRest)
              const Text(
                'Recovery day. Stay active!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              )
            else ...[
              Wrap(
                spacing: 6,
                children: day.focusMuscles
                    .map((muscle) => _buildMuscleBadge(muscle))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Text(
                '${day.exercises.length} exercises',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleBadge(String muscle) {
    final color = AppColors.getMuscleColor(muscle);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        muscle.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
