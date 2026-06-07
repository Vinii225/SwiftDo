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
              icon: Icon(Icons.person_pin_rounded, size: 28, color: isDark ? Colors.white : const Color(0xFF1E293B)),
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
      child: Column(
        children: [
          // Header minimalista
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF0F7FF),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isDark ? [] : [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 32),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: subTextColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('${l10n.ola}, ${l10n.estudante}!',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const Text('usuario@email.com',
                    style: TextStyle(
                        color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Menu Items
          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            label: l10n.configuracoes,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ConfiguracoesScreen()));
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.help_outline_rounded,
            label: l10n.ajudaSuporte,
            onTap: () {},
          ),

          const Spacer(),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Divider(color: isDark ? Colors.white10 : const Color(0xFFF1F5F9), height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                    label: Text(l10n.sairConta,
                        style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      backgroundColor: isDark ? const Color(0xFFDC2626).withValues(alpha: 0.1) : const Color(0xFFFEF2F2),
                    ),
                  ),
                ),
              ],
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
        leading: Icon(icon, color: isDark ? Colors.white70 : const Color(0xFF64748B), size: 22),
        title: Text(label,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B))),
        trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white24 : const Color(0xFFCBD5E1), size: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onTap: onTap,
      ),
    );
  }
}
