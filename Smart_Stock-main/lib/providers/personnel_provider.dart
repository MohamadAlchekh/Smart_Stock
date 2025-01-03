import 'package:flutter/material.dart';

class PersonnelProvider with ChangeNotifier {
  final List<Map<String, String>> _personnel = [];

  List<Map<String, String>> get personnel => _personnel;

  void addPersonnel({
    required String name,
    required String password,
    required String role,
  }) {
    _personnel.add({
      'name': name,
      'password': password,
      'role': role,
    });
    notifyListeners();
  }

  void removePersonnel(int index) {
    _personnel.removeAt(index);
    notifyListeners();
  }

  bool checkCredentials(String name, String password) {
    return _personnel.any((person) =>
        person['name'] == name && person['password'] == password);
  }

  String? getRole(String name) {
    final person = _personnel.firstWhere(
      (person) => person['name'] == name,
      orElse: () => {},
    );
    return person['role'];
  }
} 