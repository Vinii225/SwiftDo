import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/screens/agenda_screen.dart';

import '../helpers/pump_app.dart';
import '../helpers/test_database.dart';

void main() {
  setUp(() async => setupTestDatabase());
  tearDown(() async => teardownTestDatabase());

  testWidgets('renderiza estrutura principal', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpLocalizedApp(tester, const AgendaScreen());
    await tester.pump();

    expect(find.text('SwiftDo'), findsOneWidget);
    expect(find.text('Matérias disponíveis'), findsOneWidget);
    expect(find.byKey(const Key('agenda-fab')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
