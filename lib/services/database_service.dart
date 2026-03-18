import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/purchase_model.dart';
import '../models/goal_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pimez.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE purchases(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        personName TEXT NOT NULL,
        community TEXT NOT NULL,
        kilos REAL NOT NULL,
        pricePerKilo REAL NOT NULL,
        totalAmount REAL NOT NULL,
        pepperType TEXT NOT NULL,
        quality TEXT NOT NULL,
        purchaseDate TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        targetKilos REAL NOT NULL,
        currentKilos REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isActive INTEGER NOT NULL
      )
    ''');
  }

  // Purchases CRUD
  Future<int> insertPurchase(Purchase purchase) async {
    Database db = await database;
    return await db.insert('purchases', purchase.toMap());
  }

  Future<List<Purchase>> getAllPurchases() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'purchases',
      orderBy: 'purchaseDate DESC',
    );
    return List.generate(maps.length, (i) => Purchase.fromMap(maps[i]));
  }

  Future<List<Purchase>> getPurchasesByType(String pepperType) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'purchases',
      where: 'pepperType = ?',
      whereArgs: [pepperType],
      orderBy: 'purchaseDate DESC',
    );
    return List.generate(maps.length, (i) => Purchase.fromMap(maps[i]));
  }

  Future<Purchase?> getPurchase(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'purchases',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Purchase.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updatePurchase(Purchase purchase) async {
    Database db = await database;
    return await db.update(
      'purchases',
      purchase.toMap(),
      where: 'id = ?',
      whereArgs: [purchase.id],
    );
  }

  Future<int> deletePurchase(int id) async {
    Database db = await database;
    return await db.delete(
      'purchases',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goals CRUD
  Future<int> insertGoal(Goal goal) async {
    Database db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getAllGoals() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<Goal?> getActiveGoal() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'goals',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return Goal.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateGoal(Goal goal) async {
    Database db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(int id) async {
    Database db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}