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
  late DateTime _diaSelecionado;
  List<Tarefa> _tarefas = [];
  Map<int, Categoria> _categorias = {};
  int? _categoriaSelecionadaId;
  bool _carregandoCategorias = true;
  Set<int> _diasComTarefas = {};
  Set<int> _diasComConcluidas = {};

  final _tarefaDao = TarefaDao();
  final _categoriaDao = CategoriaDao();

  @override
  void initState() {
    super.initState();
    final hoje = DateTime.now();
    _diaSelecionado = DateTime(hoje.year, hoje.month, hoje.day);
    _carregarCategorias();
    _carregarTarefasMes();
  }

  Future<void> _carregarCategorias() async {
    if (!mounted) return;
    setState(() => _carregandoCategorias = true);

    try {
      await _categoriaDao.ensureDefaults();
      final lista = await _categoriaDao.findAll();
      if (!mounted) return;
      setState(() {
        _categorias = {for (final c in lista) c.id!: c};
        _categoriaSelecionadaId ??= lista.isNotEmpty ? lista.first.id : null;
        if (_categoriaSelecionadaId != null &&
            !_categorias.containsKey(_categoriaSelecionadaId)) {
          _categoriaSelecionadaId = lista.isNotEmpty ? lista.first.id : null;
        }
        _carregandoCategorias = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregandoCategorias = false);
    }
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

    if (!mounted) return;
    setState(() {
      _tarefas = doMes.where((t) {
        final data = DateTime.tryParse(t.data);
        return data?.day == _diaSelecionado.day;
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

  void _mudarMes(int delta) {
    final novoMes = DateTime(_mesSelecionado.year, _mesSelecionado.month + delta);
    final ultimoDia = DateTime(novoMes.year, novoMes.month + 1, 0).day;
    final dia = _diaSelecionado.day.clamp(1, ultimoDia);
    setState(() {
      _mesSelecionado = novoMes;
      _diaSelecionado = DateTime(novoMes.year, novoMes.month, dia);
    });
    _carregarTarefasMes();
  }

  String _dataSelecionadaStr() {
    return '${_diaSelecionado.year}-'
        '${_diaSelecionado.month.toString().padLeft(2, '0')}-'
        '${_diaSelecionado.day.toString().padLeft(2, '0')}';
  }

  Future<void> _deletarTarefa(int id) async {
    await _tarefaDao.delete(id);
    await _carregarTarefasMes();
  }

  Future<void> _alternarConcluida(Tarefa tarefa) async {
    await _tarefaDao.marcarConcluida(tarefa.id!, concluida: tarefa.concluida == 0);
    await _carregarTarefasMes();
  }

  Future<void> _abrirFormularioAtividade() async {
    final l10n = AppLocalizations.of(context)!;
    await _carregarCategorias();

    if (_categorias.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.erroCarregarDados)),
      );
      return;
    }

    if (_categoriaSelecionadaId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selecioneMateria)),
      );
      return;
    }

    if (!mounted) return;

    final tituloCtrl = TextEditingController();
    var categoriaId = _categoriaSelecionadaId!;

    final salvo = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
            final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

            Future<void> salvar() async {
              if (tituloCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  SnackBar(content: Text(l10n.campoObrigatorio)),
                );
                return;
              }

              await _tarefaDao.insert(Tarefa(
                titulo: tituloCtrl.text.trim(),
                categoriaId: categoriaId,
                data: _dataSelecionadaStr(),
              ));

              if (sheetContext.mounted) Navigator.pop(sheetContext, true);
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        l10n.novaAtividade,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_diaSelecionado.day.toString().padLeft(2, '0')}/'
                        '${_diaSelecionado.month.toString().padLeft(2, '0')}/'
                        '${_diaSelecionado.year}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.tituloAtividade,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: tituloCtrl,
                        autofocus: true,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Ex: Revisar capítulo 3',
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.materia,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categorias.values.map((categoria) {
                          final cor = Color(
                            int.parse(categoria.cor.replaceFirst('#', '0xFF')),
                          );
                          final selecionada = categoriaId == categoria.id;
                          return GestureDetector(
                            onTap: () {
                              setSheetState(() => categoriaId = categoria.id!);
                              setState(() => _categoriaSelecionadaId = categoria.id);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selecionada
                                    ? cor.withValues(alpha: 0.15)
                                    : isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selecionada
                                      ? cor
                                      : isDark
                                          ? Colors.white10
                                          : const Color(0xFFE2E8F0),
                                  width: selecionada ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: cor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    categoria.nome,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: selecionada
                                          ? cor
                                          : isDark
                                              ? Colors.white70
                                              : const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetContext, false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(l10n.cancelar),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: salvar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.salvar,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    tituloCtrl.dispose();
    if (salvo == true) {
      await _carregarTarefasMes();
    }
  }

  String _formatarData(String data) {
    final d = DateTime.tryParse(data);
    if (d == null) return data;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const SwiftDoAppBar(),
      endDrawer: const SwiftDoDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioAtividade,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.adicionarAtividade),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalendario(context),
            const SizedBox(height: 16),
            _buildMaterias(context),
            const SizedBox(height: 16),
            _buildListaTarefas(context),
            const SizedBox(height: 80),
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
    final offsetInicio = primeiroDia.weekday % 7;

    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF2563EB)),
                  onPressed: () => _mudarMes(-1),
                ),
                Text(
                  '${meses[_mesSelecionado.month - 1]} ${_mesSelecionado.year}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF2563EB)),
                  onPressed: () => _mudarMes(1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: offsetInicio + ultimoDia.day,
              itemBuilder: (context, index) {
                if (index < offsetInicio) return const SizedBox();
                final dia = index - offsetInicio + 1;
                final hoje = DateTime.now();
                final isHoje = hoje.year == _mesSelecionado.year &&
                    hoje.month == _mesSelecionado.month &&
                    hoje.day == dia;
                final isSelecionado = _diaSelecionado.day == dia &&
                    _diaSelecionado.month == _mesSelecionado.month &&
                    _diaSelecionado.year == _mesSelecionado.year;
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
                          boxShadow: isSelecionado
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
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
                                      : isDark
                                          ? Colors.white70
                                          : const Color(0xFF475569),
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

  Widget _buildMaterias(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.materiasDisponiveis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.selecioneMateriaPadrao,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subTextColor,
              ),
            ),
            const SizedBox(height: 14),
            if (_carregandoCategorias)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.carregandoMaterias,
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  ],
                ),
              )
            else if (_categorias.isEmpty)
              Text(
                l10n.erroCarregarDados,
                style: TextStyle(color: subTextColor, fontSize: 13),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categorias.values.map((categoria) {
                  final cor = Color(
                    int.parse(categoria.cor.replaceFirst('#', '0xFF')),
                  );
                  final selecionada = _categoriaSelecionadaId == categoria.id;
                  return GestureDetector(
                    onTap: () => setState(() => _categoriaSelecionadaId = categoria.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selecionada
                            ? cor.withValues(alpha: 0.15)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selecionada
                              ? cor
                              : isDark
                                  ? Colors.white10
                                  : const Color(0xFFE2E8F0),
                          width: selecionada ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            categoria.nome,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selecionada
                                  ? cor
                                  : isDark
                                      ? Colors.white70
                                      : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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

    final titulo =
        '${l10n.atividadesMes} - ${_diaSelecionado.day.toString().padLeft(2, '0')}/'
        '${_diaSelecionado.month.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            if (_tarefas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 40,
                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.nenhumaAtividade,
                        style: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.adicionarPrimeiraAtividade,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _abrirFormularioAtividade,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(l10n.adicionarAtividade),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
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
    final concluida = tarefa.concluida == 1;

    final categoria = _categorias[tarefa.categoriaId];
    final cor = categoria != null
        ? Color(int.parse(categoria.cor.replaceFirst('#', '0xFF')))
        : const Color(0xFF94A3B8);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: concluida,
            activeColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            onChanged: (_) => _alternarConcluida(tarefa),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tarefa.titulo,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    decoration: concluida ? TextDecoration.lineThrough : null,
                    decorationColor: subTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${categoria?.nome ?? ''} • ${_formatarData(tarefa.data)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
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
