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
}
