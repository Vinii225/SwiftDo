import 'package:sqflite/sqflite.dart';

/// Bootstrap + demo seeding idempotente para o SwiftDo.
class DatabaseSeed {
  static const seedVersionKey = 'seed_version';
  static const currentSeedVersion = 2;
  static const demoInstaladoKey = 'demo_instalado';

  static const categoriasPadrao = [
    {'nome': 'Matemática', 'cor': '#1565C0'},
    {'nome': 'História', 'cor': '#2E7D32'},
    {'nome': 'Física', 'cor': '#C62828'},
    {'nome': 'Química', 'cor': '#00838F'},
    {'nome': 'Biologia', 'cor': '#558B2F'},
    {'nome': 'Inglês', 'cor': '#5E35B1'},
    {'nome': 'Programação', 'cor': '#3949AB'},
    {'nome': 'Leitura', 'cor': '#E65100'},
    {'nome': 'Projetos', 'cor': '#6A1B9A'},
  ];

  static const configuracoesPadrao = {
    'tema_escuro': '0',
    'notificacoes': '1',
    'som_cronometro': '1',
    'meta_diaria': '5',
    'meta_semanal': '35',
    'foco_min': '25',
    'pausa_min': '5',
    'idioma': 'pt',
    demoInstaladoKey: '0',
  };

  static Future<void> run(Database db) async {
    await _applySeedMigration(db);
    await _seedCategorias(db);
    await _seedConfiguracoes(db);
    await _seedDemo(db);
    await _setConfig(db, seedVersionKey, '$currentSeedVersion');
  }

  /// Apaga tudo e reinsere do zero quando a versão do seed muda.
  static Future<void> _applySeedMigration(Database db) async {
    try {
      final row = await db.query(
        'configuracoes',
        where: 'chave = ?',
        whereArgs: [seedVersionKey],
        limit: 1,
      );
      final stored = row.isEmpty
          ? 0
          : int.tryParse(row.first['valor'] as String? ?? '') ?? 0;
      if (stored >= currentSeedVersion) return;

      await db.delete('tarefas');
      await db.delete('sessoes_foco');
      await db.delete('categorias');
      await db.delete('configuracoes');
    } on DatabaseException {
      // Banco novo ou incompleto — seed normal cuida do restante.
    }
  }

  static Future<void> _seedCategorias(Database db) async {
    for (final categoria in categoriasPadrao) {
      final existente = await db.query(
        'categorias',
        where: 'nome = ?',
        whereArgs: [categoria['nome']],
        limit: 1,
      );
      if (existente.isEmpty) {
        await db.insert('categorias', categoria);
      }
    }
  }

  static Future<void> _seedConfiguracoes(Database db) async {
    for (final entry in configuracoesPadrao.entries) {
      final existente = await db.query(
        'configuracoes',
        where: 'chave = ?',
        whereArgs: [entry.key],
        limit: 1,
      );
      if (existente.isEmpty) {
        await db.insert('configuracoes', {
          'chave': entry.key,
          'valor': entry.value,
        });
      }
    }
  }

  static Future<void> _seedDemo(Database db) async {
    final demoFlag = await db.query(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: [demoInstaladoKey],
      limit: 1,
    );
    if (demoFlag.isNotEmpty && demoFlag.first['valor'] == '1') return;

    final tarefas = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM tarefas'),
    ) ?? 0;
    final sessoes = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM sessoes_foco'),
    ) ?? 0;
    if (tarefas > 0 || sessoes > 0) {
      await _setConfig(db, demoInstaladoKey, '1');
      return;
    }

    final categorias = await db.query('categorias');
    final porNome = {
      for (final row in categorias) row['nome'] as String: row['id'] as int,
    };

    int? id(String nome) => porNome[nome];

    final hoje = DateTime.now();
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final tarefasDemo = [
      {
        'titulo': 'Revisar equações do 2º grau',
        'categoria': 'Matemática',
        'data': fmt(hoje),
        'concluida': 0,
        'tempo_estudo_min': 0,
      },
      {
        'titulo': 'Resumir aula de História',
        'categoria': 'História',
        'data': fmt(hoje),
        'concluida': 0,
        'tempo_estudo_min': 0,
      },
      {
        'titulo': 'Ler capítulo 4 do livro',
        'categoria': 'Leitura',
        'data': fmt(hoje.subtract(const Duration(days: 1))),
        'concluida': 1,
        'tempo_estudo_min': 30,
      },
      {
        'titulo': 'Exercícios de cinemática',
        'categoria': 'Física',
        'data': fmt(hoje.subtract(const Duration(days: 2))),
        'concluida': 1,
        'tempo_estudo_min': 45,
      },
      {
        'titulo': 'Montar apresentação do projeto',
        'categoria': 'Projetos',
        'data': fmt(hoje.subtract(const Duration(days: 3))),
        'concluida': 1,
        'tempo_estudo_min': 60,
      },
      {
        'titulo': 'Praticar vocabulário em inglês',
        'categoria': 'Inglês',
        'data': fmt(hoje.subtract(const Duration(days: 4))),
        'concluida': 1,
        'tempo_estudo_min': 20,
      },
    ];

    for (final tarefa in tarefasDemo) {
      final categoriaId = id(tarefa['categoria'] as String);
      if (categoriaId == null) continue;
      await db.insert('tarefas', {
        'titulo': tarefa['titulo'],
        'categoria_id': categoriaId,
        'data': tarefa['data'],
        'concluida': tarefa['concluida'],
        'tempo_estudo_min': tarefa['tempo_estudo_min'],
      });
    }

    final sessoesDemo = [
      {'duracao_min': 25, 'offset': 0},
      {'duracao_min': 25, 'offset': 1},
      {'duracao_min': 15, 'offset': 2},
    ];

    for (final sessao in sessoesDemo) {
      await db.insert('sessoes_foco', {
        'tarefa_id': null,
        'duracao_min': sessao['duracao_min'],
        'data': fmt(hoje.subtract(Duration(days: sessao['offset'] as int))),
      });
    }

    await _setConfig(db, demoInstaladoKey, '1');
  }

  static Future<void> _setConfig(Database db, String chave, String valor) async {
    await db.insert(
      'configuracoes',
      {'chave': chave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
