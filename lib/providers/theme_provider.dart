import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../dao/configuracao_dao.dart';

class ThemeProvider extends ChangeNotifier {
  @visibleForTesting
  static bool skipInitialLoadForTests = false;

  final _dao = ConfiguracaoDao();
  ThemeMode _themeMode = ThemeMode.light;
  bool _disposed = false;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    if (!skipInitialLoadForTests) _loadTheme();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _loadTheme() async {
    final isDark = await _dao.getTemaEscuro();
    if (_disposed) return;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _notify();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _notify();
    try {
      await _dao.setTemaEscuro(isDark);
    } catch (e) {
      // Silently fail or log error, but UI is already updated
    }
  }

}
