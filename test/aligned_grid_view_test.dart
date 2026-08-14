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
          itemBuilder: (context, index) =>
              SizedBox(key: ValueKey(index), height: 20.0 + index),
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

  testWidgets('does not rebuild tracks for scroll-only constraint changes', (
    tester,
  ) async {
    var buildCount = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          itemCount: 2,
          itemBuilder: (context, index) {
            buildCount++;
            return const SizedBox(height: 2000);
          },
        ),
      ),
    );
    expect(buildCount, 2);

    await tester.drag(find.byType(AlignedGridView), const Offset(0, -10));
    await tester.pump();

    expect(buildCount, 2);
  });

  testWidgets('uses one sliver child per row', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          itemCount: 3,
          itemBuilder: (context, index) => const SizedBox(height: 40),
        ),
      ),
    );

    final sliverList = tester.widget<SliverList>(find.byType(SliverList));
    expect(sliverList.delegate.estimatedChildCount, 2);
  });

  testWidgets('includes row spacing in horizontal grids', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.horizontal,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          itemCount: 3,
          itemBuilder: (context, index) =>
              SizedBox(key: ValueKey(index), width: index == 1 ? 80 : 40),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(80, 295));
    expect(tester.getSize(find.byKey(const ValueKey(1))), const Size(80, 295));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(1))),
      const Offset(0, 305),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))),
      const Offset(100, 0),
    );
  });

  testWidgets('uses varied-extent rows when row extents are known', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          mainAxisExtentBuilder: (rowIndex) => rowIndex == 0 ? 80 : 40,
          itemCount: 3,
          itemBuilder: (context, index) =>
              SizedBox(key: ValueKey(index), height: 20),
        ),
      ),
    );

    expect(find.byType(SliverVariedExtentList), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(395, 80));
    expect(tester.getSize(find.byKey(const ValueKey(1))), const Size(395, 80));
    expect(tester.getSize(find.byKey(const ValueKey(2))), const Size(395, 40));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))),
      const Offset(0, 100),
    );
  });
}
