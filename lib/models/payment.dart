import 'dart:convert'; // Tambahkan ini
import 'order_item.dart';
import 'menu_item.dart'; // Tambahkan ini untuk deserialisasi item

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
    required this.userId, // Wajib diisi
    required this.id,
    required this.buyerName,
    required this.total,
    required this.paid,
    required this.change,
    required this.paymentMethod,
    required this.items
  });

  // Konversi PaymentRecord ke Map untuk disimpan di SQLite
  Map<String, dynamic> toMap() {
    // Serialize items list to JSON string
    final itemsJson = json.encode(items.map((item) => {
      'id': item.item.id,
      'name': item.item.name,
      'price': item.item.price,
      'qty': item.qty,
    }).toList());

    return {
      'id': id,
      'userId': userId,
      'buyerName': buyerName,
      'total': total,
      'paid': paid,
      'change': change,
      'paymentMethod': paymentMethod,
      'itemsJson': itemsJson, // Simpan item sebagai JSON string
    };
  }

  // Konversi Map dari SQLite kembali ke PaymentRecord
  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    final List<dynamic> itemsData = json.decode(map['itemsJson'] as String);
    final List<OrderItem> loadedItems = itemsData.map((itemMap) {
      // Buat MenuItem tiruan hanya untuk menampung nama dan harga
      final incompleteMenuItem = MenuItem(
        id: itemMap['id'],
        name: itemMap['name'],
        price: itemMap['price'],
      );
      return OrderItem(item: incompleteMenuItem, qty: itemMap['qty'] as int);
    }).toList();

    return PaymentRecord(
      dbId: map['dbId'] as int?,
      userId: map['userId'] as int,
      id: map['id'] as String,
      buyerName: map['buyerName'] as String,
      total: map['total'] as double,
      paid: map['paid'] as double,
      change: map['change'] as double,
      paymentMethod: map['paymentMethod'] as String,
      items: loadedItems,
    );
  }
}