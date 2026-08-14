import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('opens the fixed-column example', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Fixed columns'), findsOneWidget);
    expect(find.text('Responsive extent'), findsOneWidget);
    expect(find.text('Custom scroll view'), findsOneWidget);

    await tester.tap(find.text('Fixed columns'));
    await tester.pumpAndSettle();

    expect(
      find.text('Three tiles per row, each row aligned to its tallest tile.'),
      findsOneWidget,
    );
    expect(find.text('Longer content'), findsOneWidget);
  });

  testWidgets('lays out the large data set without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(414, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LargeDataSetExamplePage()));

    expect(find.text('Quick update 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
