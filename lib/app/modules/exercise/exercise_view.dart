import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import 'exercise_controller.dart';

class ExerciseView extends GetView<ExerciseController> {
  const ExerciseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: Obx(() => controller.filteredExercises.isEmpty
                ? _buildEmptyState()
                : _buildExerciseList()),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.categories.map((category) {
                bool isSelected = controller.selectedCategory.value == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) controller.selectCategory(category);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
          const SizedBox(height: 16),
          const Text(
            'Difficulty',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.difficulties.map((difficulty) {
                bool isSelected = controller.selectedDifficulty.value == difficulty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(difficulty),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) controller.selectDifficulty(difficulty);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: controller.filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = controller.filteredExercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Card(
      child: InkWell(
        onTap: () => controller.viewExerciseDetails(exercise),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: _getCategoryColor(exercise['category']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(exercise['category']),
                  size: 40,
                  color: _getCategoryColor(exercise['category']),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                exercise['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                exercise['category'],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise['duration']} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${exercise['calories']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cardio':
        return Colors.red;
      case 'Strength':
        return Colors.blue;
      case 'Yoga':
        return Colors.purple;
      case 'HIIT':
        return Colors.orange;
      case 'Flexibility':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cardio':
        return Icons.directions_run;
      case 'Strength':
        return Icons.fitness_center;
      case 'Yoga':
        return Icons.self_improvement;
      case 'HIIT':
        return Icons.flash_on;
      case 'Flexibility':
        return Icons.accessibility_new;
      default:
        return Icons.sports;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No exercises found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
