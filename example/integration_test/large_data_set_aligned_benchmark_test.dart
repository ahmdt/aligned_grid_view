import 'package:aligned_grid_view/aligned_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'large_data_set_benchmark.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('large data set aligned fling', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      LargeDataSetBenchmarkApp(
        child: AlignedGridView.extent(
          key: largeDataSetScrollableKey,
          controller: controller,
          padding: largeDataSetPadding,
          maxCrossAxisExtent: 240,
          mainAxisSpacing: largeDataSetMainAxisSpacing,
          crossAxisSpacing: largeDataSetCrossAxisSpacing,
          addAutomaticKeepAlives: false,
          itemCount: largeDataSetItemCount,
          itemBuilder: (context, index) => LargeDataSetCard(index: index),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await binding.watchPerformance(() async {
      for (var i = 0; i < 6; i++) {
        await tester.fling(
          find.byKey(largeDataSetScrollableKey),
          const Offset(0, -1000),
          4000,
        );
        await tester.pumpAndSettle();
      }
    }, reportKey: 'large_data_set_aligned_fling');
  });
}
