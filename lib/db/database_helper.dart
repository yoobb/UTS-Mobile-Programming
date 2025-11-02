import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/payment.dart';

class DatabaseHelper {
  static const _databaseName = "bakery_app.db";
  static const _databaseVersion = 1;

  // Nama Tabel
  static const tableUsers = 'users';
  static const tableHistory = 'history';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database reference
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Buka database
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // Buat tabel
  Future _onCreate(Database db, int version) async {
    // Tabel User (untuk Login/Daftar)
    await db.execute('''
          CREATE TABLE $tableUsers (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL
          )
          ''');

    // Tabel History (untuk Riwayat Pesanan)
    await db.execute('''
          CREATE TABLE $tableHistory (
            dbId INTEGER PRIMARY KEY,
            userId INTEGER NOT NULL,
            id TEXT NOT NULL,
            buyerName TEXT NOT NULL,
            total REAL NOT NULL,
            paid REAL NOT NULL,
            change REAL NOT NULL,
            paymentMethod TEXT NOT NULL,
            itemsJson TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES $tableUsers (id)
          )
          ''');
  }

  // --- USER/LOGIN METHODS ---

  // Daftar (Insert User)
  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, user.toMap());
  }

  // Login (Get User by Username)
  Future<User?> getUserByUsername(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // --- HISTORY METHODS ---

  // Simpan Riwayat Pembayaran
  Future<int> insertPaymentRecord(PaymentRecord record) async {
    Database db = await instance.database;
    return await db.insert(tableHistory, record.toMap());
  }

  // Ambil Riwayat Pesanan untuk User tertentu
  Future<List<PaymentRecord>> getHistoryByUserId(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableHistory,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dbId DESC',
    );

    return List.generate(maps.length, (i) {
      return PaymentRecord.fromMap(maps[i]);
    });
  }
}