import 'package:flutter/material.dart';
import '../dao/configuracao_dao.dart';

class LocaleProvider extends ChangeNotifier {
  final _dao = ConfiguracaoDao();
  Locale _locale = const Locale('pt');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _dao.get('idioma') ?? 'pt';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'pt', 'es'].contains(locale.languageCode)) return;
    _locale = locale;
    await _dao.set('idioma', locale.languageCode);
    notifyListeners();
  }
}
