// lib/view_models/cart_view_model.dart

import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';
import '../models/order_item.dart';
import '../models/payment.dart';

class CartViewModel extends ChangeNotifier {
  final List<OrderItem> _cart = [];

  List<OrderItem> get cart => _cart;

  double get cartTotal => _cart.fold(0.0, (p, c) => p + c.total);

  void addToCart(MenuItem item, int qty) {
    final found = _cart.indexWhere((o) => o.item.id == item.id);
    if (found >= 0) {
      _cart[found].qty += qty;
    } else {
      _cart.add(OrderItem(item: item, qty: qty));
    }
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _cart.removeWhere((o) => o.item.id == itemId);
    notifyListeners();
  }

  void updateCartQuantity(String itemId, int newQty) {
    final foundIndex = _cart.indexWhere((o) => o.item.id == itemId);
    if (foundIndex >= 0) {
      if (newQty > 0) {
        _cart[foundIndex].qty = newQty;
      } else {
        _cart.removeAt(foundIndex);
      }
      notifyListeners();
    }
  }

  Future<PaymentRecord> prepareCheckout(double paid, String paymentMethod, int userId, String buyerName) async {
    if (_cart.isEmpty) {
      throw Exception("Cart is empty.");
    }

    final total = cartTotal;
    final change = paid - total;

    final record = PaymentRecord(
      userId: userId,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      buyerName: buyerName,
      total: total,
      paid: paid,
      change: change,
      paymentMethod: paymentMethod,
      items: List.from(_cart),
    );

    _cart.clear();
    notifyListeners();
    return record;
  }
}