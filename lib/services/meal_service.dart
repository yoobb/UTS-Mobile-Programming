// lib/services/meal_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';
import 'package:flutter/foundation.dart';

class MealService {
  final String _baseUrl = 'www.themealdb.com';
  final String _apiKey = '1';
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

  // [Method untuk mengambil data Dessert/Drink dari Web Service]
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

  // [Method untuk POST data Dessert/Drink ke Web Service]
  Future<bool> postDrinksDesserts(Map<String, dynamic> data) async {
    final uri = Uri.https(_dessertDrinkBaseUrl, _dessertDrinkPath);

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Item berhasil ditambahkan ke Web Service: ${response.body}');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Gagal menambahkan item, status: ${response.statusCode}, body: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error posting drinks/desserts: $e');
      }
      return false;
    }
  }

  // [Method untuk PUT/Update data Dessert/Drink ke Web Service]
  Future<bool> putDrinkDessert(String id, Map<String, dynamic> data) async {
    final uri = Uri.https(_dessertDrinkBaseUrl, '$_dessertDrinkPath/$id');

    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Item ID $id berhasil diperbarui di Web Service.');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Gagal memperbarui item ID $id, status: ${response.statusCode}, body: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating drinks/desserts: $e');
      }
      return false;
    }
  }

  // [Method untuk DELETE data Dessert/Drink dari Web Service]
  Future<bool> deleteDrinkDessert(String id) async {
    final uri = Uri.https(_dessertDrinkBaseUrl, '$_dessertDrinkPath/$id');

    try {
      final response = await http.delete(uri);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print('Item dengan ID $id berhasil dihapus dari Web Service.');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('Gagal menghapus item ID $id, status: ${response.statusCode}, body: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting drinks/desserts: $e');
      }
      return false;
    }
  }
}