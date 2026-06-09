import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/models/categoria.dart';
import 'package:swiftdo/models/sessao_foco.dart';
import 'package:swiftdo/models/tarefa.dart';

void main() {
  test('Tarefa toMap/fromMap preserva dados', () {
    final original = Tarefa(
      id: 1,
      titulo: 'Estudar',
      categoriaId: 3,
      data: '2026-06-09',
      concluida: 1,
      tempoEstudoMin: 30,
    );
    final restaurada = Tarefa.fromMap(original.toMap());
    expect(restaurada.id, original.id);
    expect(restaurada.titulo, original.titulo);
    expect(restaurada.categoriaId, original.categoriaId);
    expect(restaurada.concluida, original.concluida);
    expect(restaurada.tempoEstudoMin, original.tempoEstudoMin);
  });

  test('Categoria toMap/fromMap preserva dados', () {
    final original = Categoria(id: 2, nome: 'Física', cor: '#C62828');
    final restaurada = Categoria.fromMap(original.toMap());
    expect(restaurada.id, original.id);
    expect(restaurada.nome, original.nome);
    expect(restaurada.cor, original.cor);
  });

  test('SessaoFoco toMap/fromMap preserva dados', () {
    final original = SessaoFoco(id: 5, tarefaId: 10, duracaoMin: 25, data: '2026-06-09');
    final restaurada = SessaoFoco.fromMap(original.toMap());
    expect(restaurada.id, original.id);
    expect(restaurada.tarefaId, original.tarefaId);
    expect(restaurada.duracaoMin, original.duracaoMin);
    expect(restaurada.data, original.data);
  });
}
