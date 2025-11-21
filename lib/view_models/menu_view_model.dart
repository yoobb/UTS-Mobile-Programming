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
  // [PERBAIKAN HARGA]: Menangani harga yang mungkin berupa String ("28000")
        price = (json['price'] is String
            ? double.tryParse(json['price'] as String) ?? 0.0
            : (json['price'] as num? ?? 0.0).toDouble()),
        description = json['description'] as String? ?? '',
        image = json['image'] as String? ?? '',
  // [FIX FILTER]: Mapping kategori API ke nama tab yang SAMA PERSIS
        category = _mapCategoryToSingular(json['category'] as String? ?? 'Unknown');

  // [FIX FINAL HELPER]: Memastikan nama kategori match dengan nama tab ('Drink', 'Dessert')
  static String _mapCategoryToSingular(String s) {
    String lowerCase = s.toLowerCase();
    if (lowerCase.contains('drink')) {
      return 'Drink';
    } else if (lowerCase.contains('dessert')) {
      return 'Dessert';
    }
    // Jika bukan drink/dessert, kembalikan dengan huruf kapital normal
    return _capitalize(s);
  }

  // Helper lama yang masih dipertahankan
  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

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
  bool _isLoading = false; // FIX: Deklarasi _isLoading

  final MealService _mealService = MealService();
  List<Meal> _apiMeals = [];
  List<DessertDrinkApiItem> _apiDrinksDesserts = [];

  List<Meal> get apiMeals => _apiMeals;
  List<DessertDrinkApiItem> get apiDrinksDesserts => _apiDrinksDesserts;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;

  Future<void> loadMenu() async {
    _isLoading = true;
    notifyListeners();

    try {
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

  Future<void> loadApiDrinksDesserts() async {
    try {
      final rawData = await _mealService.fetchDrinksDessertsRaw();
      _apiDrinksDesserts = rawData.map((json) => DessertDrinkApiItem.fromJson(json as Map<String, dynamic>)).toList();

      // [DIAGNOSTIK BARU] Cek jumlah item yang berhasil dimuat
      if (kDebugMode) {
        print("DIAGNOSTIK: Item Drinks/Desserts API berhasil dimuat: ${_apiDrinksDesserts.length} item");
      }

    } catch (e) {
      if (kDebugMode) {
        print("DIAGNOSTIK ERROR: Gagal memuat API drinks/desserts: $e");
      }
      _apiDrinksDesserts = [];
    }

    notifyListeners();
  }


  // Metode-metode lain tetap sama...

  Future<double> getPriceForApiMeal(String mealId) async {
    const defaultPrice = 35000.0;
    final savedPrice = await dbHelper.getApiPrice(mealId);
    return savedPrice ?? defaultPrice;
  }

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
        if (item.category != 'Dessert' && item.category != 'Drink') {
          await dbHelper.insertMenuItem(item);
        }
      }
      await loadMenu();
    }
  }
}