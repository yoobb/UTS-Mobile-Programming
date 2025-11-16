class User {
  final int? id;
  final String username;
  final String name; // Nama Pembeli
  final String role; // Tambahkan role untuk otorisasi

  User({
    this.id,
    required this.username,
    required this.name,
    this.role = 'customer', // Default role adalah customer
  });

  bool get isAdmin => role == 'admin';

  // toMap() yang diperbarui untuk mendukung insert (id=null) dan read (id!=null)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'name': name,
      'role': role,
    };
    // Hanya masukkan 'id' ke map jika nilainya ada (saat read dari DB)
    if (id != null) {
      map['id'] = id; // id di sini bertipe int? yang valid untuk Map<String, dynamic>
    }
    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      name: map['name'] as String,
      role: map['role'] as String? ?? 'customer', // Ambil role, default customer
    );
  }
}