import 'package:flutter/foundation.dart';
import '../db/database_helper.dart';
import '../models/menu_item.dart';

class MenuViewModel extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;

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

  Future<void> addMenuItem(MenuItem item) async {
    // Memberikan ID unik otomatis
    item = MenuItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: item.name,
      price: item.price,
      description: item.description,
      image: item.image,
      category: item.category,
    );

    await dbHelper.insertMenuItem(item);
    await loadMenu(); // Muat ulang menu setelah penambahan
  }

  Future<void> removeMenuItem(String id) async {
    await dbHelper.deleteMenuItem(id);
    await loadMenu(); // Muat ulang menu setelah penghapusan
  }

  // Metode untuk mengisi data awal (hanya dipanggil sekali)
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