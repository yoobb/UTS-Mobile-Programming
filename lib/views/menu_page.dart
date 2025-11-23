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

  List<String> get categories {
    final Set<String> uniqueCategories = {};

    for (var item in widget.menu) {
      if (item.category != 'Main Course' && item.category != 'Dessert' && item.category != 'Drink') {
        uniqueCategories.add(item.category);
      }
    }

    const prioritizedWebCategories = ['Main Course', 'Dessert', 'Drink'];
    final sortedCategories = [...prioritizedWebCategories];

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
    return widget.menu.where((item) => item.category == category).toList();
  }

  // [Widget Placeholder untuk Gambar Hilang]
  Widget _noImagePlaceholder() {
    return Container(
      color: const Color(0xFFE0E1DD),
      child: const Center(child: Icon(Icons.broken_image, color: COLOR_SECONDARY_ACCENT, size: 40)),
    );
  }

  // [Widget Tombol Order yang Dapat Digunakan Kembali]
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

  // [Reusable Card Widget untuk semua Item (Lokal/Web)]
  Widget _buildMenuItemCard(MenuItem item, {bool isWebItem = false, String secondaryText = ''}) {
    // Gunakan isWebItem untuk menentukan apakah menggunakan CachedNetworkImage (URL)
    final bool isNetworkImage = item.image.isNotEmpty && isWebItem;
    final String imagePath = item.image;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imagePath.isNotEmpty && isNetworkImage
                  ? CachedNetworkImage(
                imageUrl: imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => _noImagePlaceholder(),
              )
                  : (imagePath.isNotEmpty && !isNetworkImage
                  ? Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _noImagePlaceholder(),
              )
                  : _noImagePlaceholder()),
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


  // [Builder untuk Main Course]
  Widget _buildMealGrid(List<Meal> meals) {
    if (meals.isEmpty) {
      return const Center(child: Text('Tidak ada resep utama dari Web Service. Coba ganti query pencarian.'));
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

          // Menggunakan FutureBuilder untuk mendapatkan harga yang di-override Admin
          return FutureBuilder<double>(
            future: menuVM.getPriceForApiMeal(mealId),
            builder: (context, snapshot) {
              final currentPrice = snapshot.data ?? 35000.0;

              final MenuItem webMenuItem = MenuItem(
                id: mealId,
                name: m.strMeal,
                price: currentPrice,
                description: m.strInstructions.split('.').first,
                image: m.strMealThumb,
                category: 'Main Course',
              );

              return _buildMenuItemCard(webMenuItem, isWebItem: true, secondaryText: 'Category: ${m.strCategory} (${m.strArea})');
            },
          );
        },
      ),
    );
  }

  // [KOREKSI: Builder untuk Drinks/Desserts Web Service]
  Widget _buildDrinksDessertsGrid(List<DessertDrinkApiItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Tidak ada menu dari Web Service Drinks/Desserts.'));
    }

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

          // Langsung gunakan harga dari objek yang sudah difetch dari Web Service (m.price),
          // karena harga ini adalah harga yang sudah di-update Admin melalui PUT.
          final currentPrice = m.price;

          final finalMenuItem = MenuItem(
            id: m.id,
            name: m.name,
            price: currentPrice, // <-- AMBIL HARGA LANGSUNG DARI M.PRICE
            description: m.description,
            image: m.image,
            category: m.category,
          );

          // isWebItem: true
          return _buildMenuItemCard(finalMenuItem, isWebItem: true, secondaryText: m.description);
        },
      ),
    );
  }


  // [Builder untuk Menu Lokal yang Tersisa]
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

    if (widget.menu.isEmpty && menuVM.apiMeals.isEmpty && menuVM.drinksDesserts.isEmpty) {
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
                return _buildMealGrid(menuVM.apiMeals);
              } else if (category == 'Dessert' || category == 'Drink') {
                return Consumer<MenuViewModel>(
                  builder: (context, vm, child) {
                    final items = vm.drinksDesserts;
                    final filteredItems = items.where((item) => item.category == category).toList();

                    return _buildDrinksDessertsGrid(filteredItems);
                  },
                );
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