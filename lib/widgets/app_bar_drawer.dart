import 'package:flutter/material.dart';
import 'package:swiftdo/l10n/app_localizations.dart';
import '../screens/configuracoes_screen.dart';

class SwiftDoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SwiftDoAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: const Text('SwiftDo'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Builder(
            builder: (ctx) => IconButton(
              tooltip: 'Perfil',
              icon: Icon(
                Icons.account_circle_outlined,
                size: 28,
                color: isDark ? Colors.white : const Color(0xFF2563EB),
              ),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ),
      ],
    );
  }
}

class SwiftDoDrawer extends StatelessWidget {
  const SwiftDoDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      width: 320,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHeader(
                    context,
                    l10n: l10n,
                    isDark: isDark,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_outlined,
                    label: l10n.configuracoes,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ConfiguracoesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline_rounded,
                    label: l10n.ajudaSuporte,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            _buildFooter(context, l10n: l10n, isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E3A8A).withValues(alpha: 0.45),
                  themeColorSurface(context),
                ]
              : [
                  const Color(0xFFEFF6FF),
                  const Color(0xFFF0F7FF),
                ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.25 : 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close_rounded, color: subTextColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${l10n.ola}, ${l10n.estudante}!',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'usuario@email.com',
            style: TextStyle(
              color: subTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color themeColorSurface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Widget _buildFooter(
    BuildContext context, {
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          Divider(
            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
            height: 24,
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
              label: Text(
                l10n.sairConta,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: isDark
                    ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                    : const Color(0xFFFEF2F2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2563EB),
            size: 22,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
          size: 18,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}
