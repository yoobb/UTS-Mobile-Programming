// lib/models/menu_item.dart
class MenuItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image; // Field image sudah ada
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.image = '', // Default tetap string kosong
    this.category = 'Main Course',
  });

  // [MODIFIKASI: Method copyWith diperbarui untuk menyertakan image]
  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    String? image,
    String? category,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      image: image ?? this.image, // Menyertakan field image
      category: category ?? this.category,
    );
  }

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