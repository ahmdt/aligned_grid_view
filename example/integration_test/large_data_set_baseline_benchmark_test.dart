import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'large_data_set_benchmark.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('large data set baseline fling', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      LargeDataSetBenchmarkApp(
        child: ListView.separated(
          key: largeDataSetScrollableKey,
          controller: controller,
          padding: largeDataSetPadding,
          addAutomaticKeepAlives: false,
          itemCount:
              (largeDataSetItemCount + largeDataSetCrossAxisCount - 1) ~/
              largeDataSetCrossAxisCount,
          separatorBuilder: (context, index) =>
              const SizedBox(height: largeDataSetMainAxisSpacing),
          itemBuilder: (context, rowIndex) => _BaselineRow(rowIndex: rowIndex),
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
    }, reportKey: 'large_data_set_baseline_fling');
  });
}

class _BaselineRow extends StatelessWidget {
  const _BaselineRow({required this.rowIndex});

  final int rowIndex;

  @override
  Widget build(BuildContext context) {
    final firstItemIndex = rowIndex * largeDataSetCrossAxisCount;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var column = 0; column < largeDataSetCrossAxisCount; column++)
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: column == 0 ? 0 : largeDataSetCrossAxisSpacing / 2,
                  end: column == largeDataSetCrossAxisCount - 1
                      ? 0
                      : largeDataSetCrossAxisSpacing / 2,
                ),
                child: LargeDataSetCard(index: firstItemIndex + column),
              ),
            ),
        ],
      ),
    );
  }
}
