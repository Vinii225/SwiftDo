import '../db/database_helper.dart';
import '../models/tarefa.dart';

class TarefaDao {
  final db = DatabaseHelper.instance;

  Future<int> insert(Tarefa tarefa) async {
    final database = await db.database;
    return await database.insert('tarefas', tarefa.toMap()..remove('id'));
  }

  Future<List<Tarefa>> findAll() async {
    final database = await db.database;
    final result = await database.query('tarefas', orderBy: 'data ASC');
    return result.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<List<Tarefa>> findByData(String data) async {
    final database = await db.database;
    final result = await database.query(
      'tarefas',
      where: 'data = ?',
      whereArgs: [data],
      orderBy: 'id ASC',
    );
    return result.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<List<Tarefa>> findByCategoria(int categoriaId) async {
    final database = await db.database;
    final result = await database.query(
      'tarefas',
      where: 'categoria_id = ?',
      whereArgs: [categoriaId],
      orderBy: 'data ASC',
    );
    return result.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<List<Tarefa>> findPendentes() async {
    final database = await db.database;
    final result = await database.query(
      'tarefas',
      where: 'concluida = 0',
      orderBy: 'data ASC',
    );
    return result.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<Tarefa?> findById(int id) async {
    final database = await db.database;
    final result = await database.query(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Tarefa.fromMap(result.first);
  }

  Future<int> update(Tarefa tarefa) async {
    final database = await db.database;
    return await database.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<int> marcarConcluida(int id, {bool concluida = true}) async {
    final database = await db.database;
    return await database.update(
      'tarefas',
      {'concluida': concluida ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> adicionarTempoEstudo(int id, int minutosExtras) async {
    final database = await db.database;
    final tarefa = await findById(id);
    if (tarefa == null) return 0;
    return await database.update(
      'tarefas',
      {'tempo_estudo_min': tarefa.tempoEstudoMin + minutosExtras},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final database = await db.database;
    return await database.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}