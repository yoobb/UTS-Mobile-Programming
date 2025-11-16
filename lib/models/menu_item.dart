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
    this.category = 'Main Course',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'category': category,
    };
  }
  
  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String? ?? '',
      image: map['image'] as String? ?? '',
      category: map['category'] as String? ?? 'Main Course',
    );
  }
}