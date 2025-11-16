import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../db/database_helper.dart';

class AdminOrderViewModel extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<PaymentRecord> _pendingOrders = [];
  bool _isLoading = false;

  List<PaymentRecord> get pendingOrders => _pendingOrders;
  bool get isLoading => _isLoading;

  Future<void> loadPendingOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pendingOrders = await dbHelper.getPendingOrders();
    } catch (e) {
      if (kDebugMode) {
        print("Error loading pending orders: $e");
      }
      _pendingOrders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOrder(int dbId) async {
    await dbHelper.updateOrderStatus(dbId, 'completed');
    await loadPendingOrders(); // Muat ulang daftar setelah update
  }
}