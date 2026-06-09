import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/dao/categoria_dao.dart';
import 'package:swiftdo/dao/configuracao_dao.dart';
import 'package:swiftdo/dao/sessao_dao.dart';
import 'package:swiftdo/dao/tarefa_dao.dart';
import 'package:swiftdo/db/database_seed.dart';

import '../helpers/test_database.dart';

void main() {
  setUp(() async => setupTestDatabase());
  tearDown(() async => teardownTestDatabase());

  test('seed cria 9 categorias padrão', () async {
    final categorias = await CategoriaDao().findAll();
    expect(categorias.length, 9);
    expect(categorias.map((c) => c.nome).toList(), contains('Matemática'));
  });

  test('seed cria configurações padrão', () async {
    final config = await ConfiguracaoDao().getAll();
    expect(config['idioma'], 'pt');
    expect(config['foco_min'], '25');
    expect(config[DatabaseSeed.seedVersionKey], '${DatabaseSeed.currentSeedVersion}');
  });

  test('demo seed insere tarefas e sessões de exemplo', () async {
    final tarefas = await TarefaDao().findAll();
    final sessoes = await SessaoFocoDao().findAll();

    expect(tarefas.length, greaterThanOrEqualTo(6));
    expect(sessoes.length, greaterThanOrEqualTo(3));
    expect(await ConfiguracaoDao().get(DatabaseSeed.demoInstaladoKey), '1');
  });

  test('seed é idempotente — segunda execução não duplica categorias', () async {
    final antes = await CategoriaDao().findAll();
    await CategoriaDao().ensureDefaults();
    final depois = await CategoriaDao().findAll();
    expect(depois.length, antes.length);
  });
}
