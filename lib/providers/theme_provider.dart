import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Theme provider for dark/light mode toggling.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _currencySymbol = '₹';
  String _currencyCode = 'INR';

  bool get isDarkMode => _isDarkMode;
  String get currencySymbol => _currencySymbol;
  String get currencyCode => _currencyCode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    _currencyCode = prefs.getString(AppConstants.keyCurrency) ?? 'INR';
    _currencySymbol = AppConstants.currencies
        .firstWhere((c) => c['code'] == _currencyCode,
            orElse: () => {'symbol': '₹'})['symbol']!;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _currencyCode = code;
    _currencySymbol = AppConstants.currencies
        .firstWhere((c) => c['code'] == code,
            orElse: () => {'symbol': '₹'})['symbol']!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrency, code);
    notifyListeners();
  }
}
