class MenuItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image; // asset path or empty
  final String category; // <--- Ditambahkan

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.image = '',
    this.category = 'Makanan', // <--- Nilai default
  });
}