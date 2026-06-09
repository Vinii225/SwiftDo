import 'package:flutter/material.dart';
import '../dao/configuracao_dao.dart';

class ThemeProvider extends ChangeNotifier {
  final _dao = ConfiguracaoDao();
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await _dao.getTemaEscuro();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      await _dao.setTemaEscuro(isDark);
    } catch (e) {
      // Silently fail or log error, but UI is already updated
    }
  }

}
