import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/order_item.dart';

// Warna dari palet yang digunakan di sini:
const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

class MenuPage extends StatefulWidget {
  final List<MenuItem> menu;
  final void Function(MenuItem item, int qty) onAdd;

  const MenuPage({
    super.key,
    required this.menu,
    required this.onAdd,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> categories = ['Main Course', 'Dessert', 'Drink'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<MenuItem> _getMenuByCategory(String category) {
    return widget.menu.where((item) => item.category == category).toList();
  }

  Widget _buildMenuGrid(List<MenuItem> filteredMenu) {
    return LayoutBuilder(builder: (ctx, constr) {
      const int crossAxis = 2; // Ditetapkan ke 2 kolom
      return Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: filteredMenu.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxis,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, i) {
            final m = filteredMenu[i];
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column( // Menggunakan Column untuk menumpuk gambar dan teks
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Area Gambar (Mengambil hampir seluruh ruang vertikal yang tersedia)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: m.image.isNotEmpty
                          ? Image.asset(
                        m.image,
                        width: double.infinity,
                        fit: BoxFit.cover, // Gambar akan mengisi ruang
                        // Placeholder jika gambar tidak ditemukan
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE0E1DD), // Off-white placeholder
                          child: const Center(child: Icon(Icons.image_not_supported, color: COLOR_SECONDARY_ACCENT, size: 40)),
                        ),
                      )
                          : Container(
                        color: const Color(0xFFE0E1DD),
                        child: const Center(child: Icon(Icons.fastfood, color: COLOR_SECONDARY_ACCENT, size: 40)),
                      ),
                    ),
                  ),

                  // 2. Area Teks dan Aksi (Di bagian bawah kartu)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        // Deskripsi dipersingkat menjadi 1 baris
                        Text(m.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Rp ${m.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: COLOR_DARK_PRIMARY)),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: COLOR_SECONDARY_ACCENT,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () {
                                // Dialog logic
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
                                              widget.onAdd(m, qty);
                                              Navigator.pop(c);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ditambahkan $qty x ${m.name}')));
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
                            )
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
    return Column(
      children: [
        // TabBar untuk kategori
        Container(
          color: COLOR_DARK_PRIMARY,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: COLOR_SECONDARY_ACCENT,
            indicatorColor: Colors.white,
            tabs: categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
        // Konten yang difilter (TabBarView)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              final filteredMenu = _getMenuByCategory(category);
              if (filteredMenu.isEmpty) {
                return Center(child: Text('Belum ada menu untuk kategori $category.'));
              }
              return _buildMenuGrid(filteredMenu);
            }).toList(),
          ),
        ),
      ],
    );
  }
}