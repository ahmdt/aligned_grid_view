import 'package:aligned_grid_view/aligned_grid_view.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aligns tiles in each row and applies spacing', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          itemCount: 3,
          itemBuilder: (context, index) =>
              SizedBox(key: ValueKey(index), height: index == 1 ? 80 : 40),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(395, 80));
    expect(tester.getSize(find.byKey(const ValueKey(1))), const Size(395, 80));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(1))),
      const Offset(405, 0),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))),
      const Offset(0, 100),
    );
  });

  testWidgets('lays out SliverAlignedGrid in a CustomScrollView', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CustomScrollView(
          slivers: [
            SliverAlignedGrid.count(
              crossAxisCount: 2,
              itemCount: 2,
              itemBuilder: (context, index) =>
                  SizedBox(key: ValueKey(index), height: 24.0 + index),
            ),
          ],
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(400, 25));
    expect(tester.getSize(find.byKey(const ValueKey(1))), const Size(400, 25));
  });

  testWidgets('uses fixed-extent rows when the row extent is known', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          mainAxisExtent: 80,
          itemCount: 3,
          itemBuilder: (context, index) => SizedBox(
            key: ValueKey(index),
            height: 20.0 + index,
          ),
        ),
      ),
    );

    expect(find.byType(SliverFixedExtentList), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(395, 80));
    expect(tester.getSize(find.byKey(const ValueKey(1))), const Size(395, 80));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))),
      const Offset(0, 100),
    );
  });

  testWidgets('uses max cross-axis extent to select columns', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.extent(
          maxCrossAxisExtent: 300,
          itemCount: 3,
          itemBuilder: (context, index) =>
              SizedBox(key: ValueKey(index), height: 30),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey(0))),
      const Size(800 / 3, 30),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))),
      const Offset(1600 / 3, 0),
    );
  });
}
