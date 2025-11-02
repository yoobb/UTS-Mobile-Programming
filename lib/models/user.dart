// lib/models/user.dart

class User {
  final int? id;
  final String username;
  final String name; // Nama Pembeli

  User({
    this.id,
    required this.username,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'name': name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      name: map['name'] as String,
    );
  }
}