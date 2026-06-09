import '../db/database_helper.dart';

/// Dados dos cards superiores do Dashboard.
class ResumoCard {
  final int tarefasConcluidas;
  final int metaSemanal;
  final int horasEstudo;
  final int totalTemas;

  ResumoCard({
    required this.tarefasConcluidas,
    required this.metaSemanal,
    required this.horasEstudo,
    required this.totalTemas,
  });
}

/// Atividade de um dia da semana para o gráfico de barras.
class AtividadeDia {
  final String diaSemana; // 'Seg', 'Ter', etc.
  final int tarefasConcluidas;

  AtividadeDia({required this.diaSemana, required this.tarefasConcluidas});
}

/// Progresso de um tema/categoria para a lista "Temas Estudados".
class ProgressoTema {
  final int categoriaId;
  final String nome;
  final String cor;
  final int totalTarefas;
  final int tarefasConcluidas;

  ProgressoTema({
    required this.categoriaId,
    required this.nome,
    required this.cor,
    required this.totalTarefas,
    required this.tarefasConcluidas,
  });

  double get percentual =>
      totalTarefas == 0 ? 0 : tarefasConcluidas / totalTarefas;
}

enum PeriodoDashboard { semana, mes, ano }

class DashboardDao {
  final db = DatabaseHelper.instance;

  // ─── helpers de intervalo ────────────────────────────────────────────────

  /// Retorna (dataInicio, dataFim) no formato 'yyyy-MM-dd' para o período.
  (String, String) _intervalo(PeriodoDashboard periodo) {
    final hoje = DateTime.now();
    late DateTime inicio;

    switch (periodo) {
      case PeriodoDashboard.semana:
        // Segunda-feira da semana atual
        final diasDesdeSegunda = (hoje.weekday - 1) % 7;
        inicio = hoje.subtract(Duration(days: diasDesdeSegunda));
        break;
      case PeriodoDashboard.mes:
        inicio = DateTime(hoje.year, hoje.month, 1);
        break;
      case PeriodoDashboard.ano:
        inicio = DateTime(hoje.year, 1, 1);
        break;
    }

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return (fmt(inicio), fmt(hoje));
  }

  // ─── cards ───────────────────────────────────────────────────────────────

  /// Dados dos 4 cards superiores do Dashboard.
  Future<ResumoCard> getResumo(PeriodoDashboard periodo) async {
    final database = await db.database;
    final (inicio, fim) = _intervalo(periodo);

    // Tarefas concluídas no período
    final concluidas = await database.rawQuery(
      '''SELECT COUNT(*) as total FROM tarefas
         WHERE concluida = 1 AND data BETWEEN ? AND ?''',
      [inicio, fim],
    );
    final tarefasConcluidas = (concluidas.first['total'] as int?) ?? 0;

    // Meta semanal (sempre da configuração, independente do período)
    final meta = await database.query(
      'configuracoes',
      where: 'chave = ?',
      whereArgs: ['meta_semanal'],
      limit: 1,
    );
    final metaSemanal =
        int.tryParse(meta.isEmpty ? '35' : meta.first['valor'] as String) ?? 35;

    // Horas de estudo (soma das sessões de foco no período)
    final horas = await database.rawQuery(
      '''SELECT SUM(duracao_min) as total FROM sessoes_foco
         WHERE data BETWEEN ? AND ?''',
      [inicio, fim],
    );
    final minutosEstudo = (horas.first['total'] as int?) ?? 0;
    final horasEstudo = minutosEstudo ~/ 60;

    // Total de temas (categorias) com pelo menos 1 tarefa no período
    final temas = await database.rawQuery(
      '''SELECT COUNT(DISTINCT categoria_id) as total FROM tarefas
         WHERE data BETWEEN ? AND ?''',
      [inicio, fim],
    );
    final totalTemas = (temas.first['total'] as int?) ?? 0;

    return ResumoCard(
      tarefasConcluidas: tarefasConcluidas,
      metaSemanal: metaSemanal,
      horasEstudo: horasEstudo,
      totalTemas: totalTemas,
    );
  }

  // ─── gráfico de barras ───────────────────────────────────────────────────

