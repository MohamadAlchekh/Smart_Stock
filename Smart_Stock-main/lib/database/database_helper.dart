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
      CREATE TABLE STOK (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        purchase_price REAL NOT NULL,
        purchase_date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE personel (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE Depo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        total_products INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE blok (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        warehouse_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        products INTEGER DEFAULT 0,
        FOREIGN KEY (warehouse_id) REFERENCES Depo (id) ON DELETE CASCADE
      )
    ''');

    await db.insert('personel',
        {'name': 'test', 'password': 'test123', 'role': 'personel'});
  }

  Future<int> insertpersonel(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('personel', row);
  }

  Future<List<Map<String, dynamic>>> getAllpersonel() async {
    Database db = await database;
    return await db.query('personel');
  }

  Future<Map<String, dynamic>?> getpersonel(int id) async {
    Database db = await database;
    var results = await db.query('personel', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> getpersonelByNameAndPassword(
      String name, String password) async {
    Database db = await database;
    var results = await db.query('personel',
        where: 'name = ? AND password = ?', whereArgs: [name, password]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updatepersonel(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('personel', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletepersonel(int id) async {
    Database db = await database;
    return await db.delete('personel', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertWarehouse(
      Map<String, dynamic> row, List<String> blockNames) async {
    Database db = await database;
    int warehouseId = await db.insert('Depo', {
      'name': row['name'],
      'icon': row['icon'],
      'total_products': 0,
    });

    for (String blockName in blockNames) {
      await db.insert('blok', {
        'warehouse_id': warehouseId,
        'name': blockName,
        'products': 0,
      });
    }

    return warehouseId;
  }

  Future<List<Map<String, dynamic>>> getAllWarehouses() async {
    Database db = await database;
    List<Map<String, dynamic>> Depo = await db.query('Depo');

    for (var warehouse in Depo) {
      List<Map<String, dynamic>> blok = await db.query(
        'blok',
        where: 'warehouse_id = ?',
        whereArgs: [warehouse['id']],
      );
      warehouse['blok'] = blok;
    }

    return Depo;
  }

  Future<Map<String, dynamic>?> getWarehouse(int id) async {
    Database db = await database;
    var results = await db.query('Depo', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;

    var warehouse = results.first;
    warehouse['blok'] = await db.query(
      'blok',
      where: 'warehouse_id = ?',
      whereArgs: [id],
    );

    return warehouse;
  }

  Future<int> updateWarehouse(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('Depo', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateBlock(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];

    await db.update('blok', row, where: 'id = ?', whereArgs: [id]);

    var blok = await db.query(
      'blok',
      where: 'warehouse_id = ?',
      whereArgs: [row['warehouse_id']],
    );

    int totalProducts =
        blok.fold(0, (sum, block) => sum + (block['products'] as int));

    return await db.update(
      'Depo',
      {'total_products': totalProducts},
      where: 'id = ?',
      whereArgs: [row['warehouse_id']],
    );
  }

  Future<int> deleteWarehouse(int id) async {
    Database db = await database;
    return await db.delete('Depo', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertStock(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('STOK', row);
  }

  Future<List<Map<String, dynamic>>> getAllSTOK() async {
    Database db = await database;
    return await db.query('STOK');
  }

  Future<Map<String, dynamic>?> getStock(int id) async {
    Database db = await database;
    var results = await db.query('STOK', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateStock(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row['id'];
    return await db.update('STOK', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStock(int id) async {
    Database db = await database;
    return await db.delete('STOK', where: 'id = ?', whereArgs: [id]);
  }
}
