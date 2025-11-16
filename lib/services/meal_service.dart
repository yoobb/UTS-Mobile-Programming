import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  final String _baseUrl = 'www.themealdb.com';
  final String _apiKey = '1';

  Future<List<Meal>> fetchMealsByName(String query) async {
    final uri = Uri.https(_baseUrl, '/api/json/v1/$_apiKey/search.php', {'s': query});

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['meals'] == null) {
          return [];
        }

        return (data['meals'] as List)
            .map((json) => Meal.fromJson(json as Map<String, dynamic>))
            .toList();

      } else {
        throw Exception('Failed to load meals, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching meals: $e');
      return [];
    }
  }
}