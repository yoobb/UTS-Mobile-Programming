import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/payment.dart';
import '../models/menu_item.dart'; // Import model baru

class DatabaseHelper {
  static const _databaseName = "bakery_app.db";
  static const _databaseVersion = 2; // Versi naik ke 2

  static const tableUsers = 'users';
  static const tableHistory = 'history';
  static const tableMenu = 'menu'; // Tabel baru

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade); // Tambahkan onUpgrade
  }

  Future _onCreate(Database db, int version) async {
    // Tabel Users (diperbarui dengan kolom 'role')
    await db.execute('''
          CREATE TABLE $tableUsers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'customer'
          )
          ''');

    // Tabel History
    await db.execute('''
          CREATE TABLE $tableHistory (
            dbId INTEGER PRIMARY KEY AUTOINCREMENT,
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

    // Tabel Menu (Baru)
    await db.execute('''
          CREATE TABLE $tableMenu (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT,
            image TEXT,
            category TEXT NOT NULL
          )
          ''');
  }

  // Handle upgrade database (misalnya jika ada penambahan kolom)
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Menambahkan kolom 'role' ke tabel users (jika belum ada)
      try {
        await db.execute("ALTER TABLE $tableUsers ADD COLUMN role TEXT NOT NULL DEFAULT 'customer'");
      } catch (_) {
        // Kolom sudah ada, atau error lain. Diabaikan karena ini untuk migrasi.
      }

      // Membuat tabel menu (jika belum ada)
      await db.execute('''
          CREATE TABLE IF NOT EXISTS $tableMenu (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            price REAL NOT NULL,
            description TEXT,
            image TEXT,
            category TEXT NOT NULL
          )
          ''');
    }
  }


  // --- USER/LOGIN METHODS ---

  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    // Menggunakan toMap() yang sudah di-update
    return await db.insert(tableUsers, user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      // Sekarang kita juga mengambil 'role'
      columns: ['id', 'username', 'name', 'role'],
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // Tambahkan metode untuk mendapatkan user Admin default.
  Future<User?> getAdminUser() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      columns: ['id', 'username', 'name', 'role'],
      where: 'role = ?',
      whereArgs: ['admin'],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // --- HISTORY METHODS ---

  Future<int> insertPaymentRecord(PaymentRecord record) async {
    Database db = await instance.database;
    return await db.insert(tableHistory, record.toMap());
  }

  Future<List<PaymentRecord>> getHistoryByUserId(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableHistory,
      columns: ['dbId', 'userId', 'id', 'buyerName', 'total', 'paid', 'change', 'paymentMethod', 'itemsJson'],
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'dbId DESC',
    );

    return List.generate(maps.length, (i) {
      return PaymentRecord.fromMap(maps[i]);
    });
  }

  // --- MENU CRUD METHODS (BARU) ---

  Future<int> insertMenuItem(MenuItem item) async {
    Database db = await instance.database;
    return await db.insert(tableMenu, item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteMenuItem(String id) async {
    Database db = await instance.database;
    return await db.delete(
      tableMenu,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MenuItem>> getAllMenuItems() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(tableMenu, orderBy: 'category, name');

    return List.generate(maps.length, (i) {
      return MenuItem.fromMap(maps[i]);
    });
  }

  Future<int> getMenuItemCount() async {
    Database db = await instance.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableMenu'));
    return count ?? 0;
  }
}