import 'package:flutter/material.dart';
import 'package:swiftdo/l10n/app_localizations.dart';
import '../widgets/app_bar_drawer.dart';
import '../models/tarefa.dart';
import '../models/categoria.dart';
import '../dao/tarefa_dao.dart';
import '../dao/categoria_dao.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _mesSelecionado = DateTime.now();
  DateTime? _diaSelecionado;
  List<Tarefa> _tarefas = [];
  Map<int, Categoria> _categorias = {};
  // Dias do mês que têm tarefas (para os indicadores)
  Set<int> _diasComTarefas = {};
  Set<int> _diasComConcluidas = {};

  final _tarefaDao = TarefaDao();
  final _categoriaDao = CategoriaDao();

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
    _carregarTarefasMes();
  }

  Future<void> _carregarCategorias() async {
    final lista = await _categoriaDao.findAll();
    setState(() {
      _categorias = {for (final c in lista) c.id!: c};
    });
  }

  Future<void> _carregarTarefasMes() async {
    final todas = await _tarefaDao.findAll();
    final mes = _mesSelecionado;

    final doMes = todas.where((t) {
      final data = DateTime.tryParse(t.data);
      return data != null && data.year == mes.year && data.month == mes.month;
    }).toList();

    final comTarefas = <int>{};
    final comConcluidas = <int>{};
    for (final t in doMes) {
      final dia = DateTime.tryParse(t.data)?.day;
      if (dia != null) {
        comTarefas.add(dia);
        if (t.concluida == 1) comConcluidas.add(dia);
      }
    }

    setState(() {
      _tarefas = _diaSelecionado == null
          ? doMes
          : doMes.where((t) {
              final data = DateTime.tryParse(t.data);
              return data?.day == _diaSelecionado?.day;
            }).toList();
      _diasComTarefas = comTarefas;
      _diasComConcluidas = comConcluidas;
    });
  }

  void _selecionarDia(int dia) {
    setState(() {
      _diaSelecionado = DateTime(_mesSelecionado.year, _mesSelecionado.month, dia);
    });
    _carregarTarefasMes();
  }

  Future<void> _deletarTarefa(int id) async {
    await _tarefaDao.delete(id);
    await _carregarTarefasMes();
  }

  String _formatarData(String data) {
    final d = DateTime.tryParse(data);
    if (d == null) return data;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SwiftDoAppBar(),
      endDrawer: const SwiftDoDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalendario(context),
            const SizedBox(height: 16),
            _buildListaTarefas(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendario(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    final primeiroDia = DateTime(_mesSelecionado.year, _mesSelecionado.month, 1);
    final ultimoDia = DateTime(_mesSelecionado.year, _mesSelecionado.month + 1, 0);
    // 0=Dom, 1=Seg ... ajustar para iniciar em Dom
    final offsetInicio = primeiroDia.weekday % 7;

    final meses = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho',
                   'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header do mês
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF2563EB)),
                  onPressed: () {
                    setState(() {
                      _mesSelecionado = DateTime(
                          _mesSelecionado.year, _mesSelecionado.month - 1);
                      _diaSelecionado = null;
                    });
                    _carregarTarefasMes();
                  },
                ),
                Text(
                  '${meses[_mesSelecionado.month - 1]} ${_mesSelecionado.year}',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800,
                      color: textColor),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF2563EB)),
                  onPressed: () {
                    setState(() {
                      _mesSelecionado = DateTime(
                          _mesSelecionado.year, _mesSelecionado.month + 1);
                      _diaSelecionado = null;
                    });
                    _carregarTarefasMes();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Labels dos dias
            Row(
              children: ['Dom','Seg','Ter','Qua','Qui','Sex','Sáb']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Grid de dias
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, childAspectRatio: 1),
              itemCount: offsetInicio + ultimoDia.day,
              itemBuilder: (context, index) {
                if (index < offsetInicio) return const SizedBox();
                final dia = index - offsetInicio + 1;
                final hoje = DateTime.now();
                final isHoje = hoje.year == _mesSelecionado.year &&
                    hoje.month == _mesSelecionado.month &&
                    hoje.day == dia;
                final isSelecionado = _diaSelecionado?.day == dia &&
                    _diaSelecionado?.month == _mesSelecionado.month;
                final temTarefa = _diasComTarefas.contains(dia);
                final temConcluida = _diasComConcluidas.contains(dia);

                return GestureDetector(
                  onTap: () => _selecionarDia(dia),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelecionado
                              ? const Color(0xFF2563EB)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelecionado ? [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ] : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dia',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isHoje || isSelecionado
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isSelecionado
                                  ? Colors.white
                                  : isHoje
                                      ? const Color(0xFF2563EB)
                                      : isDark ? Colors.white70 : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                      if (temTarefa)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: temConcluida
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF87171),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaTarefas(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final l10n = AppLocalizations.of(context)!;

    final titulo = _diaSelecionado == null
        ? l10n.atividadesMes
        : '${l10n.atividadesMes} - ${_diaSelecionado!.day.toString().padLeft(2, '0')}/${_diaSelecionado!.month.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor)),
            const SizedBox(height: 16),
            if (_tarefas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(l10n.nenhumaAtividade,
                      style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                ),
              )
            else
              ...(_tarefas.map((t) => _buildTarefaItem(context, t))),
          ],
        ),
      ),
    );
  }

  Widget _buildTarefaItem(BuildContext context, Tarefa tarefa) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    final categoria = _categorias[tarefa.categoriaId];
    final cor = categoria != null
        ? Color(int.parse(categoria.cor.replaceFirst('#', '0xFF')))
        : const Color(0xFF94A3B8);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tarefa.titulo,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: textColor)),
                const SizedBox(height: 4),
                Text(
                  '${categoria?.nome ?? ''} • ${_formatarData(tarefa.data)}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: subTextColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20),
            onPressed: () => _deletarTarefa(tarefa.id!),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
