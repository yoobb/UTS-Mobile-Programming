import 'menu_item.dart';

class OrderItem {
  final MenuItem item;
  int qty;

  OrderItem({required this.item, this.qty = 1});

  double get total => item.price * qty;
}
