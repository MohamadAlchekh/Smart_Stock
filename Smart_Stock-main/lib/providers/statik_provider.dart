import 'package:flutter/material.dart';

class StatisticsProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _logs = [];

  List<Map<String, dynamic>> get logs => _logs;

  void addLog(
    String userName,
    String warehouseName,
    String blockName,
    String productName,
    int quantity,
    bool isAddition, {
    String? role,
  }) {
    final String displayName = role != null ? '$userName ($role)' : userName;
    final String action = isAddition ? 'ekledi' : 'sildi';
    final String logMessage = '$displayName, $warehouseName $blockName\'e $quantity adet $productName $action';

    _logs.add({
      'message': logMessage,
      'timestamp': DateTime.now(),
      'userName': userName,
      'warehouseName': warehouseName,
      'blockName': blockName,
      'productName': productName,
      'quantity': quantity,
      'isAddition': isAddition,
      'role': role,
    });

    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
} 