import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:swiftdo/db/database_init.dart';
import 'package:swiftdo/main.dart';
import 'package:swiftdo/providers/locale_provider.dart';
import 'package:swiftdo/providers/theme_provider.dart';

void main() {
  setUpAll(() async {
    await initDatabase();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ],
        child: const SwiftDoApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SwiftDo'), findsOneWidget);
  });
}
