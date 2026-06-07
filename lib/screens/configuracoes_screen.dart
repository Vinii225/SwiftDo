import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swiftdo/l10n/app_localizations.dart';
import '../dao/configuracao_dao.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  final _dao = ConfiguracaoDao();

  bool _notificacoes = true;
  bool _somCronometro = true;
  int _metaDiaria = 5;
  int _metaSemanal = 35;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final notif = await _dao.getNotificacoes();
    final som = await _dao.getSomCronometro();
    final diaria = await _dao.getMetaDiaria();
    final semanal = await _dao.getMetaSemanal();
    setState(() {
      _notificacoes = notif;
      _somCronometro = som;
      _metaDiaria = diaria;
      _metaSemanal = semanal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    String languageName = l10n.portugues;
    if (localeProvider.locale.languageCode == 'en') languageName = l10n.ingles;
    if (localeProvider.locale.languageCode == 'es') languageName = l10n.espanhol;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.configuracoes,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            Text(l10n.acompanheDesempenho,
                style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSecao(context, l10n.interface, [
              _buildItemSwitch(
                context,
                icon: Icons.dark_mode_outlined,
                titulo: l10n.temaEscuro,
                subtitulo: l10n.ajustarBrilho,
                valor: themeProvider.isDarkMode,
                onChanged: (v) => themeProvider.toggleTheme(v),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSecao(context, l10n.notificacoesSons, [
              _buildItemSwitch(
                context,
                icon: Icons.notifications_none_rounded,
                titulo: l10n.lembretesTarefas,
                subtitulo: l10n.alertasPrazos,
                valor: _notificacoes,
                onChanged: (v) async {
                  await _dao.setNotificacoes(v);
                  setState(() => _notificacoes = v);
                },
              ),
              _buildItemSwitch(
                context,
                icon: Icons.volume_up_outlined,
                titulo: l10n.somCronometro,
                subtitulo: l10n.feedbackSonoro,
                valor: _somCronometro,
                onChanged: (v) async {
                  await _dao.setSomCronometro(v);
                  setState(() => _somCronometro = v);
                },
              ),
              if (_somCronometro) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.toqueAlerta,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: subTextColor)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? theme.colorScheme.surface.withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
                          border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Text(l10n.sinoPadrao,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                            const Spacer(),
                            Icon(Icons.keyboard_arrow_down_rounded, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ]),
            const SizedBox(height: 24),
            _buildSecao(context, l10n.metasDiarias, [
              _buildItemSlider(
                context,
                icon: Icons.track_changes_rounded,
                titulo: l10n.objetivoTarefas,
                valor: _metaDiaria.toDouble(),
                min: 1,
                max: 20,
                label: '$_metaDiaria tarefas',
                onChanged: (v) => setState(() => _metaDiaria = v.round()),
                onChangeEnd: (v) => _dao.setMetaDiaria(v.round()),
              ),
              _buildItemSlider(
                context,
                icon: Icons.calendar_today_rounded,
                titulo: l10n.metaSemana,
                valor: _metaSemanal.toDouble(),
                min: 5,
                max: 100,
                label: '$_metaSemanal tarefas',
                onChanged: (v) => setState(() => _metaSemanal = v.round()),
                onChangeEnd: (v) => _dao.setMetaSemanal(v.round()),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSecao(context, l10n.sistema, [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.language_rounded,
                      color: Color(0xFF2563EB), size: 20),
                ),
                title: Text(l10n.idiomaApp,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
                subtitle: Text(languageName,
                    style:
                        TextStyle(fontSize: 12, color: subTextColor)),
                trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onTap: () => _mostrarDialogoIdioma(context),
              ),
            ]),
            const SizedBox(height: 32),
            // Zona de Perigo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF450a0a) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF7f1d1d) : const Color(0xFFFEE2E2), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.contaDados,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFfecaca) : const Color(0xFF991B1B))),
                  const SizedBox(height: 4),
                  Text(l10n.acoesPermanentes,
                      style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFf87171) : const Color(0xFFB91C1C))),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _confirmarDesativar(context),
                      icon: const Icon(Icons.delete_sweep_outlined,
                          color: Color(0xFFDC2626), size: 20),
                      label: Text(l10n.desativarConta,
                          style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w700)),
                      style: TextButton.styleFrom(
                        backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ? const Color(0xFF7f1d1d) : const Color(0xFFFEE2E2))),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoIdioma(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.idiomaApp),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.portugues),
              onTap: () {
                localeProvider.setLocale(const Locale('pt'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(l10n.ingles),
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: Text(l10n.espanhol),
              onTap: () {
                localeProvider.setLocale(const Locale('es'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecao(BuildContext context, String titulo, List<Widget> filhos) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(titulo.toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            boxShadow: isDark ? [] : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: filhos),
        ),
      ],
    );
  }

  Widget _buildItemSwitch(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: SwitchListTile(
        value: valor,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF2563EB),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        title: Text(titulo,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
        subtitle: Text(subtitulo,
            style: TextStyle(
                fontSize: 12, color: subTextColor)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  Widget _buildItemSlider(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required double valor,
    required double min,
    required double max,
    required String label,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(titulo,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
              ),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: valor,
              min: min,
              max: max,
              activeColor: const Color(0xFF2563EB),
              inactiveColor: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarDesativar(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.desativarConta),
        content: const Text(
            'Tem certeza que deseja desativar sua conta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.desativarConta,
                style: const TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // TODO: implementar desativação de conta
    }
  }
}
