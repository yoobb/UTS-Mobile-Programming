class MenuItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.image = '',
    this.category = 'Makanan',
  });
}