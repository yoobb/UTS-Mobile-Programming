// lib/views/menu_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/menu_item.dart';
import '../../view_models/menu_view_model.dart';
import '../../models/meal.dart';

const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

class MenuPage extends StatefulWidget {
  final List<MenuItem> menu;
  final void Function(MenuItem item, int qty)? onAdd;

  const MenuPage({
    super.key,
    required this.menu,
    this.onAdd,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  late TabController _tabController;

  // MODIFIKASI: Logika untuk membuat Main Course, Dessert, dan Drink menjadi tab API
  List<String> get categories {
    final Set<String> uniqueCategories = {};

    // 1. Kumpulkan kategori dari menu lokal yang tersisa (BUKAN MAIN COURSE, DESSERT, DRINK)
    for (var item in widget.menu) {
      if (item.category != 'Main Course' && item.category != 'Dessert' && item.category != 'Drink') {
        uniqueCategories.add(item.category);
      }
    }

    // 2. Tentukan urutan kategori API (Main Course, Dessert, Drink)
    const prioritizedApiCategories = ['Main Course', 'Dessert', 'Drink'];
    final sortedCategories = [...prioritizedApiCategories];

    // 3. Tambahkan kategori lokal yang tersisa
    for (var c in uniqueCategories) {
      if (!sortedCategories.contains(c)) {
        sortedCategories.add(c);
      }
    }

    return sortedCategories;
  }

  void _initializeTabController() {
    _tabController = TabController(length: categories.isEmpty ? 1 : categories.length, vsync: this);
  }

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  @override
  void didUpdateWidget(covariant MenuPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (categories.length != _tabController.length) {
      _tabController.dispose();
      _initializeTabController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MenuItem> _getMenuByCategory(String category) {
    // Fungsi ini sekarang hanya akan dipanggil untuk kategori lokal tersisa
    return widget.menu.where((item) => item.category == category).toList();
  }

  // [BARU: Widget Placeholder untuk Gambar Hilang]
  Widget _noImagePlaceholder() {
    return Container(
      color: const Color(0xFFE0E1DD),
      child: const Center(child: Icon(Icons.broken_image, color: COLOR_SECONDARY_ACCENT, size: 40)),
    );
  }

  // [BARU: Widget Tombol Order yang Dapat Digunakan Kembali]
  Widget _buildOrderButton(MenuItem item) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: COLOR_SECONDARY_ACCENT,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: Size.zero,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            int qty = 1;
            return StatefulBuilder(builder: (c, setState) {
              return AlertDialog(
                title: Text('Tambah ${item.name}'),
                content: Row(children: [
                  IconButton(onPressed: () => setState(() { if (qty>1) qty--; }), icon: const Icon(Icons.remove)),
                  Text('$qty'),
                  IconButton(onPressed: () => setState(() => qty++), icon: const Icon(Icons.add)),
                ]),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: COLOR_SECONDARY_ACCENT),
                    onPressed: () {
                      widget.onAdd!(item, qty);
                      Navigator.pop(c);
                    },
                    child: const Text('Tambah'),
                  ),
                ],
              );
            });
          },
        );
      },
      child: const Text('Order', style: TextStyle(fontSize: 12)),
    );
  }

  // [BARU: Reusable Card Widget untuk semua Item (Lokal/API)]
  Widget _buildMenuItemCard(MenuItem item, {bool isApiItem = false, String secondaryText = ''}) {
    final bool isNetworkImage = isApiItem || item.image.startsWith('http');
    final String imagePath = item.image;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imagePath.isNotEmpty
                  ? (isNetworkImage
                  ? CachedNetworkImage(
                imageUrl: imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => _noImagePlaceholder(),
              )
                  : Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _noImagePlaceholder(),
              ))
                  : _noImagePlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),

                Text(secondaryText.isEmpty ? item.description : secondaryText, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rp ${item.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: COLOR_DARK_PRIMARY)),

                    if (widget.onAdd != null)
                      _buildOrderButton(item)
                    else
                      const Text('Admin View', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // [MODIFIKASI: Builder untuk MealDB (Main Course)]
  Widget _buildMealGrid(List<Meal> meals) {
    if (meals.isEmpty) {
      return const Center(child: Text('Tidak ada resep utama dari API. Coba ganti query pencarian.'));
    }

    final menuVM = Provider.of<MenuViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: meals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, i) {
          final m = meals[i];
          final mealId = m.idMeal;

          return FutureBuilder<double>(
            future: menuVM.getPriceForApiMeal(mealId),
            builder: (context, snapshot) {
              final currentPrice = snapshot.data ?? 35000.0;

              final MenuItem apiMenuItem = MenuItem(
                id: mealId,
                name: m.strMeal,
                price: currentPrice,
                description: m.strInstructions.split('.').first,
                image: m.strMealThumb,
                category: 'Main Course',
              );

              return _buildMenuItemCard(apiMenuItem, isApiItem: true, secondaryText: 'Category: ${m.strCategory} (${m.strArea})');
            },
          );
        },
      ),
    );
  }

  // [BARU: Builder untuk Drinks/Desserts API]
  Widget _buildDrinksDessertsGrid(List<DessertDrinkApiItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Tidak ada menu dari API Drinks/Desserts.'));
    }

    final menuVM = Provider.of<MenuViewModel>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (context, i) {
          final m = items[i];
          final itemId = m.id;

          return FutureBuilder<double>(
            future: menuVM.getPriceForApiMeal(itemId),
            builder: (context, snapshot) {
              // Gunakan harga dari DB jika ada, jika tidak, gunakan harga dari API
              final currentPrice = snapshot.data ?? m.price;

              final finalMenuItem = MenuItem(
                id: itemId,
                name: m.name,
                price: currentPrice,
                description: m.description,
                image: m.image, // URL Gambar dari MockAPI
                category: m.category,
              );

              return _buildMenuItemCard(finalMenuItem, isApiItem: true, secondaryText: m.description);
            },
          );
        },
      ),
    );
  }


  // [MODIFIKASI: Builder untuk Menu Lokal yang Tersisa]
  Widget _buildMenuGridLocal(List<MenuItem> filteredMenu) {
    if (filteredMenu.isEmpty) {
      return const Center(child: Text('Menu kosong untuk kategori ini.'));
    }

    return LayoutBuilder(builder: (ctx, constr) {
      const int crossAxis = 2;
      return Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: filteredMenu.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, i) {
            final m = filteredMenu[i];
            // Menggunakan builder yang sama, dengan isApiItem: false (default)
            return _buildMenuItemCard(m, secondaryText: m.description);
          },
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final menuVM = Provider.of<MenuViewModel>(context);

    if (menuVM.isLoading) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(COLOR_SECONDARY_ACCENT)));
    }

    if (widget.menu.isEmpty && menuVM.apiMeals.isEmpty && menuVM.apiDrinksDesserts.isEmpty) {
      return const Center(child: Text('Menu Kosong. Silakan hubungi Admin untuk menambah menu atau periksa koneksi internet Anda.'));
    }

    final currentCategories = categories;

    if (_tabController.length != currentCategories.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _tabController.dispose();
          _initializeTabController();
          setState(() {});
        }
      });
      return const Center(child: CircularProgressIndicator());
    }


    return Column(
      children: [

        Container(
          color: COLOR_DARK_PRIMARY,
          child: TabBar(
            controller: _tabController,
            isScrollable: currentCategories.length > 3,
            labelColor: Colors.white,
            unselectedLabelColor: COLOR_SECONDARY_ACCENT,
            indicatorColor: Colors.white,
            tabs: currentCategories.map((c) => Tab(text: c)).toList(),
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: currentCategories.map((category) {
              if (category == 'Main Course') {
                // Tampilkan API Meals (MealDB) di tab 'Main Course'
                return _buildMealGrid(menuVM.apiMeals);
              } else if (category == 'Dessert' || category == 'Drink') {
                // [Tampilkan API Drinks/Desserts di tab 'Dessert' dan 'Drink']
                final filteredItems = menuVM.apiDrinksDesserts.where((item) => item.category == category).toList();
                return _buildDrinksDessertsGrid(filteredItems);
              }
              // Tampilkan menu lokal untuk kategori lain
              final filteredMenu = _getMenuByCategory(category);
              return _buildMenuGridLocal(filteredMenu);
            }).toList(),
          ),
        ),
      ],
    );
  }
}