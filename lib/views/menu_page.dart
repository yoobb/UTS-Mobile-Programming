import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../models/menu_item.dart';
import '../../view_models/menu_view_model.dart'; // Import MenuViewModel

const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

class MenuPage extends StatefulWidget {
  final List<MenuItem> menu; // Menerima data menu dari luar
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
  // Ambil kategori secara dinamis dari menu yang ada
  List<String> get categories {
    final Set<String> uniqueCategories = {};
    for (var item in widget.menu) {
      uniqueCategories.add(item.category);
    }
    // Pastikan urutan kategori selalu sama, atau set default
    const defaultCategories = ['Main Course', 'Dessert', 'Drink'];
    final sortedCategories = defaultCategories.where((c) => uniqueCategories.contains(c)).toList();
    for (var c in uniqueCategories) {
      if (!sortedCategories.contains(c)) {
        sortedCategories.add(c);
      }
    }
    return sortedCategories;
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller di sini dengan jumlah kategori yang dinamis
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant MenuPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Perlu menginisialisasi ulang TabController jika daftar menu berubah
    // (misalnya setelah Admin menambahkan/menghapus item)
    if (widget.menu != oldWidget.menu || categories.length != _tabController.length) {
      _tabController.dispose();
      _tabController = TabController(length: categories.length, vsync: this);
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

  Widget _buildMenuGrid(List<MenuItem> filteredMenu) {
    // Tampilkan loading jika menu kosong tapi sedang loading
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
    // Ambil status loading dari MenuViewModel
    final menuVM = Provider.of<MenuViewModel>(context);

    if (menuVM.isLoading) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(COLOR_SECONDARY_ACCENT)));
    }

    if (widget.menu.isEmpty) {
      return const Center(child: Text('Menu Kosong. Silakan hubungi Admin untuk menambah menu.'));
    }

    // Panggil ulang setstate untuk memastikan TabBarController di-re-initialize
    // jika daftar kategori berubah setelah loadMenu() selesai.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (categories.length != _tabController.length && mounted) {
        setState(() {
          _tabController = TabController(length: categories.length, vsync: this);
        });
      }
    });

    return Column(
      children: [

        Container(
          color: COLOR_DARK_PRIMARY,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: COLOR_SECONDARY_ACCENT,
            indicatorColor: Colors.white,
            tabs: categories.map((c) => Tab(text: c)).toList(),
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: categories.map((category) {
              final filteredMenu = _getMenuByCategory(category);
              return _buildMenuGrid(filteredMenu);
            }).toList(),
          ),
        ),
      ],
    );
  }
}