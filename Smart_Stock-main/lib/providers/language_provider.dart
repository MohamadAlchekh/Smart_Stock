import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageProvider with ChangeNotifier {
  void setLanguage(BuildContext context, String langCode) {
    switch (langCode) {
      case 'tr':
        context.setLocale(const Locale('tr'));
        break;
      case 'en':
        context.setLocale(const Locale('en'));
        break;
      case 'ar':
        context.setLocale(const Locale('ar'));
        break;
    }
    notifyListeners();
  }
} 