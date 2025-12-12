import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Default to light mode if error
      _themeMode = ThemeMode.light;
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDarkMode);
    } catch (e) {
      // Ignore persistence errors
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, mode == ThemeMode.dark);
    } catch (e) {
      // Ignore persistence errors
    }
  }
}
