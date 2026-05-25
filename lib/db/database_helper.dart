import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('swiftdo.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
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

    // Categorias de estudo - ver se é bom deixar o usuario escolher
    await db.insert('categorias', {'nome': 'Matemática', 'cor': '#1565C0'});
    await db.insert('categorias', {'nome': 'História', 'cor': '#2E7D32'});
    await db.insert('categorias', {'nome': 'Física', 'cor': '#C62828'});
    await db.insert('categorias', {'nome': 'Leitura', 'cor': '#E65100'});
    await db.insert('categorias', {'nome': 'Projetos', 'cor': '#6A1B9A'});

    // cronometro pomodoro
    await db.insert('configuracoes', {'chave': 'tema_escuro', 'valor': '0'});
    await db.insert('configuracoes', {'chave': 'notificacoes', 'valor': '1'});
    await db.insert('configuracoes', {'chave': 'som_cronometro', 'valor': '1'});
    await db.insert('configuracoes', {'chave': 'meta_diaria', 'valor': '5'});
    await db.insert('configuracoes', {'chave': 'meta_semanal', 'valor': '35'});
    await db.insert('configuracoes', {'chave': 'foco_min', 'valor': '25'});
    await db.insert('configuracoes', {'chave': 'pausa_min', 'valor': '5'});
  }
}