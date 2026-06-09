import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/dao/sessao_dao.dart';
import 'package:swiftdo/models/sessao_foco.dart';

import '../helpers/test_database.dart';

void main() {
  late SessaoFocoDao dao;

  setUp(() async {
    await setupTestDatabase();
    dao = SessaoFocoDao();
  });

  tearDown(() async => teardownTestDatabase());

  test('insert e findByData', () async {
    await dao.insert(SessaoFoco(duracaoMin: 25, data: '2026-06-09'));
    await dao.insert(SessaoFoco(duracaoMin: 15, data: '2026-06-09'));

    final doDia = await dao.findByData('2026-06-09');
    expect(doDia.length, greaterThanOrEqualTo(2));
    expect(await dao.totalMinutosPorData('2026-06-09'), greaterThanOrEqualTo(40));
  });

  test('delete remove sessão', () async {
    final id = await dao.insert(SessaoFoco(duracaoMin: 10, data: '2026-06-01'));
    await dao.delete(id);
    expect((await dao.findAll()).any((s) => s.id == id), isFalse);
  });
}