  /// Tarefas concluídas por dia para o gráfico "Atividades da Semana".
  /// Sempre retorna os 7 dias da semana atual (Seg–Dom).
  Future<List<AtividadeDia>> getAtividadesSemana() async {
    final database = await db.database;
    final hoje = DateTime.now();
    final diasDesdeSegunda = (hoje.weekday - 1) % 7;
    final segunda = hoje.subtract(Duration(days: diasDesdeSegunda));

    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final resultado = <AtividadeDia>[];

    for (int i = 0; i < 7; i++) {
      final dia = segunda.add(Duration(days: i));
      final dataStr =
          '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';

      final rows = await database.rawQuery(
        '''SELECT COUNT(*) as total FROM tarefas
           WHERE concluida = 1 AND data = ?''',
        [dataStr],
      );
      resultado.add(AtividadeDia(
        diaSemana: labels[i],
        tarefasConcluidas: (rows.first['total'] as int?) ?? 0,
      ));
    }

    return resultado;
  }

  /// Versão mensal: retorna tarefas concluídas agrupadas por semana do mês.
  Future<List<AtividadeDia>> getAtividadesMes() async {
    final database = await db.database;
    final hoje = DateTime.now();
    final inicio = DateTime(hoje.year, hoje.month, 1);
    final fim = DateTime(hoje.year, hoje.month + 1, 0);

    final rows = await database.rawQuery(
      '''SELECT data, COUNT(*) as total FROM tarefas
         WHERE concluida = 1 AND data BETWEEN ? AND ?
         GROUP BY data
         ORDER BY data ASC''',
      [
        '${inicio.year}-${inicio.month.toString().padLeft(2, '0')}-01',
        '${fim.year}-${fim.month.toString().padLeft(2, '0')}-${fim.day.toString().padLeft(2, '0')}',
      ],
    );

    // Agrupa por semana (S1, S2, S3, S4)
    final semanas = {'S1': 0, 'S2': 0, 'S3': 0, 'S4': 0};
    for (final row in rows) {
      final dia = int.parse((row['data'] as String).split('-')[2]);
      final semana = 'S${((dia - 1) ~/ 7) + 1}';
      if (semanas.containsKey(semana)) {
        semanas[semana] = semanas[semana]! + (row['total'] as int);
      }
    }

    return semanas.entries
        .map((e) => AtividadeDia(diaSemana: e.key, tarefasConcluidas: e.value))
        .toList();
  }

  /// Versão anual: retorna tarefas concluídas agrupadas por mês.
  Future<List<AtividadeDia>> getAtividadesAno() async {
    final database = await db.database;
    final ano = DateTime.now().year;
    const meses = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];

    final rows = await database.rawQuery(
      '''SELECT strftime('%m', data) as mes, COUNT(*) as total
         FROM tarefas
         WHERE concluida = 1 AND strftime('%Y', data) = ?
         GROUP BY mes
         ORDER BY mes ASC''',
      [ano.toString()],
    );

    final mapaContagem = {
      for (final row in rows) row['mes'] as String: (row['total'] as int)
    };

    return List.generate(12, (i) {
      final mesStr = (i + 1).toString().padLeft(2, '0');
      return AtividadeDia(
        diaSemana: meses[i],
        tarefasConcluidas: mapaContagem[mesStr] ?? 0,
      );
    });
  }

  // ─── temas estudados ─────────────────────────────────────────────────────

  /// Lista de progresso por categoria para a seção "Temas Estudados".
  Future<List<ProgressoTema>> getProgressoPorTema(
      PeriodoDashboard periodo) async {
    final database = await db.database;
    final (inicio, fim) = _intervalo(periodo);

    final rows = await database.rawQuery(
      '''SELECT c.id, c.nome, c.cor,
                COUNT(t.id) as total,
                SUM(CASE WHEN t.concluida = 1 THEN 1 ELSE 0 END) as concluidas
         FROM categorias c
         LEFT JOIN tarefas t ON t.categoria_id = c.id
           AND t.data BETWEEN ? AND ?
         GROUP BY c.id
         ORDER BY c.nome ASC''',
      [inicio, fim],
    );

    return rows
        .where((row) => (row['total'] as int) > 0)
        .map((row) => ProgressoTema(
              categoriaId: row['id'] as int,
              nome: row['nome'] as String,
              cor: row['cor'] as String,
              totalTarefas: row['total'] as int,
              tarefasConcluidas: (row['concluidas'] as int?) ?? 0,
            ))
        .toList();
  }
}