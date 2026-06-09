import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/dao/categoria_dao.dart';
import 'package:swiftdo/models/categoria.dart';

import '../helpers/test_database.dart';

void main() {
  late CategoriaDao dao;

  setUp(() async {
    await setupTestDatabase();
    dao = CategoriaDao();
  });

  tearDown(() async => teardownTestDatabase());

  test('insert e findById', () async {
    final id = await dao.insert(Categoria(nome: 'Teste', cor: '#FF0000'));
    final categoria = await dao.findById(id);
    expect(categoria?.nome, 'Teste');
    expect(categoria?.cor, '#FF0000');
  });

  test('update altera nome', () async {
    final id = await dao.insert(Categoria(nome: 'Antes', cor: '#111111'));
    await dao.update(Categoria(id: id, nome: 'Depois', cor: '#222222'));
    expect((await dao.findById(id))?.nome, 'Depois');
  });

  test('delete remove categoria', () async {
    final id = await dao.insert(Categoria(nome: 'Temp', cor: '#333333'));
    await dao.delete(id);
    expect(await dao.findById(id), isNull);
  });
}
