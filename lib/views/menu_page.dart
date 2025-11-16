// lib/views/screens/menu_view.dart

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

  // MODIFIKASI: Logika untuk membuat Main Course menjadi tab API
  List<String> get categories {
    final Set<String> uniqueCategories = {};

    // 1. Kumpulkan kategori dari menu lokal, TAPI HILANGKAN 'Main Course' lama.
    for (var item in widget.menu) {
      if (item.category != 'Main Course') {
        uniqueCategories.add(item.category);
      }
    }

    // 2. Tentukan urutan kategori lokal yang tersisa (Dessert, Drink, dll.)
    const prioritizedCategories = ['Dessert', 'Drink'];
    final sortedCategories = prioritizedCategories.where((c) => uniqueCategories.contains(c)).toList();
    for (var c in uniqueCategories) {
      if (!sortedCategories.contains(c)) {
        sortedCategories.add(c);
      }
    }

    // 3. Tambahkan "Main Course" BARU di awal (untuk konten API Recipes)
    sortedCategories.insert(0, 'Main Course');

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
    // Fungsi ini sekarang hanya akan dipanggil untuk 'Dessert', 'Drink', dll.
    return widget.menu.where((item) => item.category == category).toList();
  }


  Widget _buildApiMealGrid(List<Meal> meals) {
    if (meals.isEmpty) {
      return const Center(child: Text('Tidak ada resep dari API. Coba ganti query pencarian.'));
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

          return FutureBuilder<double>(
            future: menuVM.getPriceForApiMeal(m.idMeal),
            builder: (context, snapshot) {
              final currentPrice = snapshot.data ?? 35000.0;

              // REAKTIVASI: Buat MenuItem agar bisa di-order
              final MenuItem apiMenuItem = MenuItem(
                id: m.idMeal,
                name: m.strMeal,
                price: currentPrice,
                description: m.strInstructions.split('.').first,
                image: m.strMealThumb,
                category: m.strCategory,
              );

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: m.strMealThumb.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: m.strMealThumb,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFE0E1DD),
                            child: const Center(child: Icon(Icons.broken_image, color: COLOR_SECONDARY_ACCENT, size: 40)),
                          ),
                        )
                            : Container(
                          color: const Color(0xFFE0E1DD),
                          child: const Center(child: Text(
                              'No Image',
                              style: TextStyle(color: COLOR_SECONDARY_ACCENT, fontSize: 14)
                          )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.strMeal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),

                          Text('Category: ${m.strCategory} (${m.strArea})', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tampilkan harga yang sudah dimuat
                              Text('Rp ${apiMenuItem.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: COLOR_DARK_PRIMARY)),

                              // TOMBOL ORDER (Muncul jika onAdd TIDAK NULL)
                              if (widget.onAdd != null)
                                ElevatedButton(
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
                                            title: Text('Tambah ${apiMenuItem.name}'),
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
                                                  widget.onAdd!(apiMenuItem, qty);
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
                                ),
                              // Tampilkan status jika Admin
                              if (widget.onAdd == null)
                                const Text('Admin View', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }


  Widget _buildMenuGrid(List<MenuItem> filteredMenu) {
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
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: m.image.isNotEmpty
                          ? Image.asset(
                        m.image,
                        width: double.infinity,
                        fit: BoxFit.cover,

                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE0E1DD),
                          child: const Center(child: Icon(Icons.image_not_supported, color: COLOR_SECONDARY_ACCENT, size: 40)),
                        ),
                      )
                          : Container(
                        color: const Color(0xFFE0E1DD),
                        child: const Center(child: Text(
                            'No Image',
                            style: TextStyle(color: COLOR_SECONDARY_ACCENT, fontSize: 14)
                        )),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),

                        Text(m.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rp ${m.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: COLOR_DARK_PRIMARY)),

                            if (widget.onAdd != null)
                              ElevatedButton(
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
                                          title: Text('Tambah ${m.name}'),
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
                                                widget.onAdd!(m, qty);
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
                              ),

                            if (widget.onAdd == null)
                              const Text('Admin View', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
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

    if (widget.menu.isEmpty && menuVM.apiMeals.isEmpty) {
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
                // Tampilkan API Meals di tab 'Main Course'
                return _buildApiMealGrid(menuVM.apiMeals);
              }
              // Tampilkan menu lokal untuk kategori lain
              final filteredMenu = _getMenuByCategory(category);
              return _buildMenuGrid(filteredMenu);
            }).toList(),
          ),
        ),
      ],
    );
  }
}