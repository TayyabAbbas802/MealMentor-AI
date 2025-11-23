import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/services/firebase_service.dart';

class ExerciseController extends GetxController {
  final FirebaseService _firebaseService = Get.find<FirebaseService>();

  final isLoading = false.obs;
  final selectedCategory = 'All'.obs;
  final selectedDifficulty = 'All'.obs;

  final List<String> categories = ['All', 'Cardio', 'Strength', 'Yoga', 'HIIT', 'Flexibility'];
  final List<String> difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  final RxList<Map<String, dynamic>> allExercises = <Map<String, dynamic>>[
    {
      'id': '1',
      'name': 'Running',
      'category': 'Cardio',
      'difficulty': 'Beginner',
      'duration': 30,
      'calories': 300,
      'description': 'Great cardio exercise for overall fitness',
      'sets': 1,
      'reps': '30 min',
      'equipment': 'None',
    },
    {
      'id': '2',
      'name': 'Push-ups',
      'category': 'Strength',
      'difficulty': 'Beginner',
      'duration': 10,
      'calories': 50,
      'description': 'Upper body strength exercise',
      'sets': 3,
      'reps': '15',
      'equipment': 'None',
    },
    {
      'id': '3',
      'name': 'Yoga Flow',
      'category': 'Yoga',
      'difficulty': 'Intermediate',
      'duration': 45,
      'calories': 200,
      'description': 'Full body flexibility and strength',
      'sets': 1,
      'reps': '45 min',
      'equipment': 'Yoga Mat',
    },
    {
      'id': '4',
      'name': 'Burpees',
      'category': 'HIIT',
      'difficulty': 'Advanced',
      'duration': 20,
      'calories': 250,
      'description': 'High intensity full body workout',
      'sets': 4,
      'reps': '10',
      'equipment': 'None',
    },
    {
      'id': '5',
      'name': 'Squats',
      'category': 'Strength',
      'difficulty': 'Beginner',
      'duration': 15,
      'calories': 100,
      'description': 'Lower body strength builder',
      'sets': 3,
      'reps': '20',
      'equipment': 'None',
    },
    {
      'id': '6',
      'name': 'Cycling',
      'category': 'Cardio',
      'difficulty': 'Intermediate',
      'duration': 40,
      'calories': 350,
      'description': 'Low impact cardio exercise',
      'sets': 1,
      'reps': '40 min',
      'equipment': 'Bicycle',
    },
    {
      'id': '7',
      'name': 'Plank',
      'category': 'Strength',
      'difficulty': 'Intermediate',
      'duration': 5,
      'calories': 30,
      'description': 'Core strengthening exercise',
      'sets': 3,
      'reps': '60 sec',
      'equipment': 'None',
    },
    {
      'id': '8',
      'name': 'Stretching Routine',
      'category': 'Flexibility',
      'difficulty': 'Beginner',
      'duration': 15,
      'calories': 40,
      'description': 'Full body flexibility routine',
      'sets': 1,
      'reps': '15 min',
      'equipment': 'None',
    },
  ].obs;

  List<Map<String, dynamic>> get filteredExercises {
    return allExercises.where((exercise) {
      bool matchesCategory = selectedCategory.value == 'All' || exercise['category'] == selectedCategory.value;
      bool matchesDifficulty = selectedDifficulty.value == 'All' || exercise['difficulty'] == selectedDifficulty.value;
      return matchesCategory && matchesDifficulty;
    }).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void selectDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
  }

  void viewExerciseDetails(Map<String, dynamic> exercise) {
    Get.dialog(
      Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(exercise['category'], Colors.blue),
                    const SizedBox(width: 8),
                    _buildBadge(exercise['difficulty'], Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  exercise['description'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDetailItem('Duration', '${exercise['duration']} min', Icons.access_time),
                    _buildDetailItem('Calories', '${exercise['calories']}', Icons.local_fire_department),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoRow('Sets', '${exercise['sets']}'),
                const SizedBox(height: 8),
                _buildInfoRow('Reps', exercise['reps']),
                const SizedBox(height: 8),
                _buildInfoRow('Equipment', exercise['equipment']),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      startExercise(exercise);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Exercise'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.green),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void startExercise(Map<String, dynamic> exercise) {
    Get.snackbar(
      'Exercise Started',
      '${exercise['name']} workout has begun!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
