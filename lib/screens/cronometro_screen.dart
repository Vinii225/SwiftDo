import 'dart:async';
import 'package:flutter/material.dart';
import 'package:swiftdo/l10n/app_localizations.dart';
import '../widgets/app_bar_drawer.dart';
import '../dao/configuracao_dao.dart';
import '../dao/sessao_dao.dart';
import '../models/sessao_foco.dart';

enum ModoTimer { foco, pausa }

class CronometroScreen extends StatefulWidget {
  const CronometroScreen({super.key});

  @override
  State<CronometroScreen> createState() => _CronometroScreenState();
}

class _CronometroScreenState extends State<CronometroScreen> {
  final _configDao = ConfiguracaoDao();
  final _sessaoDao = SessaoFocoDao();

  ModoTimer _modo = ModoTimer.foco;
  int _focoMin = 5;
  int _pausaMin = 1;
  int _segundosRestantes = 5 * 60;
  bool _rodando = false;
  Timer? _timer;

  final _ctrlFoco = TextEditingController();
  final _ctrlPausa = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarConfigs();
  }

  Future<void> _carregarConfigs() async {
    final foco = await _configDao.getFocoMin();
    final pausa = await _configDao.getPausaMin();
    setState(() {
      _focoMin = foco;
      _pausaMin = pausa;
      _segundosRestantes = foco * 60;
      _ctrlFoco.text = '$foco';
      _ctrlPausa.text = '$pausa';
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
    _timer?.cancel();
    setState(() {
      _modo = modo;
      _rodando = false;
      _segundosRestantes =
          modo == ModoTimer.foco ? _focoMin * 60 : _pausaMin * 60;
    });
  }

  Future<void> _salvarConfigs() async {
    final novoFoco = int.tryParse(_ctrlFoco.text) ?? _focoMin;
    final novaPausa = int.tryParse(_ctrlPausa.text) ?? _pausaMin;
    await _configDao.setFocoMin(novoFoco);
    await _configDao.setPausaMin(novaPausa);
    setState(() {
      _focoMin = novoFoco;
      _pausaMin = novaPausa;
      _segundosRestantes =
          _modo == ModoTimer.foco ? novoFoco * 60 : novaPausa * 60;
    });
  }

  String get _tempoFormatado {
    final min = _segundosRestantes ~/ 60;
    final seg = _segundosRestantes % 60;
    return '${min.toString().padLeft(2, '0')} : ${seg.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrlFoco.dispose();
    _ctrlPausa.dispose();
    super.dispose();
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
            _buildTimerCard(context),
            const SizedBox(height: 16),
            _buildConfigCard(context),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            // Ícone
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

            // Toggle Foco / Pausa
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModoBtn(l10n.foco, ModoTimer.foco),
                  const SizedBox(width: 4),
                  _buildModoBtn(l10n.tempoPausa, ModoTimer.pausa),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Timer
            Text(
              _tempoFormatado,
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _modo == ModoTimer.foco ? l10n.tempoFoco : l10n.tempoPausa,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: subTextColor),
            ),
            const SizedBox(height: 32),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play/Pause
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
                // Reset
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

  Widget _buildConfigCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.ajustarCronometro,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            const SizedBox(height: 20),
            _buildCampoConfig(context, '${l10n.tempoFoco} (minutos)', _ctrlFoco),
            const SizedBox(height: 16),
            _buildCampoConfig(context, '${l10n.tempoPausa} (minutos)', _ctrlPausa),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _salvarConfigs();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.aplicarAlteracoes)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 0,
                ),
                child: Text(l10n.aplicarAlteracoes,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoConfig(BuildContext context, String label, TextEditingController ctrl) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subTextColor)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
