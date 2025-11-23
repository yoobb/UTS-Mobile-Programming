// lib/views/admin_menu_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../view_models/menu_view_model.dart';

const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

class AdminMenuPage extends StatelessWidget {
  const AdminMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuViewModel>(
      builder: (context, menuVM, child) {
        if (menuVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<MenuItem> localMenu = menuVM.menuItems;
        final List<MenuItem> webMenu = menuVM.drinksDesserts.map((d) => d.toMenuItem()).toList();

        final List<MenuItem> combinedMenu = [...localMenu, ...webMenu];

        combinedMenu.sort((a, b) {
          final aIsWeb = (a.category == 'Dessert' || a.category == 'Drink');
          final bIsWeb = (b.category == 'Dessert' || b.category == 'Drink');
          if (aIsWeb && !bIsWeb) return 1;
          if (!aIsWeb && bIsWeb) return -1;
          return a.name.compareTo(b.name);
        });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMenuDialog(context, menuVM),
                  icon: const Icon(Icons.add_box),
                  label: const Text('Tambah Menu Baru'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: COLOR_SECONDARY_ACCENT,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: combinedMenu.length,
                itemBuilder: (ctx, i) {
                  final item = combinedMenu[i];
                  final bool isWebItem = (item.category == 'Dessert' || item.category == 'Drink');

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      onTap: () => _showEditDialog(context, menuVM, item, isWebItem),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'ID: ${item.id} | Kategori: ${item.category} | Rp ${item.price.toStringAsFixed(0)} ' +
                            (isWebItem ? '(Web)' : '(Lokal)'),
                        style: TextStyle(color: isWebItem ? Colors.blue : Colors.black54),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: COLOR_DARK_PRIMARY),
                            onPressed: () => _showEditDialog(context, menuVM, item, isWebItem),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, menuVM, item, isWebItem),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // [MODIFIKASI: FUNGSI TAMBAH MENU BARU]
  void _showAddMenuDialog(BuildContext context, MenuViewModel menuVM) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController(); // BARU: Controller untuk URL Gambar

    // HANYA kategori Web yang ditampilkan untuk item baru
    final List<String> webCategories = ['Dessert', 'Drink'];

    // Defaultkan ke kategori Web (Dessert)
    String category = webCategories.first;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (c, setState) {

          // isWebItem selalu TRUE di sini karena hanya Dessert/Drink yang ada di dropdown
          const bool isWebItem = true;

          return AlertDialog(
            title: const Text('Tambah Item Menu (Web)'), // Tetapkan ke (Web)
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: Text('Item ini akan dikirim ke Web Service dan muncul di tab Dessert/Drink.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  ),

                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Menu')),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga (Rp)'), keyboardType: TextInputType.number),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),

                  // INPUT BARU: URL Gambar
                  TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL Gambar (Opsional)')),

                  const SizedBox(height: 12),

                  // DROPDOWN: HANYA DESSERT DAN DRINK
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: webCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() => category = newValue!);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: COLOR_SECONDARY_ACCENT),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  final desc = descCtrl.text.trim();
                  final imageUrl = imageCtrl.text.trim(); // Ambil URL Gambar

                  if (name.isEmpty || price <= 0) {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Harga harus diisi dengan benar.')));
                    }
                    return;
                  }

                  // Panggil fungsi POST Web Service dengan URL Gambar
                  final success = await menuVM.addApiDrinkDessert(name, price, desc, category, imageUrl);

                  if (c.mounted) Navigator.pop(c);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Menu berhasil ditambahkan.' : 'Gagal menambahkan menu.')));
                  }
                },
                child: const Text('Tambah'),
              ),
            ],
          );
        });
      },
    );
  }

  // [MODIFIKASI: FUNGSI EDIT MENU]
  void _showEditDialog(BuildContext context, MenuViewModel menuVM, MenuItem item, bool isWebItem) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
    final descCtrl = TextEditingController(text: item.description);
    final imageCtrl = TextEditingController(text: item.image); // BARU: Tampilkan URL Gambar saat Edit

    String category = item.category;

    final List<String> webCategories = ['Dessert', 'Drink'];
    final List<String> localCategories = ['Main Course', 'Snack', 'Other'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (c, setState) {

          // Kategori yang diizinkan untuk di-edit
          final categories = isWebItem ? webCategories : localCategories;

          return AlertDialog(
            title: Text('Edit Item Menu (${isWebItem ? 'Web' : 'Lokal'})'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isWebItem)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text('Perubahan akan dikirim ke Web Service.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                    ),

                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Menu')),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga (Rp)'), keyboardType: TextInputType.number),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),

                  // INPUT BARU: URL Gambar saat Edit
                  if (isWebItem) // Hanya tampilkan jika item adalah item Web
                    TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL Gambar')),

                  const SizedBox(height: 12),
                  // Dropdown kategori
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (newValue) => setState(() => category = newValue!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Batal')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: isWebItem ? COLOR_SECONDARY_ACCENT : COLOR_DARK_PRIMARY),
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  final desc = descCtrl.text.trim();
                  final imageUrl = isWebItem ? imageCtrl.text.trim() : item.image; // Ambil URL Gambar baru jika di mode Web

                  if (name.isEmpty || price <= 0) {
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Harga harus diisi dengan benar.')));
                    }
                    return;
                  }

                  // Buat objek MenuItem yang diperbarui
                  final updatedItem = item.copyWith(
                    name: name,
                    price: price,
                    description: desc,
                    category: category,
                    image: imageUrl, // Simpan URL gambar
                  );

                  bool success = false;
                  if (isWebItem) {
                    success = await menuVM.updateApiDrinkDessert(updatedItem);
                  } else {
                    await menuVM.updateMenuItemLocal(updatedItem);
                    success = true;
                  }

                  if (c.mounted) Navigator.pop(c);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Menu berhasil diperbarui.' : 'Gagal memperbarui menu.')));
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  // [Fungsi Hapus Menu (logika sama)]
  void _confirmDelete(BuildContext context, MenuViewModel menuVM, MenuItem item, bool isWebItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus menu "${item.name}" dari ${isWebItem ? 'Web' : 'Lokal'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              bool success = false;
              if (isWebItem) {
                success = await menuVM.removeApiDrinkDessert(item.id);
              } else {
                await menuVM.removeMenuItem(item.id);
                success = true;
              }

              if(ctx.mounted) Navigator.pop(ctx);
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success ? 'Menu berhasil dihapus.' : 'Gagal menghapus menu. ID mungkin tidak valid atau koneksi bermasalah.')
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}