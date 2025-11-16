import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/menu_item.dart';
import '../models/meal.dart'; // Import Meal model
import '../services/meal_service.dart'; // Import MealService

class MenuViewModel extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  final MealService _mealService = MealService();
  List<Meal> _apiMeals = [];

  List<Meal> get apiMeals => _apiMeals;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      _menuItems = await dbHelper.getAllMenuItems();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading menu: $e");
      }
      _menuItems = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method: loadApiMeals - Memuat data resep dari API
  Future<void> loadApiMeals(String query) async {
    try {
      _apiMeals = await _mealService.fetchMealsByName(query);
    } catch (e) {
      if (kDebugMode) {
        print("Error loading API meals: $e");
      }
      _apiMeals = [];
    }

    notifyListeners();
  }

  // Method: getPriceForApiMeal - MEMPERBAIKI ERROR INI
  // Fungsi untuk mendapatkan harga yang tersimpan dari database
  Future<double> getPriceForApiMeal(String mealId) async {
    const defaultPrice = 35000.0;
    final savedPrice = await dbHelper.getApiPrice(mealId);
    return savedPrice ?? defaultPrice;
  }

  // Method: saveApiMealPrice - Menyimpan harga API yang disesuaikan oleh Admin
  Future<void> saveApiMealPrice(String mealId, double price) async {
    await dbHelper.insertApiPrice(mealId, price);
    notifyListeners();
  }

  Future<void> addMenuItem(MenuItem item) async {
    item = MenuItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: item.name,
      price: item.price,
      description: item.description,
      image: item.image,
      category: item.category,
    );

    await dbHelper.insertMenuItem(item);
    await loadMenu();
  }

  Future<void> removeMenuItem(String id) async {
    await dbHelper.deleteMenuItem(id);
    await loadMenu();
  }

  Future<void> seedInitialMenu(List<MenuItem> initialMenu) async {
    final count = await dbHelper.getMenuItemCount();
    if (count == 0) {
      for (var item in initialMenu) {
        await dbHelper.insertMenuItem(item);
      }
      await loadMenu();
    }
  }
}