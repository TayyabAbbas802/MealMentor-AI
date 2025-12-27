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
  
  // Pagination
  final displayedExercises = <Map<String, dynamic>>[].obs;
  final currentPage = 0.obs;
  final pageSize = 50;
  final hasMoreExercises = true.obs;
  
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
    _loadUserData();
    fetchInitialExercises(); // Load only first page
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

  /// Fetch initial exercises (first 50 only)
  Future<void> fetchInitialExercises() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentPage.value = 0;

      final exercises = await _wgerService.getExercises();
      print('📊 Total exercises available: ${exercises.length}');

      // Transform and filter exercises with images
      final transformedExercises = exercises.map((ex) {
        final muscleNames = ex['muscle_names'] as List<dynamic>?;
        final primaryMuscle = (muscleNames?.isNotEmpty == true)
            ? muscleNames!.first.toString()
            : 'Full Body';

        return {
          'id': '${ex['id']}',
          'wgerId': ex['id'] ?? 0,
          'name': ex['name'] ?? 'Unknown Exercise',
          'category': ex['category'] ?? 'Strength',
          'difficulty': _calculateDifficulty(ex),
          'duration': 15,
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
      }).where((ex) {
        final gifUrl = ex['gifUrl'];
        return gifUrl != null && gifUrl.toString().isNotEmpty;
      }).toList();

      // Store all exercises
      allExercises.value = transformedExercises;
      
      // Display only first 50
      displayedExercises.value = transformedExercises.take(pageSize).toList();
      filteredExercises.value = displayedExercises;
      
      hasMoreExercises.value = transformedExercises.length > pageSize;

      print('✅ Loaded ${displayedExercises.length} of ${allExercises.length} exercises');
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

  /// Load more exercises (pagination)
  void loadMoreExercises() {
    if (!hasMoreExercises.value) return;

    final nextPage = currentPage.value + 1;
    final startIndex = nextPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, allExercises.length);

    if (startIndex >= allExercises.length) {
      hasMoreExercises.value = false;
      return;
    }

    final moreExercises = allExercises.sublist(startIndex, endIndex);
    displayedExercises.addAll(moreExercises);
    currentPage.value = nextPage;
    
    hasMoreExercises.value = endIndex < allExercises.length;
    
    print('📄 Loaded page $nextPage: ${moreExercises.length} more exercises');
  }

  /// Fetch exercises from Wger API (kept for compatibility)
  Future<void> fetchExercisesFromWger() async {
    await fetchInitialExercises();
  }

  /// Apply filters to exercise list
  void applyFilters() {
    // If search query exists, search across ALL exercises in real-time
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      
      filteredExercises.value = allExercises.where((exercise) {
        final name = (exercise['name'] ?? '').toString().toLowerCase();
        final description = (exercise['description'] ?? '').toString().toLowerCase();
        final muscles = (exercise['muscle_names'] as List?)
            ?.map((m) => m.toString().toLowerCase())
            .join(' ') ?? '';

        final matchesSearch = name.contains(query) ||
            description.contains(query) ||
            muscles.contains(query);
        
        if (!matchesSearch) return false;

        // Apply other filters
        if (selectedCategory.value != 'All' &&
            exercise['category'] != selectedCategory.value) {
          return false;
        }

        if (selectedDifficulty.value != 'All' &&
            exercise['difficulty'] != selectedDifficulty.value) {
          return false;
        }

        if (selectedMuscleGroup.value != 'All') {
          final exerciseMuscles = exercise['muscle_names'] as List<dynamic>?;
          if (exerciseMuscles == null || exerciseMuscles.isEmpty) {
            return false;
          }

          final normalizedFilter = selectedMuscleGroup.value.toLowerCase();
          final hasMatchingMuscle = exerciseMuscles.any((muscle) {
            final normalizedMuscle = muscle.toString().toLowerCase();
            return _matchesMuscleGroup(normalizedMuscle, normalizedFilter);
          });

          if (!hasMatchingMuscle) return false;
        }

        return true;
      }).toList();
      
      print('🔍 Search results: ${filteredExercises.length} exercises found for "$query"');
      return;
    }

    // No search query - filter displayed exercises only
    filteredExercises.value = displayedExercises.where((exercise) {
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
          return _matchesMuscleGroup(normalizedMuscle, normalizedFilter);
        });

        if (!hasMatchingMuscle) return false;
      }

      return true;
    }).toList();
  }

  /// Helper method to match muscle groups
  bool _matchesMuscleGroup(String muscleName, String filter) {
    // Direct match
    if (muscleName.contains(filter) || filter.contains(muscleName)) {
      return true;
    }
    
    // Map common names to anatomical names
    if (filter == 'chest' && 
        (muscleName.contains('pectoral') || muscleName.contains('chest'))) {
      return true;
    }
    if (filter == 'back' && 
        (muscleName.contains('latissimus') || muscleName.contains('trapezius') || 
         muscleName.contains('rhomboid') || muscleName.contains('back'))) {
      return true;
    }
    if (filter == 'shoulders' && 
        (muscleName.contains('deltoid') || muscleName.contains('shoulder'))) {
      return true;
    }
    if (filter == 'biceps' && 
        (muscleName.contains('bicep') || muscleName.contains('brachialis'))) {
      return true;
    }
    if (filter == 'triceps' && 
        muscleName.contains('tricep')) {
      return true;
    }
    if (filter == 'quads' && 
        (muscleName.contains('quad') || muscleName.contains('rectus femoris') ||
         muscleName.contains('vastus'))) {
      return true;
    }
    if (filter == 'glutes' && 
        (muscleName.contains('glute') || muscleName.contains('gluteus'))) {
      return true;
    }
    if (filter == 'calves' && 
        (muscleName.contains('calf') || muscleName.contains('gastrocnemius') ||
         muscleName.contains('soleus'))) {
      return true;
    }
    if (filter == 'abs' && 
        (muscleName.contains('ab') || muscleName.contains('oblique') ||
         muscleName.contains('rectus abdominis'))) {
      return true;
    }
    
    return false;
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