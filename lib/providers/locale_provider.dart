import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../dao/configuracao_dao.dart';

class LocaleProvider extends ChangeNotifier {
  /// Evita I/O assíncrono em widget tests (providers sobrevivem ao tearDown do banco).
  @visibleForTesting
  static bool skipInitialLoadForTests = false;

  final _dao = ConfiguracaoDao();
  Locale _locale = const Locale('pt');
  bool _disposed = false;

  Locale get locale => _locale;

  LocaleProvider() {
    if (!skipInitialLoadForTests) _loadLocale();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _dao.get('idioma') ?? 'pt';
    if (_disposed) return;
    _locale = Locale(languageCode);
    _notify();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'pt', 'es'].contains(locale.languageCode)) return;
    _locale = locale;
    await _dao.set('idioma', locale.languageCode);
    _notify();
  }
}
