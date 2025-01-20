import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class PersonelProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _personel = [];

  List<Map<String, dynamic>> get personel => _personel;

  // Load all personel from database
  Future<void> loadpersonel() async {
    _personel = await _db.getAllpersonel();
    notifyListeners();
  }

  // Add new personel
  Future<void> addpersonel({
    required String name,
    required String password,
    required String role,
  }) async {
    final Map<String, dynamic> newpersonel = {
      'name': name,
      'password': password,
      'role': role,
    };

    await _db.insertpersonel(newpersonel);
    await loadpersonel(); // Reload the list after adding
  }

  // Remove personel
  Future<void> removepersonel(int index) async {
    if (index >= 0 && index < _personel.length) {
      final personelId = _personel[index]['id'] as int;
      await _db.deletepersonel(personelId);
      await loadpersonel(); // Reload the list after deletion
    }
  }

  // Login check
  Future<Map<String, dynamic>?> login(String name, String password) async {
    return await _db.getpersonelByNameAndPassword(name, password);
  }
}
