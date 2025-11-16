import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment.dart';
import '../models/order_item.dart';
import '../view_models/admin_order_view_model.dart';

const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

class AdminOrdersPage extends StatelessWidget { // Mengubah ke StatelessWidget
  const AdminOrdersPage({super.key});

  // Helper untuk menampilkan detail item
  Widget _buildItemDetails(List<OrderItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Text(
          '${item.qty}x ${item.item.name}',
          style: const TextStyle(fontSize: 14),
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Memuat ulang pesanan setiap kali widget dibangun (misalnya saat pindah tab)
    // Walaupun ada listener di home.dart, ini untuk memastikan data segar.
    final adminVM = Provider.of<AdminOrderViewModel>(context);

    if (adminVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final orders = adminVM.pendingOrders;

    if (orders.isEmpty) {
      return const Center(child: Text('Tidak ada pesanan baru yang menunggu diproses.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];

        final dbId = order.dbId;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text('Pesanan #${i + 1} (${order.id})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: COLOR_DARK_PRIMARY)),
                const Divider(),
                Text('Pembeli: ${order.buyerName}', style: const TextStyle(fontSize: 16)),
                Text('Metode Bayar: ${order.paymentMethod}', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                const SizedBox(height: 8),

                _buildItemDetails(order.items),

                const Divider(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL: Rp ${order.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),

                    // Tombol Terima/Selesaikan
                    if (dbId != null)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Selesaikan Pesanan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await adminVM.completeOrder(dbId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil diselesaikan!')));
                          }
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}