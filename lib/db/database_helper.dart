// lib/data/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/payment.dart';

class DatabaseHelper {
  static const _databaseName = "bakery_app.db";
  static const _databaseVersion = 1;

  static const tableUsers = 'users';
  static const tableHistory = 'history';

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
        onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableUsers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL
          )
          ''');

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
  }

  // --- USER/LOGIN METHODS ---

  Future<int> insertUser(User user) async {
    Database db = await instance.database;
    return await db.insert(tableUsers, user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      columns: ['id', 'username', 'name'],
      where: 'username = ?',
      whereArgs: [username],
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
}