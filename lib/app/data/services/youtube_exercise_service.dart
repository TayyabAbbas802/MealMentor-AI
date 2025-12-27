import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service to fetch exercise videos from YouTube Data API v3
class YouTubeExerciseService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  final http.Client _httpClient;
  
  // Cache for video IDs mapped to exercise names
  final Map<String, String> _videoCache = {};
  
  YouTubeExerciseService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Get YouTube API key from environment
  String? get _apiKey {
    try {
      return dotenv.get('YOUTUBE_API_KEY', fallback: '');
    } catch (e) {
      print('⚠️ YOUTUBE_API_KEY not found in .env file');
      return null;
    }
  }

  /// Search for exercise video by name
  /// Returns video ID if found, null otherwise
  Future<String?> searchExerciseVideo(String exerciseName) async {
    // Check cache first
    final cachedVideoId = _videoCache[exerciseName.toLowerCase()];
    if (cachedVideoId != null) {
      print('✅ Cache hit for: $exerciseName');
      return cachedVideoId;
    }

    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      print('❌ YouTube API key not configured');
      return null;
    }

    try {
      // Construct search query
      final query = '$exerciseName proper form exercise tutorial';
      final encodedQuery = Uri.encodeComponent(query);
      
      // Search parameters
      final url = Uri.parse(
        '$_baseUrl/search?'
        'part=snippet&'
        'q=$encodedQuery&'
        'type=video&'
        'videoDuration=short&'  // Short videos (< 4 minutes)
        'videoEmbeddable=true&'  // Must be embeddable
        'maxResults=5&'
        'order=relevance&'
        'key=$apiKey'
      );

      print('🔍 Searching YouTube for: $exerciseName');
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          // Get the first (most relevant) video
          final videoId = items[0]['id']['videoId'] as String;
          final title = items[0]['snippet']['title'] as String;
          
          print('✅ Found video: $title (ID: $videoId)');
          
          // Cache the result
          _videoCache[exerciseName.toLowerCase()] = videoId;
          
          return videoId;
        } else {
          print('⚠️ No videos found for: $exerciseName');
          return null;
        }
      } else if (response.statusCode == 403) {
        // Quota exceeded - fail silently
        print('⚠️ YouTube quota exceeded - skipping video for: $exerciseName');
        return null;
      } else {
        print('❌ YouTube API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error searching YouTube: $e');
      return null;
    }
  }

  /// Get video details including thumbnail URL
  Future<Map<String, dynamic>?> getVideoDetails(String videoId) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/videos?'
        'part=snippet,contentDetails&'
        'id=$videoId&'
        'key=$apiKey'
      );

      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List?;

        if (items != null && items.isNotEmpty) {
          final video = items[0];
          final snippet = video['snippet'];
          final thumbnails = snippet['thumbnails'];

          return {
            'videoId': videoId,
            'title': snippet['title'],
            'description': snippet['description'],
            'thumbnailUrl': thumbnails['medium']['url'] ?? 
                           thumbnails['default']['url'],
            'duration': video['contentDetails']['duration'],
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting video details: $e');
      return null;
    }
  }

  /// Batch search for multiple exercises
  /// Returns map of exercise name -> video ID
  Future<Map<String, String>> batchSearchExercises(
    List<String> exerciseNames,
  ) async {
    final results = <String, String>{};
    
    for (final name in exerciseNames) {
      final videoId = await searchExerciseVideo(name);
      if (videoId != null) {
        results[name] = videoId;
      }
      
      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return results;
  }

  /// Get thumbnail URL for a video ID
  String getThumbnailUrl(String videoId, {String quality = 'medium'}) {
    // YouTube thumbnail URL format
    // Qualities: default, medium (mqdefault), high (hqdefault), standard (sddefault), maxres
    final qualityMap = {
      'default': 'default',
      'medium': 'mqdefault',
      'high': 'hqdefault',
      'standard': 'sddefault',
      'maxres': 'maxresdefault',
    };
    
    final qualityStr = qualityMap[quality] ?? 'mqdefault';
    return 'https://img.youtube.com/vi/$videoId/$qualityStr.jpg';
  }

  /// Clear video cache
  void clearCache() {
    _videoCache.clear();
    print('🗑️ YouTube video cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedVideos': _videoCache.length,
      'exercises': _videoCache.keys.toList(),
    };
  }

  /// Pre-cache popular exercises
  Future<void> preCachePopularExercises() async {
    final popularExercises = [
      'Push-ups',
      'Squats',
      'Lunges',
      'Plank',
      'Burpees',
      'Jumping Jacks',
      'Mountain Climbers',
      'Bench Press',
      'Deadlift',
      'Pull-ups',
      'Bicep Curls',
      'Tricep Dips',
      'Shoulder Press',
      'Leg Press',
      'Crunches',
    ];

    print('🔄 Pre-caching popular exercises...');
    await batchSearchExercises(popularExercises);
    print('✅ Pre-cache complete: ${_videoCache.length} exercises cached');
  }
}
