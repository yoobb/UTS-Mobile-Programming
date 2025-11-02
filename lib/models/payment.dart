// lib/models/payment.dart

import 'dart:convert';
import 'order_item.dart';
import 'menu_item.dart';

class PaymentRecord {
  final int? dbId; // ID unik di database
  final int userId; // ID pengguna yang melakukan pembayaran

  final String id;
  final String buyerName;
  final double total;
  final double paid;
  final double change;
  final String paymentMethod;
  final List<OrderItem> items;

  PaymentRecord({
    this.dbId,
    required this.userId,
    required this.id,
    required this.buyerName,
    required this.total,
    required this.paid,
    required this.change,
    required this.paymentMethod,
    required this.items
  });

  Map<String, dynamic> toMap() {
    final itemsJson = json.encode(items.map((item) => {
      'id': item.item.id,
      'name': item.item.name,
      'price': item.item.price,
      'qty': item.qty,
    }).toList());

    return {
      'userId': userId,
      'id': id,
      'buyerName': buyerName,
      'total': total,
      'paid': paid,
      'change': change,
      'paymentMethod': paymentMethod,
      'itemsJson': itemsJson,
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    final List<dynamic> itemsData = json.decode(map['itemsJson'] as String);
    final List<OrderItem> loadedItems = itemsData.map((itemMap) {
      final incompleteMenuItem = MenuItem(
        id: itemMap['id'],
        name: itemMap['name'],
        price: (itemMap['price'] as num).toDouble(),
        description: '',
        image: '',
      );
      return OrderItem(item: incompleteMenuItem, qty: itemMap['qty'] as int);
    }).toList();

    return PaymentRecord(
      dbId: map['dbId'] as int?,
      userId: map['userId'] as int,
      id: map['id'] as String,
      buyerName: map['buyerName'] as String,
      total: (map['total'] as num).toDouble(),
      paid: (map['paid'] as num).toDouble(),
      change: (map['change'] as num).toDouble(),
      paymentMethod: map['paymentMethod'] as String,
      items: loadedItems,
    );
  }
}