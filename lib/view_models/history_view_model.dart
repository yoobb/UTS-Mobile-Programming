// lib/view_models/history_view_model.dart

import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../db/database_helper.dart';

class HistoryViewModel extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  List<PaymentRecord> _history = [];

  List<PaymentRecord> get history => _history;

  Future<void> loadHistory(int userId) async {
    _history = await dbHelper.getHistoryByUserId(userId);
    notifyListeners();
  }

  Future<void> saveRecord(PaymentRecord record) async {
    await dbHelper.insertPaymentRecord(record);
    if (record.userId != null) {
      await loadHistory(record.userId);
    }
  }
}