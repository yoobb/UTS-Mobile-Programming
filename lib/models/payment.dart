import 'order_item.dart';

class PaymentRecord {
  final String id;
  final String buyerName;
  final double total;
  final double paid;
  final double change;
  final String paymentMethod;
  final List<OrderItem> items;

  PaymentRecord({required this.id, required this.buyerName, required this.total, required this.paid, required this.change, required this.paymentMethod, required this.items}); // <--- DIPERBARUI
}