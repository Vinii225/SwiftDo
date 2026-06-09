import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/dao/categoria_dao.dart';
import 'package:swiftdo/dao/tarefa_dao.dart';
import 'package:swiftdo/models/tarefa.dart';

import '../helpers/test_database.dart';

void main() {
  late TarefaDao tarefaDao;
  late int categoriaId;

  setUp(() async {
    await setupTestDatabase();
    tarefaDao = TarefaDao();
    final categorias = await CategoriaDao().findAll();
    categoriaId = categorias.firstWhere((c) => c.nome == 'Matemática').id!;
  });

  tearDown(() async => teardownTestDatabase());

  test('insert e findById', () async {
    final id = await tarefaDao.insert(Tarefa(
      titulo: 'Resolver lista',
      categoriaId: categoriaId,
      data: '2026-06-09',
    ));

    final tarefa = await tarefaDao.findById(id);
    expect(tarefa?.titulo, 'Resolver lista');
    expect(tarefa?.concluida, 0);
  });

  test('update altera título', () async {
    final id = await tarefaDao.insert(Tarefa(
      titulo: 'Antes',
      categoriaId: categoriaId,
      data: '2026-06-09',
    ));
    final criada = (await tarefaDao.findById(id))!;

    await tarefaDao.update(Tarefa(
      id: criada.id,
      titulo: 'Depois',
      categoriaId: criada.categoriaId,
      data: criada.data,
      concluida: criada.concluida,
      tempoEstudoMin: criada.tempoEstudoMin,
    ));

    expect((await tarefaDao.findById(id))?.titulo, 'Depois');
  });

  test('marcarConcluida e findPendentes', () async {
    final id = await tarefaDao.insert(Tarefa(
      titulo: 'Pendente',
      categoriaId: categoriaId,
      data: '2026-06-10',
    ));

    await tarefaDao.marcarConcluida(id, concluida: true);
    expect((await tarefaDao.findById(id))?.concluida, 1);
    expect((await tarefaDao.findPendentes()).any((t) => t.id == id), isFalse);

    await tarefaDao.marcarConcluida(id, concluida: false);
    expect((await tarefaDao.findPendentes()).any((t) => t.id == id), isTrue);
  });

  test('findByData retorna tarefas do dia', () async {
    await tarefaDao.insert(Tarefa(
      titulo: 'Do dia',
      categoriaId: categoriaId,
      data: '2026-06-15',
    ));

    final doDia = await tarefaDao.findByData('2026-06-15');
    expect(doDia.any((t) => t.titulo == 'Do dia'), isTrue);
    expect(await tarefaDao.findByData('2099-01-01'), isEmpty);
  });

  test('adicionarTempoEstudo acumula minutos', () async {
    final id = await tarefaDao.insert(Tarefa(
      titulo: 'Estudo',
      categoriaId: categoriaId,
      data: '2026-06-09',
      tempoEstudoMin: 10,
    ));

    await tarefaDao.adicionarTempoEstudo(id, 15);
    expect((await tarefaDao.findById(id))?.tempoEstudoMin, 25);
  });

  test('delete remove tarefa', () async {
    final id = await tarefaDao.insert(Tarefa(
      titulo: 'Apagar',
      categoriaId: categoriaId,
      data: '2026-06-09',
    ));

    await tarefaDao.delete(id);
    expect(await tarefaDao.findById(id), isNull);
  });
}
