import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/food_model.dart';

class UsdaService {
  static const String baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  late final String apiKey;

  UsdaService() {
    apiKey = dotenv.env['USDA_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('Warning: USDA_API_KEY not found in .env file');
    }
  }

  /// Search for foods by query string
  Future<List<FoodItem>> searchFoods(String query, {int pageSize = 25}) async {
    if (apiKey.isEmpty) {
      throw Exception('USDA API key not configured');
    }

    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final url = Uri.parse('$baseUrl/foods/search').replace(queryParameters: {
        'api_key': apiKey,
        'query': query,
        'pageSize': pageSize.toString(),
        'dataType': 'Survey (FNDDS),Foundation,SR Legacy', // Common foods
      });

      print('USDA API Request: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List<dynamic>? ?? [];

        print('USDA API returned ${foods.length} foods');

        return foods.map((food) => FoodItem.fromJson(food)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Invalid API key. Please check your USDA_API_KEY in .env file');
      } else {
        throw Exception('Failed to search foods: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching foods: $e');
      rethrow;
    }
  }

  /// Get detailed information about a specific food
  Future<FoodItem?> getFoodDetails(int fdcId) async {
    if (apiKey.isEmpty) {
      throw Exception('USDA API key not configured');
    }

    try {
      final url = Uri.parse('$baseUrl/food/$fdcId').replace(queryParameters: {
        'api_key': apiKey,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FoodItem.fromJson(data);
      } else {
        throw Exception('Failed to get food details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting food details: $e');
      return null;
    }
  }

  /// Get popular/common foods (default search)
  Future<List<FoodItem>> getCommonFoods() async {
    // Return common foods like chicken, rice, eggs, etc.
    final commonSearches = [
      'chicken breast',
      'brown rice',
      'eggs',
      'salmon',
      'broccoli',
      'sweet potato',
      'oatmeal',
      'greek yogurt',
    ];

    try {
      // Search for a random common food
      final randomFood = (commonSearches..shuffle()).first;
      return await searchFoods(randomFood, pageSize: 10);
    } catch (e) {
      print('Error getting common foods: $e');
      return [];
    }
  }
}
