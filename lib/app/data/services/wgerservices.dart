// lib/data/services/wgerservices.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WgerService {
  static const String baseUrl = 'https://wger.de/api/v2';
  final http.Client _httpClient;

  // Cache with timestamp
  List<Map<String, dynamic>> _cachedExercises = [];
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(hours: 24);

  WgerService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Check if cache is valid
  bool get _isCacheValid {
    if (_cacheTimestamp == null || _cachedExercises.isEmpty) return false;
    return DateTime.now().difference(_cacheTimestamp!) < _cacheDuration;
  }

  /// Fetch exercises using the rich 'exerciseinfo' endpoint
  Future<List<Map<String, dynamic>>> getExercises({
    String? category,
    List<String>? equipment,
    List<int>? muscles,
    String? language = '2', // 2 is English
  }) async {
    try {
      // Fetch if cache is empty or expired
      if (!_isCacheValid) {
        await _fetchAllExercises(language);
      }

      var exercises = List<Map<String, dynamic>>.from(_cachedExercises);

      print('🔍 Before filtering: ${exercises.length} exercises');
      print('   Category filter: $category');
      print('   Equipment filter: $equipment');
      print('   Muscles filter: $muscles');

      // Filter for quality: Must have name (but don't be too strict)
      exercises = exercises.where((ex) {
        final name = ex['name'];

        if (name == null) return false;

        if (name is String) {
          return name.trim().isNotEmpty;
        } else {
          final nameStr = name.toString();
          return nameStr.trim().isNotEmpty && nameStr != 'null';
        }
      }).toList();

      print('🔍 After name filter: ${exercises.length} exercises');

      // Apply Category Filter - ONLY if explicitly provided
      if (category != null && category != 'All') {
        exercises = exercises.where((ex) {
          final cat = ex['category'];
          return cat.toString().toLowerCase() == category.toLowerCase();
        }).toList();
        print('🔍 After category filter: ${exercises.length} exercises');
      }

      // Apply Muscle Filter - ONLY if explicitly provided
      if (muscles != null && muscles.isNotEmpty) {
        exercises = exercises.where((e) {
          final mList = e['muscles'] as List?;
          if (mList == null || mList.isEmpty) return false;
          return mList.any((m) => muscles.contains(m['id']));
        }).toList();
        print('🔍 After muscle filter: ${exercises.length} exercises');
      }

      // Apply Equipment Filter - ONLY if explicitly provided
      if (equipment != null && equipment.isNotEmpty) {
        exercises = exercises.where((e) {
          final eList = e['equipment_names'] as List<String>?;
          if (eList == null || eList.isEmpty) {
            return equipment.any((eq) =>
            eq.toLowerCase() == 'body weight' ||
                eq.toLowerCase() == 'bodyweight'
            );
          }
          return eList.any((eName) =>
              equipment.any((eq) =>
                  eName.toLowerCase().contains(eq.toLowerCase())
              )
          );
        }).toList();
        print('🔍 After equipment filter: ${exercises.length} exercises');
      }

      print('✅ Final filtered count: ${exercises.length} exercises');
      return exercises;
    } catch (e) {
      print('❌ Error in getExercises: $e');
      return [];
    }
  }

  /// Fetch ALL exercises with pagination
  Future<void> _fetchAllExercises(String? language) async {
    try {
      List<Map<String, dynamic>> allExercises = [];
      String? nextUrl = '$baseUrl/exerciseinfo/?language=${language ?? 2}&limit=100';
      int pageCount = 0;
      const maxPages = 10; // Safety limit to prevent infinite loops

      print('🔄 Fetching exercises from Wger API...');

      while (nextUrl != null && pageCount < maxPages) {
        print('📄 Fetching page ${pageCount + 1}...');

        final response = await _httpClient.get(Uri.parse(nextUrl));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = List<Map<String, dynamic>>.from(data['results']);

          // Process and add to collection
          allExercises.addAll(_processExercises(results));

          // Get next page URL
          nextUrl = data['next'];
          pageCount++;

          print('✅ Page $pageCount loaded: ${results.length} exercises');
        } else {
          print('❌ Failed to load page $pageCount: ${response.statusCode}');
          break;
        }
      }

      _cachedExercises = allExercises;
      _cacheTimestamp = DateTime.now();

      print('✅ Total exercises loaded: ${_cachedExercises.length}');
    } catch (e) {
      print('❌ Error fetching all exercises: $e');
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  /// Process raw exercise data into app format
  /// Process raw exercise data into app format
  List<Map<String, dynamic>> _processExercises(List<Map<String, dynamic>> rawExercises) {
    return rawExercises.map((ex) {
      // Debug first 5 exercises to see structure
      if (rawExercises.indexOf(ex) < 5) {
        print('🔍 Exercise ${rawExercises.indexOf(ex)}:');
        print('   Raw data: $ex');
        print('   Name field: ${ex['name']} (type: ${ex['name'].runtimeType})');
      }

      // Extract name - Wger API exerciseinfo endpoint stores names in translations array
      String exerciseName = 'Unknown Exercise';
      
      // First try the direct name field
      if (ex['name'] != null) {
        final nameField = ex['name'];
        if (nameField is String && nameField.isNotEmpty) {
          exerciseName = nameField;
        } else if (nameField is Map) {
          exerciseName = nameField['en']?.toString() ??
              nameField['2']?.toString() ??
              nameField.values.firstOrNull?.toString() ??
              'Unknown Exercise';
        }
      }
      
      // If name is still unknown, check translations array
      if (exerciseName == 'Unknown Exercise' && ex['translations'] != null) {
        final translations = ex['translations'];
        if (translations is List && translations.isNotEmpty) {
          // Try to find English translation (language ID 2)
          var englishTranslation = translations.firstWhere(
            (t) => t is Map && (t['language'] == 2 || t['language'] == '2'),
            orElse: () => null,
          );
          
          // If no English, use first available translation
          if (englishTranslation == null && translations.isNotEmpty) {
            englishTranslation = translations.first;
          }
          
          if (englishTranslation is Map && englishTranslation['name'] != null) {
            exerciseName = englishTranslation['name'].toString();
          }
        }
      }
      
      // Clean up the name
      if (exerciseName != 'Unknown Exercise') {
        exerciseName = exerciseName.trim();
        if (exerciseName.isEmpty || exerciseName == 'null') {
          exerciseName = 'Unknown Exercise';
        }
      }

      // Extract Image - handle different possible structures
      String? imageUrl;
      try {
        if (ex['images'] != null) {
          final images = ex['images'];
          if (images is List && images.isNotEmpty) {
            final firstImage = images[0];
            if (firstImage is Map) {
              imageUrl = firstImage['image']?.toString();
            } else if (firstImage is String) {
              imageUrl = firstImage;
            }
          }
        }
      } catch (e) {
        print('Error extracting image: $e');
      }

      // Extract Equipment Names
      List<String> equipmentNames = [];
      try {
        if (ex['equipment'] != null && ex['equipment'] is List) {
          equipmentNames = (ex['equipment'] as List)
              .map((e) {
            if (e is Map && e['name'] != null) {
              return e['name'].toString();
            } else if (e is String) {
              return e;
            }
            return '';
          })
              .where((name) => name.isNotEmpty)
              .toList();
        }
      } catch (e) {
        print('Error extracting equipment: $e');
      }

      // Extract Muscle Names
      List<String> muscleNames = [];
      try {
        if (ex['muscles'] != null && ex['muscles'] is List) {
          muscleNames = (ex['muscles'] as List)
              .map((m) {
            if (m is Map && m['name'] != null) {
              return m['name'].toString();
            } else if (m is String) {
              return m;
            }
            return '';
          })
              .where((name) => name.isNotEmpty)
              .toList();
        }
      } catch (e) {
        print('Error extracting muscles: $e');
      }

      // Extract Category Name
      String categoryName = 'Strength';
      try {
        if (ex['category'] != null) {
          if (ex['category'] is Map) {
            categoryName = ex['category']['name']?.toString() ?? 'Strength';
          } else {
            categoryName = ex['category'].toString();
          }
        }
      } catch (e) {
        print('Error extracting category: $e');
      }

      final processed = {
        'id': ex['id'],
        'name': exerciseName,
        'description': ex['description']?.toString() ?? '',
        'category': categoryName,
        'muscles': ex['muscles'] ?? [],
        'muscle_names': muscleNames,
        'equipment_names': equipmentNames,
        'gifUrl': imageUrl,
        'language': ex['language'],
      };

      // Debug first few processed results
      if (rawExercises.indexOf(ex) < 3) {
        print('✅ Processed: ${processed['name']} | Image: ${processed['gifUrl']}');
      }

      return processed;
    }).toList();
  }

  /// Get specific exercise by ID
  Future<Map<String, dynamic>?> getExercise(int id) async {
    final exercises = await getExercises();
    try {
      return exercises.firstWhere((e) => e['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get exercises by multiple muscle groups
  Future<List<Map<String, dynamic>>> getExercisesByMuscles(List<int> muscleIds) async {
    return getExercises(muscles: muscleIds);
  }

  /// Get available muscles
  Future<List<Map<String, dynamic>>> getMuscles() async {
    return [
      {'id': 2, 'name': 'Shoulders', 'icon': '💪'},
      {'id': 1, 'name': 'Biceps', 'icon': '💪'},
      {'id': 5, 'name': 'Triceps', 'icon': '💪'},
      {'id': 4, 'name': 'Chest', 'icon': '🫁'},
      {'id': 12, 'name': 'Back', 'icon': '🦴'},
      {'id': 10, 'name': 'Quads', 'icon': '🦵'},
      {'id': 11, 'name': 'Glutes', 'icon': '🍑'},
      {'id': 8, 'name': 'Calves', 'icon': '🦵'},
      {'id': 6, 'name': 'Abs', 'icon': '🎯'},
      {'id': 14, 'name': 'Cardio', 'icon': '❤️'},
    ];
  }

  /// Get available equipment
  Future<List<Map<String, dynamic>>> getEquipment() async {
    return [
      {'id': 7, 'name': 'Body Weight', 'icon': '🏃'},
      {'id': 3, 'name': 'Dumbbell', 'icon': '🏋️'},
      {'id': 2, 'name': 'Barbell', 'icon': '🏋️'},
      {'id': 8, 'name': 'Bench', 'icon': '🪑'},
      {'id': 1, 'name': 'SZ-Bar', 'icon': '💪'},
      {'id': 9, 'name': 'Cable', 'icon': '🔗'},
    ];
  }

  /// Get exercise categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    return [
      {'id': 1, 'name': 'Strength'},
      {'id': 2, 'name': 'Cardio'},
    ];
  }

  /// Force refresh cache
  Future<void> refreshCache() async {
    clearCache();
    await _fetchAllExercises('2');
  }

  /// Clear cache
  void clearCache() {
    _cachedExercises.clear();
    _cacheTimestamp = null;
  }

  /// Get cache info
  Map<String, dynamic> getCacheInfo() {
    return {
      'exerciseCount': _cachedExercises.length,
      'lastUpdated': _cacheTimestamp?.toIso8601String(),
      'isValid': _isCacheValid,
    };
  }
}