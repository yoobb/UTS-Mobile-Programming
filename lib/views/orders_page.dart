// lib/views/screens/orders_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/cart_view_model.dart';

class OrderPage extends StatelessWidget {
  final VoidCallback onProceed;

  const OrderPage({
    super.key,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartViewModel>(
      builder: (context, cartVM, child) {
        final cart = cartVM.cart;

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

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () => cartVM.updateCartQuantity(o.item.id, o.qty - 1),
                            ),

                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () => cartVM.updateCartQuantity(o.item.id, o.qty + 1),
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => cartVM.removeFromCart(o.item.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(

                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF778DA9), minimumSize: const Size.fromHeight(48)),
                onPressed: onProceed,
                child: const Text('Lanjut ke Pembayaran'),
              )
            ],
          ),
        );
      },
    );
  }
}