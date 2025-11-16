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
                    backgroundColor: COLOR_DARK_PRIMARY,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: menuVM.menuItems.length,
                itemBuilder: (ctx, i) {
                  final item = menuVM.menuItems[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('ID: ${item.id} | Kategori: ${item.category} | Rp ${item.price.toStringAsFixed(0)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, menuVM, item),
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

  void _showAddMenuDialog(BuildContext context, MenuViewModel menuVM) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    // DAFTAR KATEGORI YANG DIPERBOLEHKAN (MENGHILANGKAN 'Main Course')
    final validCategories = ['Dessert', 'Drink'];
    String category = validCategories.first; // Default diatur ke Dessert

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (c, setState) {
          return AlertDialog(
            title: const Text('Tambah Item Menu Lokal'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Catatan untuk Admin
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                  ),

                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Menu')),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Harga (Rp)'), keyboardType: TextInputType.number),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: validCategories // <-- MENGGUNAKAN DAFTAR YANG DIFILTER
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
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  final desc = descCtrl.text.trim();

                  if (name.isEmpty || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan Harga harus diisi dengan benar.')));
                    return;
                  }

                  final newItem = MenuItem(
                    id: '', // ID akan dibuat di ViewModel
                    name: name,
                    price: price,
                    description: desc,
                    image: '', // Mengabaikan gambar untuk kesederhanaan
                    category: category,
                  );

                  // Menyimpan menu lokal (Hanya Dessert atau Drink)
                  await menuVM.addMenuItem(newItem);
                  if(c.mounted) Navigator.pop(c);
                  if(context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu berhasil ditambahkan.')));
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

  void _confirmDelete(BuildContext context, MenuViewModel menuVM, MenuItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Anda yakin ingin menghapus menu "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await menuVM.removeMenuItem(item.id);
              if(ctx.mounted) Navigator.pop(ctx);
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu berhasil dihapus.')));
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