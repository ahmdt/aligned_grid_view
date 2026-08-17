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

  testWidgets('uses direct grid geometry when the row extent is known', (
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

    expect(find.byType(SliverGrid), findsOneWidget);
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

  testWidgets('uses direct grid geometry when row extents are known', (
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

    expect(find.byType(SliverGrid), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(395, 80));
    expect(tester.getSize(find.byKey(const ValueKey(1))), const Size(395, 80));
    expect(tester.getSize(find.byKey(const ValueKey(2))), const Size(395, 40));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))),
      const Offset(0, 100),
    );
  });

  testWidgets('does not include spacing after the final fixed-extent row', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 800,
            height: 100,
            child: AlignedGridView.count(
              controller: controller,
              crossAxisCount: 2,
              mainAxisExtent: 80,
              mainAxisSpacing: 20,
              itemCount: 3,
              itemBuilder: (context, index) => const SizedBox(),
            ),
          ),
        ),
      ),
    );

    expect(controller.position.maxScrollExtent, 80);
  });

  testWidgets('does not include spacing after the final varied-extent row', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 800,
            height: 100,
            child: AlignedGridView.count(
              controller: controller,
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              mainAxisExtentBuilder: (rowIndex) => rowIndex == 0 ? 80 : 40,
              itemCount: 3,
              itemBuilder: (context, index) => const SizedBox(),
            ),
          ),
        ),
      ),
    );

    expect(controller.position.maxScrollExtent, 40);
  });

  testWidgets('caches each known row extent across repeated jumps', (
    tester,
  ) async {
    final controller = ScrollController();
    final calls = List<int>.filled(1000, 0);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          height: 200,
          child: AlignedGridView.count(
            controller: controller,
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            mainAxisExtentBuilder: (rowIndex) {
              calls[rowIndex]++;
              return rowIndex.isEven ? 40 : 80;
            },
            itemCount: 2000,
            itemBuilder: (context, index) => const SizedBox(),
          ),
        ),
      ),
    );

    final target = controller.position.maxScrollExtent * 0.8;
    controller.jumpTo(target);
    await tester.pump();
    final callsAfterFirstJump = calls.fold<int>(0, (sum, value) => sum + value);

    controller.jumpTo(0);
    await tester.pump();
    controller.jumpTo(target);
    await tester.pump();

    expect(calls.every((count) => count <= 1), isTrue);
    expect(
      calls.fold<int>(0, (sum, value) => sum + value),
      callsAfterFirstJump,
    );
  });

  testWidgets('lays out fixed extents in reversed cross-axis direction', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisExtent: 40,
          itemCount: 2,
          itemBuilder: (context, index) => SizedBox(key: ValueKey(index)),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.byKey(const ValueKey(0))),
      const Offset(405, 0),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(1))),
      const Offset(0, 0),
    );
  });

  testWidgets('uses at least one column at zero cross-axis extent', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 0,
            height: 100,
            child: AlignedGridView.extent(
              maxCrossAxisExtent: 100,
              mainAxisExtent: 20,
              itemCount: 1,
              itemBuilder: (context, index) => SizedBox(key: ValueKey(index)),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey(0))).width, 0);
  });

  testWidgets('does not request an extent for an empty varied grid', (
    tester,
  ) async {
    var extentCalls = 0;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          itemCount: 0,
          mainAxisExtentBuilder: (rowIndex) {
            extentCalls++;
            return 40;
          },
          itemBuilder: (context, index) => const SizedBox(),
        ),
      ),
    );

    expect(extentCalls, 0);
  });

  testWidgets('invalidates cached extents when the builder changes', (
    tester,
  ) async {
    var useLargeExtents = false;
    late StateSetter setState;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: StatefulBuilder(
          builder: (context, stateSetter) {
            setState = stateSetter;
            final extentBuilder = useLargeExtents
                ? (int rowIndex) => 80.0
                : (int rowIndex) => 40.0;
            return AlignedGridView.count(
              crossAxisCount: 2,
              mainAxisExtentBuilder: extentBuilder,
              itemCount: 2,
              itemBuilder: (context, index) => SizedBox(key: ValueKey(index)),
            );
          },
        ),
      ),
    );
    expect(tester.getSize(find.byKey(const ValueKey(0))).height, 40);

    setState(() => useLargeExtents = true);
    await tester.pump();

    expect(tester.getSize(find.byKey(const ValueKey(0))).height, 80);
  });

  testWidgets('indexes content-driven semantics per tile', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          itemCount: 3,
          itemBuilder: (context, index) => const SizedBox(height: 40),
        ),
      ),
    );

    final indexedSemantics = tester.widgetList<IndexedSemantics>(
      find.byType(IndexedSemantics),
    );
    expect(indexedSemantics.map((widget) => widget.index), [0, 1, 2]);
  });

  testWidgets('lays out fixed extents horizontally', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          scrollDirection: Axis.horizontal,
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 20,
          mainAxisExtent: 80,
          itemCount: 3,
          itemBuilder: (context, index) => SizedBox(key: ValueKey(index)),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const ValueKey(0))), const Size(80, 295));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(1))),
      const Offset(0, 305),
    );
    expect(
      tester.getTopLeft(find.byKey(const ValueKey(2))),
      const Offset(100, 0),
    );
  });

  testWidgets('stops content-driven rows after the first null item', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AlignedGridView.count(
          crossAxisCount: 2,
          itemBuilder: (context, index) {
            if (index == 1) {
              return null;
            }
            return SizedBox(key: ValueKey(index), height: 40);
          },
        ),
      ),
    );

    expect(find.byKey(const ValueKey(0)), findsOneWidget);
    expect(find.byKey(const ValueKey(2)), findsNothing);
  });
}
