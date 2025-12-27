// Example: How to use YouTube videos in your workout screens

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meal_mentor_ai/app/widgets/exercise_video_player.dart';
import 'package:meal_mentor_ai/app/data/services/wgerservices.dart';

/// Example 1: Exercise List with Video Thumbnails
class ExerciseListExample extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const ExerciseListExample({Key? key, required this.exercises}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        
        return Card(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Video thumbnail (replaces static image)
              ExerciseVideoThumbnail(
                youtubeVideoId: exercise['youtubeVideoId'],
                exerciseName: exercise['name'],
                height: 200,
                onTap: () {
                  // Show full video player
                  _showVideoDialog(context, exercise);
                },
              ),
              
              // Exercise details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVideoDialog(BuildContext context, Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Full video player
            ExerciseVideoPlayer(
              youtubeVideoId: exercise['youtubeVideoId'],
              exerciseName: exercise['name'],
              autoPlay: true,
            ),
            
            // Close button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 2: Exercise Detail Screen with Video
class ExerciseDetailExample extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailExample({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise['name']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video player at the top
            ExerciseVideoPlayer(
              youtubeVideoId: exercise['youtubeVideoId'],
              exerciseName: exercise['name'],
              autoPlay: false,
              showControls: true,
            ),
            
            // Exercise information
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(exercise['description'] ?? 'No description available'),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Muscles Targeted',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: (exercise['muscle_names'] as List<String>?)
                        ?.map((muscle) => Chip(label: Text(muscle)))
                        .toList() ?? [],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example 3: Active Workout with Video Reference
class ActiveWorkoutExample extends StatelessWidget {
  final Map<String, dynamic> currentExercise;

  const ActiveWorkoutExample({Key? key, required this.currentExercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout'),
      ),
      body: Column(
        children: [
          // Video player (auto-loop for reference)
          Expanded(
            flex: 2,
            child: ExerciseVideoPlayer(
              youtubeVideoId: currentExercise['youtubeVideoId'],
              exerciseName: currentExercise['name'],
              autoPlay: true,
              showControls: false, // Minimal controls during workout
            ),
          ),
          
          // Workout controls
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentExercise['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '3 sets × 12 reps',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Mark set as complete
                    },
                    child: const Text('Complete Set'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Example 4: How to load exercises with videos in your controller
class WorkoutControllerExample extends GetxController {
  final wgerService = Get.find<WgerService>();
  final exercises = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExercises();
  }

  Future<void> loadExercises() async {
    try {
      isLoading.value = true;
      
      // Fetch exercises - YouTube videos are automatically fetched!
      final fetchedExercises = await wgerService.getExercises(
        category: 'Strength',
        muscles: [4, 1], // Chest and biceps
      );
      
      exercises.value = fetchedExercises;
      
      print('✅ Loaded ${exercises.length} exercises with videos');
    } catch (e) {
      print('❌ Error loading exercises: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
