import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/widgets/database_error_screen.dart';

void main() {
  testWidgets('mostra mensagem de erro e botão de retry', (tester) async {
    var retryCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: DatabaseErrorScreen(
          erro: 'falha de teste',
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(find.text('SwiftDo'), findsOneWidget);
    expect(find.text('falha de teste'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();

    expect(retryCount, 1);
  });
}
