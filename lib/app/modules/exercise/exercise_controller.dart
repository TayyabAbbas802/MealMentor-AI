// lib/presentation/controllers/exercise_controller.dart
import 'package:get/get.dart';
import '../../data/services/wgerservices.dart';
import '../../data/services/firebase_service.dart';

class ExerciseController extends GetxController {
  late WgerService _wgerService;
  late FirebaseService _firebaseService;
  FirebaseService get firebaseService => _firebaseService;

  // Observable lists
  final allExercises = <Map<String, dynamic>>[].obs;
  final filteredExercises = <Map<String, dynamic>>[].obs;
  final favoriteExercises = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> userData = Rx<Map<String, dynamic>?>(null);
  // Loading & error states
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Filters
  final selectedCategory = 'All'.obs;
  final selectedDifficulty = 'All'.obs;
  final selectedMuscleGroup = 'All'.obs;
  final searchQuery = ''.obs;

  // Categories (matching Wger API)
  final categories = <String>[
    'All',
    'Strength',
    'Cardio',
  ].obs;

  final difficulties = <String>[
    'All',
    'Beginner',
    'Intermediate',
    'Advanced',
  ].obs;

  final muscleGroups = <String>[
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Quads',
    'Glutes',
    'Calves',
    'Abs',
    'Cardio',
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _wgerService = Get.find<WgerService>();
    _firebaseService = Get.find<FirebaseService>();
    _loadUserData(); // Add this
    fetchExercisesFromWger();
    _loadFavorites();
  }

