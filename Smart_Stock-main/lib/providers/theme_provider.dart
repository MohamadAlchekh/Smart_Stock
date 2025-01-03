import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData(
    primaryColor: const Color(0xFF1A237E),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF1A237E),
      secondary: const Color(0xFF303F9F),
    ),
  );

  ThemeData get themeData => _themeData;

  void setTheme(String themeKey) {
    switch (themeKey) {
      case 'blue':
        _themeData = ThemeData(
          primaryColor: const Color(0xFF1A237E),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFF1A237E),
            secondary: const Color(0xFF303F9F),
          ),
        );
        break;
      case 'dark':
        _themeData = ThemeData.dark().copyWith(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.dark().copyWith(
            primary: Colors.black,
            secondary: Colors.grey[800]!,
          ),
        );
        break;
    }
    notifyListeners();
  }
} 