// lib/view_models/menu_view_model.dart

import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/menu_item.dart';
import '../models/meal.dart'; // Import Meal model
import '../services/meal_service.dart'; // Import MealService

// [BARU: MODEL UNTUK DATA DESSERT/DRINK DARI MOCKAPI]
class DessertDrinkApiItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final String category;

  DessertDrinkApiItem.fromJson(Map<String, dynamic> json)
      : id = (json['id'] as dynamic)?.toString() ?? '',
        name = json['name'] as String? ?? 'Nama Tidak Diketahui',
        price = (json['price'] as num? ?? 0.0).toDouble(),
        description = json['description'] as String? ?? '',
        image = json['image'] as String? ?? '',
        category = json['category'] as String? ?? 'Unknown';

  // Helper untuk konversi ke MenuItem
  MenuItem toMenuItem() {
    return MenuItem(
      id: id,
      name: name,
      price: price,
      description: description,
      image: image,
      category: category,
    );
  }
}
// [AKHIR MODEL BARU]

class MenuViewModel extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  final MealService _mealService = MealService();
  List<Meal> _apiMeals = [];
  // [BARU: LIST UNTUK DESSERT/DRINK API ITEMS]
  List<DessertDrinkApiItem> _apiDrinksDesserts = [];

  List<Meal> get apiMeals => _apiMeals;
  // [BARU: GETTER untuk Dessert/Drink API Items]
  List<DessertDrinkApiItem> get apiDrinksDesserts => _apiDrinksDesserts;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
      // [MODIFIKASI: Filter out local 'Dessert' dan 'Drink' items]
      final allItems = await dbHelper.getAllMenuItems();
      _menuItems = allItems.where((item) => item.category != 'Dessert' && item.category != 'Drink').toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading menu: $e");
      }
      _menuItems = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method: loadApiMeals - Memuat data resep dari API (MealDB)
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

  // [BARU: METHOD: loadApiDrinksDesserts]
  Future<void> loadApiDrinksDesserts() async {
    try {
      final rawData = await _mealService.fetchDrinksDessertsRaw();
      _apiDrinksDesserts = rawData.map((json) => DessertDrinkApiItem.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading API drinks/desserts: $e");
      }
      _apiDrinksDesserts = [];
    }

    notifyListeners();
  }
  // [AKHIR METHOD BARU]


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

  // [MODIFIKASI: seedInitialMenu untuk menghilangkan Dessert/Drink dari seed]
  Future<void> seedInitialMenu(List<MenuItem> initialMenu) async {
    final count = await dbHelper.getMenuItemCount();
    if (count == 0) {
      for (var item in initialMenu) {
        // Hanya masukkan item yang BUKAN Dessert atau Drink ke database lokal
        if (item.category != 'Dessert' && item.category != 'Drink') {
          await dbHelper.insertMenuItem(item);
        }
      }
      await loadMenu();
    }
  }
}