import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';

class ConfiguracaoDao {
  final db = DatabaseHelper.instance;

  Future<String?> get(String chave) async {
    final database = await db.database;
    final result = await database.query(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [chave],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return result.first['valor'] as String?;
  }

  Future<Map<String, String>> getAll() async {
    final database = await db.database;
    final result = await database.query('configuracoes');
    return {
      for (final row in result) row['chave'] as String: row['valor'] as String,
    };
  }

  Future<void> set(String chave, String valor) async {
    final database = await db.database;
    await database.insert(
      'configuracoes',
      {'chave': chave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Helpers tipados para as chaves do app

  Future<bool> getTemaEscuro() async =>
      (await get('tema_escuro')) == '1';

  Future<void> setTemaEscuro(bool valor) async =>
      await set('tema_escuro', valor ? '1' : '0');

  Future<bool> getNotificacoes() async =>
      (await get('notificacoes')) == '1';

  Future<void> setNotificacoes(bool valor) async =>
      await set('notificacoes', valor ? '1' : '0');

  Future<bool> getSomCronometro() async =>
      (await get('som_cronometro')) == '1';

  Future<void> setSomCronometro(bool valor) async =>
      await set('som_cronometro', valor ? '1' : '0');

  Future<int> getMetaDiaria() async =>
      int.tryParse(await get('meta_diaria') ?? '5') ?? 5;

  Future<void> setMetaDiaria(int valor) async =>
      await set('meta_diaria', valor.toString());

  Future<int> getMetaSemanal() async =>
      int.tryParse(await get('meta_semanal') ?? '35') ?? 35;

  Future<void> setMetaSemanal(int valor) async =>
      await set('meta_semanal', valor.toString());

  Future<int> getFocoMin() async =>
      int.tryParse(await get('foco_min') ?? '5') ?? 5;

  Future<void> setFocoMin(int valor) async =>
      await set('foco_min', valor.toString());

  Future<int> getPausaMin() async =>
      int.tryParse(await get('pausa_min') ?? '1') ?? 1;

  Future<void> setPausaMin(int valor) async =>
      await set('pausa_min', valor.toString());
}