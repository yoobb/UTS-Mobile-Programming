// lib/views/screens/history_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../models/order_item.dart';
import '../../view_models/history_view_model.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});


  IconData _getPaymentIcon(String method) {
    if (method.toLowerCase().contains('cash')) {
      return Icons.money;
    } else if (method.toLowerCase().contains('card')) {
      return Icons.credit_card;
    } else if (method.toLowerCase().contains('transfer') || method.toLowerCase().contains('qris')) {
      return Icons.qr_code_2;
    }
    return Icons.receipt_long;
  }


  String _formatDateTime(String timestampId) {
    try {
      final milliseconds = int.parse(timestampId);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }


  Widget _buildItemDetails(List<OrderItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text('Detail Pesanan (${items.length} item):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
        const Divider(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: Text(
                  '${item.qty}x ${item.item.name}',
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),

              Text(
                'Rp ${item.total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryViewModel>(
      builder: (context, historyVM, child) {
        final history = historyVM.history;

        if (history.isEmpty) {
          return const Center(child: Text('Belum ada riwayat pembayaran'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: history.length,
          itemBuilder: (ctx, i) {
            final h = history[i];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          'Transaksi Sukses',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF778DA9)),
                        ),

                        Text(
                          _formatDateTime(h.id),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text('Pembeli: ${h.buyerName}', style: const TextStyle(fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(_getPaymentIcon(h.paymentMethod), size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${h.paymentMethod}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800),
                        ),
                      ],
                    ),

                    _buildItemDetails(h.items),

                    const Divider(height: 20),


                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL AKHIR:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          'Rp ${h.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D1B2A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}