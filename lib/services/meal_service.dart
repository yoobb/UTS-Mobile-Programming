// lib/view_models/menu_view_model.dart

import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/menu_item.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

// [MODEL UNTUK DATA DESSERT/DRINK DARI WEB SERVICE]
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
        price = (json['price'] is String
            ? double.tryParse(json['price'] as String) ?? 0.0
            : (json['price'] as num? ?? 0.0).toDouble()),
        description = json['description'] as String? ?? '',
        image = json['image'] as String? ?? '',
        category = _mapCategoryToSingular(json['category'] as String? ?? 'Unknown');

  static String _mapCategoryToSingular(String s) {
    String lowerCase = s.toLowerCase();
    if (lowerCase.contains('drink')) {
      return 'Drink';
    } else if (lowerCase.contains('dessert')) {
      return 'Dessert';
    }
    return _capitalize(s);
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

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
// [AKHIR MODEL]

class MenuViewModel extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

  final MealService _mealService = MealService();
  List<Meal> _apiMeals = [];
  // Ganti nama variabel
  List<DessertDrinkApiItem> _drinksDesserts = [];

  List<Meal> get apiMeals => _apiMeals;
  // Ganti nama getter
  List<DessertDrinkApiItem> get drinksDesserts => _drinksDesserts;
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
        print("Error loading meals: $e");
      }
      _apiMeals = [];
    }

    notifyListeners();
  }

  Future<void> loadApiDrinksDesserts() async {
    try {
      final rawData = await _mealService.fetchDrinksDessertsRaw();
      _drinksDesserts = rawData.map((json) => DessertDrinkApiItem.fromJson(json as Map<String, dynamic>)).toList();

    } catch (e) {
      if (kDebugMode) {
        print("DIAGNOSTIK ERROR: Gagal memuat drinks/desserts: $e");
      }
      _drinksDesserts = [];
    }

    notifyListeners();
  }

  // [Method untuk menambahkan item Drink/Dessert]
  Future<bool> addApiDrinkDessert(String name, double price, String description, String category, String imageUrl) async {
    final newItemData = {
      'name': name,
      'price': price.toStringAsFixed(0),
      'description': description,
      // MENGGUNAKAN URL dari input, fallback jika kosong
      'image': imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150/d5f5f5/0d1b2a?text=${category}',
      'category': category,
    };

    final success = await _mealService.postDrinksDesserts(newItemData);

    if (success) {
      await loadApiDrinksDesserts();
      return true;
    }
    return false;
  }

  // [Method untuk menghapus item Drink/Dessert]
  Future<bool> removeApiDrinkDessert(String id) async {
    final success = await _mealService.deleteDrinkDessert(id);

    if (success) {
      await loadApiDrinksDesserts();
      return true;
    }
    return false;
  }

  // [Method untuk mengupdate item Lokal]
  Future<void> updateMenuItemLocal(MenuItem item) async {
    if (item.id.isNotEmpty) {
      await dbHelper.updateMenuItem(item);
      await loadMenu();
    }
  }

  // [Method untuk mengupdate item Drink/Dessert]
  Future<bool> updateApiDrinkDessert(MenuItem item) async {
    final updateData = {
      'name': item.name,
      'price': item.price.toStringAsFixed(0),
      'description': item.description,
      'image': item.image, // Mengirim URL gambar yang diperbarui
      'category': item.category,
    };

    if (item.id.isEmpty) return false;

    final success = await _mealService.putDrinkDessert(item.id, updateData);

    if (success) {
      await loadApiDrinksDesserts();
      return true;
    }
    return false;
  }

  // [Modifikasi Method Lama]
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

  // [Hapus kata API dari getter]
  Future<double> getPriceForApiMeal(String mealId) async {
    const defaultPrice = 35000.0;
    final savedPrice = await dbHelper.getApiPrice(mealId);
    return savedPrice ?? defaultPrice;
  }

  Future<void> saveApiMealPrice(String mealId, double price) async {
    await dbHelper.insertApiPrice(mealId, price);
    notifyListeners();
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