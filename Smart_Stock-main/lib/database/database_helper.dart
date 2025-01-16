import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Define valid roles
  static const String ROLE_ADMIN = 'admin';
  static const String ROLE_PERSONEL = 'personel';
  static const List<String> VALID_ROLES = [ROLE_ADMIN, ROLE_PERSONEL];

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_stock.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables
    await db.execute('''
      CREATE TABLE stocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        purchase_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE personnel (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE warehouses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        total_products INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE blocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        warehouse_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        products INTEGER DEFAULT 0,
        FOREIGN KEY (warehouse_id) REFERENCES warehouses (id) ON DELETE CASCADE
      )
    ''');

    // Add default personnel account
    await db.insert('personnel',
        {'name': 'test', 'password': 'test123', 'role': 'personel'});
  }

  // Personnel CRUD operations
  Future<int> insertPersonnel(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('personnel', row);
  }

  Future<List<Map<String, dynamic>>> getAllPersonnel() async {
    Database db = await database;
    return await db.query('personnel');
  }

  Future<Map<String, dynamic>?> getPersonnel(int id) async {
    Database db = await database;
    var results = await db.query('personnel', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getPersonnelByNameAndPassword(
      String name, String password) async {
    Database db = await database;
    var results = await db.query('personnel',
        where: 'name = ? AND password = ?', whereArgs: [name, password]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updatePersonnel(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('personnel', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePersonnel(int id) async {
    Database db = await database;
    return await db.delete('personnel', where: 'id = ?', whereArgs: [id]);
  }

  // Warehouse CRUD operations
  Future<int> insertWarehouse(
      Map<String, dynamic> row, List<String> blockNames) async {
    Database db = await database;
    int warehouseId = await db.insert('warehouses', {
      'name': row['name'],
      'icon': row['icon'],
      'total_products': 0,
    });

    // Insert blocks for this warehouse
    for (String blockName in blockNames) {
      await db.insert('blocks', {
        'warehouse_id': warehouseId,
        'name': blockName,
        'products': 0,
      });
    }

    return warehouseId;
  }

  Future<List<Map<String, dynamic>>> getAllWarehouses() async {
    Database db = await database;
    List<Map<String, dynamic>> warehouses = await db.query('warehouses');

    // For each warehouse, get its blocks
    for (var warehouse in warehouses) {
      List<Map<String, dynamic>> blocks = await db.query(
        'blocks',
        where: 'warehouse_id = ?',
        whereArgs: [warehouse['id']],
      );
      warehouse['blocks'] = blocks;
    }

    return warehouses;
  }

  Future<Map<String, dynamic>?> getWarehouse(int id) async {
    Database db = await database;
    var results =
        await db.query('warehouses', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;

    var warehouse = results.first;
    // Get blocks for this warehouse
    warehouse['blocks'] = await db.query(
      'blocks',
      where: 'warehouse_id = ?',
      whereArgs: [id],
    );

    return warehouse;
  }

  Future<int> updateWarehouse(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('warehouses', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateBlock(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];

    // Update block
    await db.update('blocks', row, where: 'id = ?', whereArgs: [id]);

    // Update total products in warehouse
    var blocks = await db.query(
      'blocks',
      where: 'warehouse_id = ?',
      whereArgs: [row['warehouse_id']],
    );

    int totalProducts =
        blocks.fold(0, (sum, block) => sum + (block['products'] as int));

    return await db.update(
      'warehouses',
      {'total_products': totalProducts},
      where: 'id = ?',
      whereArgs: [row['warehouse_id']],
    );
  }

  Future<int> deleteWarehouse(int id) async {
    Database db = await database;
    // Blocks will be automatically deleted due to ON DELETE CASCADE
    return await db.delete('warehouses', where: 'id = ?', whereArgs: [id]);
  }

  // Stock CRUD operations
  Future<int> insertStock(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('stocks', row);
  }

  Future<List<Map<String, dynamic>>> getAllStocks() async {
    Database db = await database;
    return await db.query('stocks');
  }

  Future<Map<String, dynamic>?> getStock(int id) async {
    Database db = await database;
    var results = await db.query('stocks', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateStock(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('stocks', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStock(int id) async {
    Database db = await database;
    return await db.delete('stocks', where: 'id = ?', whereArgs: [id]);
  }
}
