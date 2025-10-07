import 'package:flutter/material.dart';
import '../models/order_item.dart';

class OrdersPage extends StatelessWidget {
  final List<OrderItem> cart;
  final void Function(String itemId) onRemove;
  final VoidCallback onProceed;
  final void Function(String itemId, int newQty) onUpdateQty;

  const OrdersPage({
    super.key,
    required this.cart,
    required this.onRemove,
    required this.onProceed,
    required this.onUpdateQty,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.isEmpty) {
      return const Center(child: Text('Cart kosong. Tambahkan pesanan dari menu.'));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: cart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final o = cart[i];
                return Card(
                  child: ListTile(
                    // Leading: Menampilkan kuantitas saat ini
                    leading: SizedBox(
                      width: 30,
                      child: Center(
                        child: Text(
                            o.qty.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                    ),
                    title: Text(o.item.name),
                    subtitle: Text('Rp ${o.item.price.toStringAsFixed(0)}  •  Total: Rp ${o.total.toStringAsFixed(0)}'),
                    // Trailing: Kontrol penambahan/pengurangan
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Kurang (-)
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: () => onUpdateQty(o.item.id, o.qty - 1),
                        ),
                        // Tombol Tambah (+)
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: () => onUpdateQty(o.item.id, o.qty + 1),
                        ),
                        // Tombol Hapus (untuk penghapusan total)
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => onRemove(o.item.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            // Secondary Accent #778DA9
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF778DA9), minimumSize: const Size.fromHeight(48)),
            onPressed: onProceed,
            child: const Text('Lanjut ke Pembayaran'),
          )
        ],
      ),
    );
  }
}