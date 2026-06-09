import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:swiftdo/l10n/app_localizations.dart';
import '../widgets/app_bar_drawer.dart';
import '../dao/configuracao_dao.dart';
import '../dao/sessao_dao.dart';
import '../models/sessao_foco.dart';

enum ModoTimer { foco, pausa }

class _TimerPreset {
  const _TimerPreset({required this.foco, required this.pausa});

  final int foco;
  final int pausa;
}

const _presets = [
  _TimerPreset(foco: 25, pausa: 5),
  _TimerPreset(foco: 15, pausa: 3),
  _TimerPreset(foco: 50, pausa: 10),
];

class CronometroScreen extends StatefulWidget {
  const CronometroScreen({super.key});

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> {
  final _configDao = ConfiguracaoDao();
  final _sessaoDao = SessaoFocoDao();

  ModoTimer _modo = ModoTimer.foco;
  int _focoMin = 25;
  int _pausaMin = 5;
  int _segundosRestantes = 25 * 60;
  bool _rodando = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _carregarConfigs();
  }

  Future<void> _carregarConfigs() async {
    final foco = await _configDao.getFocoMin();
    final pausa = await _configDao.getPausaMin();
    if (!mounted) return;
    setState(() {
      _focoMin = foco;
      _pausaMin = pausa;
      _segundosRestantes = foco * 60;
    });
  }

  void _iniciarPausar() {
    if (_rodando) {
      _timer?.cancel();
      setState(() => _rodando = false);
    } else {
      setState(() => _rodando = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_segundosRestantes > 0) {
          setState(() => _segundosRestantes--);
        } else {
          _concluirSessao();
        }
      });
    }
  }

  Future<void> _concluirSessao() async {
    _timer?.cancel();
    setState(() => _rodando = false);

    if (_modo == ModoTimer.foco) {
      final hoje = DateTime.now();
      final dataStr =
          '${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}';
      await _sessaoDao.insert(SessaoFoco(
        duracaoMin: _focoMin,
        data: dataStr,
      ));
    }

    _resetar();
  }

  void _resetar() {
    _timer?.cancel();
    setState(() {
      _rodando = false;
      _segundosRestantes =
          _modo == ModoTimer.foco ? _focoMin * 60 : _pausaMin * 60;
    });
  }

  void _trocarModo(ModoTimer modo) {
    if (_rodando) return;
    _timer?.cancel();
    setState(() {
      _modo = modo;
      _rodando = false;
      _segundosRestantes =
          modo == ModoTimer.foco ? _focoMin * 60 : _pausaMin * 60;
    });
  }

  Future<void> _salvarConfigs(int novoFoco, int novaPausa) async {
    await _configDao.setFocoMin(novoFoco);
    await _configDao.setPausaMin(novaPausa);
    if (!mounted) return;
    setState(() {
      _focoMin = novoFoco;
      _pausaMin = novaPausa;
      if (!_rodando) {
        _segundosRestantes =
            _modo == ModoTimer.foco ? novoFoco * 60 : novaPausa * 60;
      }
    });
  }

  void _abrirEditorTempos() {
    final l10n = AppLocalizations.of(context)!;
    if (_rodando) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pauseParaEditar)),
      );
      return;
    }

    var draftFoco = _focoMin;
    var draftPausa = _pausaMin;

    showModalBottomSheet<void>(
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

            int? presetAtivo() {
              for (final preset in _presets) {
                if (preset.foco == draftFoco && preset.pausa == draftPausa) {
                  return _presets.indexOf(preset);
                }
              }
              return null;
            }

            void aplicarPreset(_TimerPreset preset) {
              HapticFeedback.lightImpact();
              setSheetState(() {
                draftFoco = preset.foco;
                draftPausa = preset.pausa;
              });
            }

            Future<void> confirmar() async {
              await _salvarConfigs(draftFoco, draftPausa);
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (mounted) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(l10n.temposAtualizados)),
                );
              }
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
                        l10n.ajustarCronometro,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.editarTempos,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.presets.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: subTextColor,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPresetChip(
                            label: '${l10n.presetPomodoro} · 25/5',
                            selected: presetAtivo() == 0,
                            onTap: () => aplicarPreset(_presets[0]),
                          ),
                          _buildPresetChip(
                            label: '${l10n.presetCurto} · 15/3',
                            selected: presetAtivo() == 1,
                            onTap: () => aplicarPreset(_presets[1]),
                          ),
                          _buildPresetChip(
                            label: '${l10n.presetLongo} · 50/10',
                            selected: presetAtivo() == 2,
                            onTap: () => aplicarPreset(_presets[2]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildStepperRow(
                        label: l10n.tempoFoco,
                        value: draftFoco,
                        min: 1,
                        max: 120,
                        onChanged: (v) => setSheetState(() => draftFoco = v),
                      ),
                      const SizedBox(height: 16),
                      _buildStepperRow(
                        label: l10n.tempoPausa,
                        value: draftPausa,
                        min: 1,
                        max: 30,
                        onChanged: (v) => setSheetState(() => draftPausa = v),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: confirmar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.aplicarAlteracoes,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
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
  }

  String get _tempoFormatado {
    final min = _segundosRestantes ~/ 60;
    final seg = _segundosRestantes % 60;
    return '${min.toString().padLeft(2, '0')} : ${seg.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SwiftDoAppBar(),
      endDrawer: const SwiftDoDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildTimerCard(context),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: l10n.editarTempos,
                  onPressed: _abrirEditorTempos,
                  icon: Icon(
                    Icons.tune_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.timer_rounded, color: Color(0xFF2563EB), size: 32),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModoBtn(l10n.foco, ModoTimer.foco),
                    const SizedBox(width: 4),
                    _buildModoBtn(l10n.tempoPausa, ModoTimer.pausa),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _tempoFormatado,
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _modo == ModoTimer.foco ? l10n.tempoFoco : l10n.tempoPausa,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: subTextColor),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _abrirEditorTempos,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDuracaoPill(
                      icon: Icons.bolt_rounded,
                      label: '$_focoMin ${l10n.minutos}',
                      ativo: _modo == ModoTimer.foco,
                    ),
                    _buildDuracaoPill(
                      icon: Icons.coffee_rounded,
                      label: '$_pausaMin ${l10n.minutos}',
                      ativo: _modo == ModoTimer.pausa,
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _iniciarPausar,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      _rodando ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: _resetar,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.refresh_rounded,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B), size: 28),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuracaoPill({
    required IconData icon,
    required String label,
    required bool ativo,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: ativo ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: ativo ? FontWeight.w700 : FontWeight.w500,
            color: ativo ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildModoBtn(String label, ModoTimer modo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    final ativo = _modo == modo;
    return GestureDetector(
      onTap: () => _trocarModo(modo),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: ativo ? const Color(0xFF2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ativo ? Colors.white : subTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2563EB)
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF2563EB)
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white10
                    : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected
                ? Colors.white
                : Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    void alterar(int delta) {
      final novo = (value + delta).clamp(min, max);
      if (novo != value) {
        HapticFeedback.selectionClick();
        onChanged(novo);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: subTextColor,
              ),
            ),
          ),
          _buildStepperBtn(Icons.remove_rounded, () => alterar(-1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$value ${AppLocalizations.of(context)!.minutos}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
          _buildStepperBtn(Icons.add_rounded, () => alterar(1)),
        ],
      ),
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        ),
      ),
    );
  }
}
