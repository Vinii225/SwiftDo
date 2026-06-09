import 'package:sqflite/sqflite.dart';
import 'database_path.dart';
import 'database_seed.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('swiftdo.db');
    return _database!;
  }

  /// Fecha e apaga o arquivo do banco (útil para reset total no web/desktop).
  Future<void> reset() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    final path = await getDatabaseFilePath('swiftdo.db');
    await deleteDatabase(path);
  }

  Future<Database> _initDB(String fileName) async {
    final path = await getDatabaseFilePath(fileName);
    try {
      return await _openAt(path);
    } catch (_) {
      try {
        await deleteDatabase(path);
      } catch (_) {}
      return await _openAt(path);
    }
  }

  Future<Database> _openAt(String path) {
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: _onOpen,
    );
  }

  Future<void> _onOpen(Database db) async {
    await DatabaseSeed.run(db);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categorias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        cor TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        categoria_id INTEGER NOT NULL,
        data TEXT NOT NULL,
        concluida INTEGER NOT NULL DEFAULT 0,
        tempo_estudo_min INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sessoes_foco (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tarefa_id INTEGER,
        duracao_min INTEGER NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (tarefa_id) REFERENCES tarefas(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE configuracoes (
        chave TEXT PRIMARY KEY,
        valor TEXT NOT NULL
      )
    ''');

    await DatabaseSeed.run(db);
  }
}
