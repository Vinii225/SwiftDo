import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:swiftdo/l10n/app_localizations.dart';
import 'db/database_helper.dart';
import 'db/database_init.dart';
import 'screens/agenda_screen.dart';
import 'screens/cronometro_screen.dart';
import 'screens/dashboard_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? dbInitError;
  try {
    await initDatabase();
    await DatabaseHelper.instance.database;
  } catch (e) {
    dbInitError = e.toString();
    debugPrint('Erro ao iniciar banco: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: SwiftDoApp(dbInitError: dbInitError),
    ),
  );
}

class SwiftDoApp extends StatelessWidget {
  const SwiftDoApp({super.key, this.dbInitError});

  final String? dbInitError;

  @override
  Widget build(BuildContext context) {
    if (dbInitError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFF0F7FF),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'SwiftDo',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Não foi possível iniciar o banco de dados local.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dbInitError!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await DatabaseHelper.instance.reset();
                      } catch (_) {}
                      // ignore: use_build_context_synchronously
                      if (context.mounted) {
                        await main();
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'SwiftDo',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'),
        Locale('en'),
        Locale('es'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F7FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
          surface: Colors.black,
          onSurface: Colors.white,
          primary: const Color(0xFF2563EB),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Color(0xFF2563EB),
          unselectedItemColor: Color(0xFF94A3B8),
          elevation: 0,
        ),
      ),
      home: Builder(
        builder: (context) {
          // Force re-evaluation of AppLocalizations.of(context)
          return const MainNavigation();
        },
      ),
    );
  }
}


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AgendaScreen(),
    CronometroScreen(),
    DashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today_outlined, size: 22),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.calendar_today, size: 22),
              ),
              label: l10n.agenda,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.timer_outlined, size: 22),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.timer, size: 22),
              ),
              label: l10n.foco,
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.bar_chart_outlined, size: 22),
              ),
              activeIcon: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.bar_chart, size: 22),
              ),
              label: l10n.dados,
            ),
          ],
        ),
      ),
    );
  }
}
