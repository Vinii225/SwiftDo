import 'package:flutter/material.dart';
import 'package:swiftdo/l10n/app_localizations.dart';
import '../widgets/app_bar_drawer.dart';
import '../dao/dashboard_dao.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dao = DashboardDao();
  PeriodoDashboard _periodo = PeriodoDashboard.semana;
  ResumoCard? _resumo;
  List<AtividadeDia> _atividades = [];
  List<ProgressoTema> _temas = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    if (!mounted) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final resumo = await _dao.getResumo(_periodo);
      final temas = await _dao.getProgressoPorTema(_periodo);
      List<AtividadeDia> atividades;
      switch (_periodo) {
        case PeriodoDashboard.semana:
          atividades = await _dao.getAtividadesSemana();
          break;
        case PeriodoDashboard.mes:
          atividades = await _dao.getAtividadesMes();
          break;
        case PeriodoDashboard.ano:
          atividades = await _dao.getAtividadesAno();
          break;
      }
      if (!mounted) return;
      setState(() {
        _resumo = resumo;
        _atividades = atividades;
        _temas = temas;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _carregando = false;
        _erro = AppLocalizations.of(context)!.erroCarregarDados;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: const SwiftDoAppBar(),
      endDrawer: const SwiftDoDrawer(),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? _buildErro(context)
              : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.minhaEvolucao,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor)),
                  Text(l10n.acompanheDesempenho,
                      style: TextStyle(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  _buildFiltro(context),
                  const SizedBox(height: 16),
                  _buildCards(context),
                  const SizedBox(height: 16),
                  _buildGrafico(context),
                  const SizedBox(height: 16),
                  _buildTemas(context),
                ],
              ),
            ),
    );
  }

  Widget _buildErro(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_rounded,
              size: 48,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.erroBancoLocalTitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.erroBancoLocalDetalhe,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.tentarNovamente),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltro(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            _buildFiltroBtn(context, l10n.semana, PeriodoDashboard.semana),
            _buildFiltroBtn(context, l10n.mes, PeriodoDashboard.mes),
            _buildFiltroBtn(context, l10n.ano, PeriodoDashboard.ano),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltroBtn(BuildContext context, String label, PeriodoDashboard p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final ativo = _periodo == p;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _periodo = p);
          _carregar();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: ativo ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ativo ? Colors.white : subTextColor,
                )),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context) {
    if (_resumo == null) return const SizedBox();
    final l10n = AppLocalizations.of(context)!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildCard(
          context,
          icon: Icons.emoji_events_rounded,
          iconBg: const Color(0xFF10B981),
          valor: '${_resumo!.tarefasConcluidas}',
          label: l10n.concluidas,
        ),
        _buildCard(
          context,
          icon: Icons.track_changes_rounded,
          iconBg: const Color(0xFF2563EB),
          valor: '${_resumo!.metaSemanal}',
          label: l10n.metaSemanal,
        ),
        _buildCard(
          context,
          icon: Icons.timer_rounded,
          iconBg: const Color(0xFFF59E0B),
          valor: '${_resumo!.horasEstudo}h',
          label: l10n.tempoFoco,
        ),
        _buildCard(
          context,
          icon: Icons.auto_stories_rounded,
          iconBg: const Color(0xFF8B5CF6),
          valor: '${_resumo!.totalTemas}',
          label: l10n.materias,
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required String valor,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration:
                  BoxDecoration(color: iconBg.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconBg, size: 20),
            ),
            const Spacer(),
            Text(valor,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor)),
            Text(label,
                style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildGrafico(BuildContext context) {
    if (_atividades.isEmpty) return const SizedBox();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final l10n = AppLocalizations.of(context)!;

    final maxVal = _atividades.map((a) => a.tarefasConcluidas).fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.atividadeRecente,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _atividades.map((a) {
                  final pct = maxVal == 0 ? 0.0 : a.tarefasConcluidas / maxVal;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: 120 * pct + (pct > 0 ? 8 : 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: pct > 0.5 ? 1 : 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(a.diaSemana,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.white38 : const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemas(BuildContext context) {
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
            Text(l10n.temasMaterias,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            const SizedBox(height: 16),
            if (_temas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        size: 36,
                        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.dadosVaziosTitulo,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.dadosVaziosDetalhe,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._temas.map((t) {
                final cor = Color(int.parse(t.cor.replaceFirst('#', '0xFF')));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.nome,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : const Color(0xFF334155))),
                          Text('${(t.percentual * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: subTextColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: t.percentual,
                          minHeight: 8,
                          backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(cor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
