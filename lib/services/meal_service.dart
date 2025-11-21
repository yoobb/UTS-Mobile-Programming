// lib/services/meal_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import 'package:flutter/foundation.dart'; // [FIX: Menambahkan import ini untuk kDebugMode]

class MealService {
  final String _baseUrl = 'www.themealdb.com';
  final String _apiKey = '1';
  // [BARU: URL untuk Dessert/Drink]
  final String _dessertDrinkBaseUrl = '692045a731e684d7bfcc5ca3.mockapi.io';
  final String _dessertDrinkPath = '/api/eatmood/DrinksDesserts';


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

  // [BARU: Method untuk mengambil data Dessert/Drink dari MockAPI]
  Future<List<dynamic>> fetchDrinksDessertsRaw() async {
    final uri = Uri.https(_dessertDrinkBaseUrl, _dessertDrinkPath);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load desserts/drinks, status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching desserts/drinks: $e');
      }
      return [];
    }
  }
}