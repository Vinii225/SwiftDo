import '../db/database_helper.dart';
import '../models/categoria.dart';

class CategoriaDao {
  final db = DatabaseHelper.instance;

  Future<int> insert(Categoria categoria) async {
    final database = await db.database;
    return await database.insert('categorias', categoria.toMap()..remove('id'));
  }

  Future<List<Categoria>> findAll() async {
    final database = await db.database;
    final result = await database.query('categorias', orderBy: 'nome ASC');
    return result.map((map) => Categoria.fromMap(map)).toList();
  }

  Future<Categoria?> findById(int id) async {
    final database = await db.database;
    final result = await database.query(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Categoria.fromMap(result.first);
  }

  Future<int> update(Categoria categoria) async {
    final database = await db.database;
    return await database.update(
      'categorias',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  Future<int> delete(int id) async {
    final database = await db.database;
    return await database.delete(
      'categorias',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}