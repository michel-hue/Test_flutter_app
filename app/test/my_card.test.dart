import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('MyCard ressemble à la référence', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: MyCard(titre: 'Bonjour')),
        ),
      ),
    );

    await expectLater(
      find.byType(MyCard),
      matchesGoldenFile('goldens/my_card.png'),
    );
  });
}