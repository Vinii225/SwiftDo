import '../db/database_helper.dart';
import '../models/sessao_foco.dart';

class SessaoFocoDao {
  final db = DatabaseHelper.instance;

  Future<int> insert(SessaoFoco sessao) async {
    final database = await db.database;
    return await database.insert('sessoes_foco', sessao.toMap()..remove('id'));
  }

  Future<List<SessaoFoco>> findAll() async {
    final database = await db.database;
    final result = await database.query('sessoes_foco', orderBy: 'data DESC');
    return result.map((map) => SessaoFoco.fromMap(map)).toList();
  }

  Future<List<SessaoFoco>> findByTarefa(int tarefaId) async {
    final database = await db.database;
    final result = await database.query(
      'sessoes_foco',
      where: 'tarefa_id = ?',
      whereArgs: [tarefaId],
      orderBy: 'data DESC',
    );
    return result.map((map) => SessaoFoco.fromMap(map)).toList();
  }

  Future<List<SessaoFoco>> findByData(String data) async {
    final database = await db.database;
    final result = await database.query(
      'sessoes_foco',
      where: 'data = ?',
      whereArgs: [data],
      orderBy: 'id ASC',
    );
    return result.map((map) => SessaoFoco.fromMap(map)).toList();
  }

  /// Retorna o total de minutos de foco em uma data específica.
  Future<int> totalMinutosPorData(String data) async {
    final database = await db.database;
    final result = await database.rawQuery(
      'SELECT SUM(duracao_min) as total FROM sessoes_foco WHERE data = ?',
      [data],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  /// Retorna o total de minutos de foco por tarefa.
  Future<int> totalMinutosPorTarefa(int tarefaId) async {
    final database = await db.database;
    final result = await database.rawQuery(
      'SELECT SUM(duracao_min) as total FROM sessoes_foco WHERE tarefa_id = ?',
      [tarefaId],
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<int> delete(int id) async {
    final database = await db.database;
    return await database.delete(
      'sessoes_foco',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}