import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/dao/configuracao_dao.dart';

import '../helpers/test_database.dart';

void main() {
  late ConfiguracaoDao dao;

  setUp(() async {
    await setupTestDatabase();
    dao = ConfiguracaoDao();
  });

  tearDown(() async => teardownTestDatabase());

  test('get retorna valor padrão do seed', () async {
    expect(await dao.get('idioma'), 'pt');
  });

  test('set sobrescreve valor existente', () async {
    await dao.set('idioma', 'en');
    expect(await dao.get('idioma'), 'en');
  });

  test('helpers tipados de tema e metas', () async {
    expect(await dao.getTemaEscuro(), isFalse);
    await dao.setTemaEscuro(true);
    expect(await dao.getTemaEscuro(), isTrue);

    await dao.setMetaDiaria(8);
    expect(await dao.getMetaDiaria(), 8);
  });
}