  Future<void> _loadUserData() async {
    try {
      if (_firebaseService.currentUser != null) {
        final userDoc = await _firebaseService.getUserDocument(
            _firebaseService.currentUser!.uid
        );
        if (userDoc != null) {
          userData.value = userDoc.toJson();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Fetch exercises from Wger API
  Future<void> fetchExercisesFromWger() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final exercises = await _wgerService.getExercises();

      print('📊 Raw exercises count: ${exercises.length}');

      // Transform API data to our format
      allExercises.value = exercises.map((ex) {
        // Get primary muscle group
        final muscleNames = ex['muscle_names'] as List<dynamic>?;
        final primaryMuscle = (muscleNames?.isNotEmpty == true)
            ? muscleNames!.first.toString()
            : 'Full Body';

        // Debug print for first few exercises
        if (exercises.indexOf(ex) < 3) {
          print('🔍 Exercise ${ex['id']}: ${ex['name']}');
          print('   Category: ${ex['category']}');
          print('   Muscles: $muscleNames');
          print('   Equipment: ${ex['equipment_names']}');
        }

        return {
          'id': '${ex['id']}',
          'wgerId': ex['id'] ?? 0,
          'name': ex['name'] ?? 'Unknown Exercise',
          'category': ex['category'] ?? 'Strength',
          'difficulty': _calculateDifficulty(ex),
          'duration': 15, // Default duration in minutes
          'calories': _estimateCalories(ex),
          'description': _cleanDescription(ex['description'] ?? ''),
          'sets': _recommendSets(ex),
          'reps': _recommendReps(ex),
          'muscleGroup': _normalizeMuscleGroup(primaryMuscle),
          'muscle_names': muscleNames ?? ['Full Body'],
          'equipment': ex['equipment_names'] ?? ['Body Weight'],
          'instructions': _cleanDescription(ex['description'] ?? 'No instructions available'),
          'gifUrl': ex['gifUrl'],
          'isFavorite': false,
        };
      }).toList();

      // Filter to show only exercises with images
      final exercisesWithImages = allExercises.where((ex) {
        final gifUrl = ex['gifUrl'];
        return gifUrl != null && gifUrl.toString().isNotEmpty;
      }).toList();

      allExercises.value = exercisesWithImages;
      filteredExercises.value = exercisesWithImages;

      print('✅ Loaded ${allExercises.length} exercises with images (filtered from ${exercises.length} total)');
      print('📊 Sample exercise data:');
      if (allExercises.isNotEmpty) {
        final sample = allExercises.first;
        print('   Name: ${sample['name']}');
        print('   Muscles: ${sample['muscle_names']}');
        print('   GIF URL: ${sample['gifUrl']}');
      }

      // Update favorites status
      _updateFavoritesStatus();

    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to load exercises: $e';
      print('❌ Error loading exercises: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load exercises from Wger API',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Apply filters to exercise list
  void applyFilters() {
    filteredExercises.value = allExercises.where((exercise) {
      // Category filter
      if (selectedCategory.value != 'All' &&
          exercise['category'] != selectedCategory.value) {
        return false;
      }

      // Difficulty filter
      if (selectedDifficulty.value != 'All' &&
          exercise['difficulty'] != selectedDifficulty.value) {
        return false;
      }

      // Muscle group filter
      if (selectedMuscleGroup.value != 'All') {
        final exerciseMuscles = exercise['muscle_names'] as List<dynamic>?;
        if (exerciseMuscles == null || exerciseMuscles.isEmpty) {
          return false;
        }

        final normalizedFilter = selectedMuscleGroup.value.toLowerCase();
        final hasMatchingMuscle = exerciseMuscles.any((muscle) {
          final normalizedMuscle = muscle.toString().toLowerCase();
          
          // Direct match
          if (normalizedMuscle.contains(normalizedFilter) ||
              normalizedFilter.contains(normalizedMuscle)) {
            return true;
          }
          
          // Map common names to anatomical names
          if (normalizedFilter == 'chest' && 
              (normalizedMuscle.contains('pectoral') || normalizedMuscle.contains('chest'))) {
            return true;
          }
          if (normalizedFilter == 'back' && 
              (normalizedMuscle.contains('latissimus') || normalizedMuscle.contains('trapezius') || 
               normalizedMuscle.contains('rhomboid') || normalizedMuscle.contains('back'))) {
            return true;
          }
          if (normalizedFilter == 'shoulders' && 
              (normalizedMuscle.contains('deltoid') || normalizedMuscle.contains('shoulder'))) {
            return true;
          }
          if (normalizedFilter == 'biceps' && 
              (normalizedMuscle.contains('bicep') || normalizedMuscle.contains('brachialis'))) {
            return true;
          }
          if (normalizedFilter == 'triceps' && 
              normalizedMuscle.contains('tricep')) {
            return true;
          }
          if (normalizedFilter == 'quads' && 
              (normalizedMuscle.contains('quad') || normalizedMuscle.contains('rectus femoris') ||
               normalizedMuscle.contains('vastus'))) {
            return true;
          }
          if (normalizedFilter == 'glutes' && 
              (normalizedMuscle.contains('glute') || normalizedMuscle.contains('gluteus'))) {
            return true;
          }
          if (normalizedFilter == 'calves' && 
              (normalizedMuscle.contains('calf') || normalizedMuscle.contains('gastrocnemius') ||
               normalizedMuscle.contains('soleus'))) {
            return true;
          }
          if (normalizedFilter == 'abs' && 
              (normalizedMuscle.contains('ab') || normalizedMuscle.contains('oblique') ||
               normalizedMuscle.contains('rectus abdominis'))) {
            return true;
          }
          
          return false;
        });

        if (!hasMatchingMuscle) return false;
      }

      // Search query filter
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        final name = (exercise['name'] ?? '').toString().toLowerCase();
        final description = (exercise['description'] ?? '').toString().toLowerCase();
        final muscles = (exercise['muscle_names'] as List?)
            ?.map((m) => m.toString().toLowerCase())
            .join(' ') ?? '';

        return name.contains(query) ||
            description.contains(query) ||
            muscles.contains(query);
      }

      return true;
    }).toList();
  }

  /// Set category filter
  void setCategory(String category) {
    selectedCategory.value = category;
    applyFilters();
  }

  /// Set difficulty filter
  void setDifficulty(String difficulty) {
    selectedDifficulty.value = difficulty;
    applyFilters();
  }

  /// Set muscle group filter
  void setMuscleGroup(String muscleGroup) {
    selectedMuscleGroup.value = muscleGroup;
    applyFilters();
  }

  /// Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    selectedCategory.value = 'All';
    selectedDifficulty.value = 'All';
    selectedMuscleGroup.value = 'All';
    searchQuery.value = '';
    filteredExercises.value = allExercises;
  }

  /// Toggle favorite exercise
  Future<void> toggleFavorite(Map<String, dynamic> exercise) async {
    final index = favoriteExercises.indexWhere((e) => e['id'] == exercise['id']);

    if (index >= 0) {
      favoriteExercises.removeAt(index);
      exercise['isFavorite'] = false;
      await _saveFavorites();
      Get.snackbar(
        'Removed',
        '${exercise['name']} removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } else {
      favoriteExercises.add(exercise);
      exercise['isFavorite'] = true;
      await _saveFavorites();
      Get.snackbar(
        'Added',
        '${exercise['name']} added to favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }

    // Update the exercise in allExercises list
    final exerciseIndex = allExercises.indexWhere((e) => e['id'] == exercise['id']);
    if (exerciseIndex >= 0) {
      allExercises[exerciseIndex] = exercise;
      allExercises.refresh();
    }
  }

  /// Check if exercise is favorite
  bool isFavorite(Map<String, dynamic> exercise) {
    return favoriteExercises.any((e) => e['id'] == exercise['id']);
  }

  /// Get exercises by muscle group
  List<Map<String, dynamic>> getExercisesByMuscleGroup(String muscleGroup) {
    final normalized = muscleGroup.toLowerCase();
    return allExercises.where((ex) {
      final muscles = ex['muscle_names'] as List<dynamic>?;
      if (muscles == null || muscles.isEmpty) return false;

      return muscles.any((muscle) {
        final muscleName = muscle.toString().toLowerCase();
        return muscleName.contains(normalized) || normalized.contains(muscleName);
      });
    }).toList();
  }

  /// Get exercises by difficulty
  List<Map<String, dynamic>> getExercisesByDifficulty(String difficulty) {
    return allExercises
        .where((ex) => ex['difficulty'] == difficulty)
        .toList();
  }

  /// Get exercises by category
  List<Map<String, dynamic>> getExercisesByCategory(String category) {
    return allExercises
        .where((ex) => ex['category'] == category)
        .toList();
  }

  /// Get exercises by equipment
  List<Map<String, dynamic>> getExercisesByEquipment(List<String> equipment) {
    return allExercises.where((ex) {
      final exerciseEquipment = ex['equipment'] as List<dynamic>?;
      if (exerciseEquipment == null || exerciseEquipment.isEmpty) {
        return equipment.contains('Body Weight');
      }

      return exerciseEquipment.any((eq) =>
          equipment.any((e) =>
              eq.toString().toLowerCase().contains(e.toLowerCase())
          )
      );
    }).toList();
  }

  /// Refresh exercises
  Future<void> refreshExercises() async {
    _wgerService.clearCache();
    await fetchExercisesFromWger();
  }

  // ============ HELPER METHODS ============

  /// Normalize muscle group names
  String _normalizeMuscleGroup(String muscle) {
    final muscleLower = muscle.toLowerCase();

    final muscleMap = {
      'pectoralis major': 'chest',
      'chest': 'chest',
      'latissimus dorsi': 'back',
      'back': 'back',
      'deltoid': 'shoulders',
      'shoulders': 'shoulders',
      'biceps': 'biceps',
      'triceps': 'triceps',
      'quadriceps': 'quads',
      'quads': 'quads',
      'gluteus': 'glutes',
      'glutes': 'glutes',
      'calves': 'calves',
      'gastrocnemius': 'calves',
      'abs': 'abs',
      'abdominals': 'abs',
      'core': 'core',
    };

    for (var entry in muscleMap.entries) {
      if (muscleLower.contains(entry.key)) {
        return entry.value;
      }
    }

    return muscleLower;
  }

  /// Calculate difficulty based on exercise data
  String _calculateDifficulty(Map<String, dynamic> exercise) {
    final name = (exercise['name'] ?? '').toString().toLowerCase();
    final equipment = exercise['equipment_names'] as List<dynamic>?;

    // Advanced exercises
    if (name.contains('advanced') ||
        name.contains('explosive') ||
        name.contains('olympic') ||
        name.contains('complex') ||
        name.contains('one arm') ||
        name.contains('pistol')) {
      return 'Advanced';
    }

    // Beginner exercises
    if (name.contains('beginner') ||
        name.contains('basic') ||
        name.contains('assisted') ||
        (equipment != null && equipment.any((e) => e.toString().toLowerCase().contains('machine')))) {
      return 'Beginner';
    }

    // Body weight exercises are often beginner-intermediate
    if (equipment == null ||
        equipment.isEmpty ||
        equipment.any((e) => e.toString().toLowerCase() == 'body weight')) {
      return 'Beginner';
    }

    return 'Intermediate'; // Default
  }

  /// Recommend sets based on exercise type
  int _recommendSets(Map<String, dynamic> exercise) {
    final category = exercise['category']?.toString().toLowerCase() ?? '';

    if (category.contains('cardio')) {
      return 1; // Usually one continuous session
    } else if (category.contains('strength')) {
      return 3; // Standard for strength training
    }

    return 3; // Default
  }

  /// Recommend reps based on exercise type
  String _recommendReps(Map<String, dynamic> exercise) {
    final category = exercise['category']?.toString().toLowerCase() ?? '';
    final name = exercise['name']?.toString().toLowerCase() ?? '';

    if (category.contains('cardio')) {
      return '20-30 min';
    } else if (name.contains('plank') || name.contains('hold')) {
      return '30-60 sec';
    } else if (name.contains('power') || name.contains('explosive')) {
      return '5-8';
    }

    return '8-12'; // Standard for hypertrophy
  }

  /// Clean HTML description
  String _cleanDescription(String description) {
    if (description.isEmpty) return 'No description available';

    // Remove HTML tags
    String cleaned = description.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");

    // Remove extra whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleaned;
  }

  /// Estimate calories based on exercise
  int _estimateCalories(Map<String, dynamic> exercise) {
    final category = exercise['category']?.toString().toLowerCase() ?? '';
    final name = exercise['name']?.toString().toLowerCase() ?? '';

    if (category.contains('cardio') ||
        name.contains('running') ||
        name.contains('jump')) {
      return 120; // High calorie burn
    } else if (name.contains('squat') ||
        name.contains('deadlift') ||
        name.contains('burpee')) {
      return 80; // Compound movements
    } else if (category.contains('strength')) {
      return 50; // Standard strength training
    }

    return 40; // Default
  }

  /// Get exercise by ID
  Map<String, dynamic>? getExerciseById(String id) {
    try {
      return allExercises.firstWhere((ex) => ex['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get exercise by Wger ID
  Map<String, dynamic>? getExerciseByWgerId(int wgerId) {
    try {
      return allExercises.firstWhere((ex) => ex['wgerId'] == wgerId);
    } catch (e) {
      return null;
    }
  }

  /// Get random exercises for quick workout
  List<Map<String, dynamic>> getRandomExercises(int count, {String? category}) {
    var exercises = category != null
        ? allExercises.where((ex) => ex['category'] == category).toList()
        : allExercises.toList();

    exercises.shuffle();
    return exercises.take(count).toList();
  }

  /// Get recommended exercises based on goal
  List<Map<String, dynamic>> getRecommendedExercises(String goal, {int count = 10}) {
    List<Map<String, dynamic>> recommended;

    switch (goal.toLowerCase()) {
      case 'muscle_gain':
      case 'muscle gain':
        recommended = allExercises
            .where((ex) =>
        ex['category'] == 'Strength' &&
            ['chest', 'back', 'quads', 'shoulders'].contains(ex['muscleGroup']))
            .toList();
        break;

      case 'weight_loss':
      case 'weight loss':
        recommended = allExercises
            .where((ex) => ex['category'] == 'Cardio')
            .toList();
        break;

      case 'maintenance':
        recommended = allExercises
            .where((ex) => ex['difficulty'] == 'Intermediate')
            .toList();
        break;

      default:
        recommended = allExercises.toList();
    }

    recommended.shuffle();
    return recommended.take(count).toList();
  }

  /// Load favorites from local storage
  Future<void> _loadFavorites() async {
    try {
      // TODO: Implement local storage to persist favorites
      // Example using shared_preferences:
      // final prefs = await SharedPreferences.getInstance();
      // final favoritesJson = prefs.getStringList('favorite_exercises') ?? [];
      // favoriteExercises.value = favoritesJson.map((json) => jsonDecode(json)).toList();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  /// Save favorites to local storage
  Future<void> _saveFavorites() async {
    try {
      // TODO: Implement local storage to persist favorites
      // Example using shared_preferences:
      // final prefs = await SharedPreferences.getInstance();
      // final favoritesJson = favoriteExercises.map((ex) => jsonEncode(ex)).toList();
      // await prefs.setStringList('favorite_exercises', favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  /// Update favorites status in all exercises
  void _updateFavoritesStatus() {
    for (var exercise in allExercises) {
      exercise['isFavorite'] = isFavorite(exercise);
    }
    allExercises.refresh();
  }

  /// Export exercise data as JSON
  Map<String, dynamic> exportExercise(Map<String, dynamic> exercise) {
    return {
      'name': exercise['name'],
      'category': exercise['category'],
      'difficulty': exercise['difficulty'],
      'muscleGroup': exercise['muscleGroup'],
      'muscle_names': exercise['muscle_names'],
      'sets': exercise['sets'],
      'reps': exercise['reps'],
      'equipment': exercise['equipment'],
      'description': exercise['description'],
      'calories': exercise['calories'],
    };
  }

  /// Get cache information
  Map<String, dynamic> getCacheInfo() {
    return _wgerService.getCacheInfo();
  }
}