import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdo/widgets/app_bar_drawer.dart';

void main() {
  testWidgets('SwiftDoAppBar exibe título', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: SwiftDoAppBar()),
      ),
    );

    expect(find.text('SwiftDo'), findsOneWidget);
    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
  });
}
