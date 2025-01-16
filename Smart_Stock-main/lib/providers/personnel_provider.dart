import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class PersonnelProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _personnel = [];

  List<Map<String, dynamic>> get personnel => _personnel;

  // Load all personnel from database
  Future<void> loadPersonnel() async {
    _personnel = await _db.getAllPersonnel();
    notifyListeners();
  }

  // Add new personnel
  Future<void> addPersonnel({
    required String name,
    required String password,
    required String role,
  }) async {
    final Map<String, dynamic> newPersonnel = {
      'name': name,
      'password': password,
      'role': role,
    };

    await _db.insertPersonnel(newPersonnel);
    await loadPersonnel(); // Reload the list after adding
  }

  // Remove personnel
  Future<void> removePersonnel(int index) async {
    if (index >= 0 && index < _personnel.length) {
      final personnelId = _personnel[index]['id'] as int;
      await _db.deletePersonnel(personnelId);
      await loadPersonnel(); // Reload the list after deletion
    }
  }

  // Login check
  Future<Map<String, dynamic>?> login(String name, String password) async {
    return await _db.getPersonnelByNameAndPassword(name, password);
  }
}
