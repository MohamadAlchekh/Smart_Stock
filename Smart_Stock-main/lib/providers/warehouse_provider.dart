import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class WarehouseProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _warehouses = [];

  List<Map<String, dynamic>> get warehouses => _warehouses;

  // Load all warehouses from database
  Future<void> loadWarehouses() async {
    _warehouses = await _db.getAllWarehouses();
    notifyListeners();
  }

  // Add new warehouse
  Future<void> addWarehouse({
    required String name,
    required String icon,
    required List<String> blockNames,
  }) async {
    final Map<String, dynamic> newWarehouse = {
      'name': name,
      'icon': icon,
    };

    await _db.insertWarehouse(newWarehouse, blockNames);
    await loadWarehouses(); // Reload the list after adding
  }

  // Update warehouse
  Future<void> updateWarehouse(Map<String, dynamic> warehouse) async {
    await _db.updateWarehouse(warehouse);
    await loadWarehouses();
  }

  // Update block
  Future<void> updateBlock(Map<String, dynamic> block) async {
    await _db.updateBlock(block);
    await loadWarehouses();
  }

  // Delete warehouse
  Future<void> deleteWarehouse(int id) async {
    await _db.deleteWarehouse(id);
    await loadWarehouses();
  }
}
