import 'dart:math' as math;

import 'package:aligned_grid_view/aligned_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _scrollItemCount = 1000000;
const _jumpItemCount = 10000;
const _crossAxisCount = 4;
const _mainAxisSpacing = 8.0;
const _crossAxisSpacing = 8.0;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final implementation in _Implementation.values) {
    for (final heights in _Heights.values) {
      final name = '${implementation.name}_${heights.name}';

      testWidgets('$name fling', (tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          _BenchmarkApp(
            implementation: implementation,
            heights: heights,
            controller: controller,
            itemCount: _scrollItemCount,
          ),
        );
        await tester.pumpAndSettle();

        await binding.watchPerformance(() async {
          for (var i = 0; i < 6; i++) {
            await tester.fling(
              find.byKey(const ValueKey('benchmark-scrollable')),
              const Offset(0, -1000),
              4000,
            );
            await tester.pumpAndSettle();
          }
        }, reportKey: '${name}_fling');
        controller.dispose();
      });

      testWidgets('$name jump', (tester) async {
        final controller = ScrollController();
        await tester.pumpWidget(
          _BenchmarkApp(
            implementation: implementation,
            heights: heights,
            controller: controller,
            itemCount: _jumpItemCount,
          ),
        );
        await tester.pumpAndSettle();

        await binding.watchPerformance(() async {
          for (final fraction in [0.25, 0.5, 0.9, 0.1]) {
            controller.jumpTo(controller.position.maxScrollExtent * fraction);
            await tester.pumpAndSettle();
          }
        }, reportKey: '${name}_jump');
        controller.dispose();
      });
    }
  }

  testWidgets('aligned_uniform fixed-extent large jump', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      _BenchmarkApp(
        implementation: _Implementation.aligned,
        heights: _Heights.uniform,
        controller: controller,
        itemCount: _scrollItemCount,
      ),
    );
    await tester.pumpAndSettle();

    await binding.watchPerformance(() async {
      for (final fraction in [0.25, 0.5, 0.9, 0.1]) {
        controller.jumpTo(controller.position.maxScrollExtent * fraction);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'aligned_uniform_fixed_extent_large_jump');
    controller.dispose();
  });

  testWidgets('aligned_known_varied fling', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      _BenchmarkApp(
        implementation: _Implementation.aligned,
        heights: _Heights.varied,
        controller: controller,
        itemCount: _scrollItemCount,
        useKnownVariedExtents: true,
      ),
    );
    await tester.pumpAndSettle();

    await binding.watchPerformance(() async {
      for (var i = 0; i < 6; i++) {
        await tester.fling(
          find.byKey(const ValueKey('benchmark-scrollable')),
          const Offset(0, -1000),
          4000,
        );
        await tester.pumpAndSettle();
      }
    }, reportKey: 'aligned_known_varied_fling');
    controller.dispose();
  });

  testWidgets('aligned_known_varied large jump', (tester) async {
    final controller = ScrollController();
    await tester.pumpWidget(
      _BenchmarkApp(
        implementation: _Implementation.aligned,
        heights: _Heights.varied,
        controller: controller,
        itemCount: _scrollItemCount,
        useKnownVariedExtents: true,
      ),
    );
    await tester.pumpAndSettle();

    await binding.watchPerformance(() async {
      for (final fraction in [0.25, 0.5, 0.9, 0.1]) {
        controller.jumpTo(controller.position.maxScrollExtent * fraction);
        await tester.pumpAndSettle();
      }
    }, reportKey: 'aligned_known_varied_large_jump');
    controller.dispose();
  });
}

enum _Implementation { aligned, intrinsicRowBaseline }

enum _Heights { uniform, varied }

class _BenchmarkApp extends StatelessWidget {
  const _BenchmarkApp({
    required this.implementation,
    required this.heights,
    required this.controller,
    required this.itemCount,
    this.useKnownVariedExtents = false,
  });

  final _Implementation implementation;
  final _Heights heights;
  final ScrollController controller;
  final int itemCount;
  final bool useKnownVariedExtents;

  @override
  Widget build(BuildContext context) {
    Widget itemBuilder(BuildContext context, int index) {
      return SizedBox(
        height: _heightFor(index, heights),
        child: const ColoredBox(color: Color(0xff336699)),
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: implementation == _Implementation.aligned
            ? AlignedGridView.count(
                key: const ValueKey('benchmark-scrollable'),
                controller: controller,
                crossAxisCount: _crossAxisCount,
                itemCount: itemCount,
                mainAxisSpacing: _mainAxisSpacing,
                crossAxisSpacing: _crossAxisSpacing,
                mainAxisExtent: heights == _Heights.uniform ? 96 : null,
                mainAxisExtentBuilder: useKnownVariedExtents
                    ? _knownVariedRowExtent
                    : null,
                itemBuilder: itemBuilder,
              )
            : _IntrinsicRowGrid(
                controller: controller,
                heights: heights,
                itemCount: itemCount,
              ),
      ),
    );
  }
}

class _IntrinsicRowGrid extends StatelessWidget {
  const _IntrinsicRowGrid({
    required this.controller,
    required this.heights,
    required this.itemCount,
  });

  final ScrollController controller;
  final _Heights heights;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final rowCount = (itemCount + _crossAxisCount - 1) ~/ _crossAxisCount;
    return ListView.separated(
      key: const ValueKey('benchmark-scrollable'),
      controller: controller,
      itemCount: rowCount,
      separatorBuilder: (context, index) =>
          const SizedBox(height: _mainAxisSpacing),
      itemBuilder: (context, rowIndex) {
        final firstItemIndex = rowIndex * _crossAxisCount;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var column = 0; column < _crossAxisCount; column++) ...[
                if (column > 0) const SizedBox(width: _crossAxisSpacing),
                Expanded(
                  child: firstItemIndex + column < itemCount
                      ? SizedBox(
                          height: _heightFor(firstItemIndex + column, heights),
                          child: const ColoredBox(color: Color(0xff336699)),
                        )
                      : const SizedBox(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

double _heightFor(int index, _Heights heights) {
  if (heights == _Heights.uniform) {
    return 96;
  }
  return switch (index % 5) {
    0 => 56,
    1 => 88,
    2 => 128,
    3 => 192,
    _ => 272,
  };
}

double _knownVariedRowExtent(int rowIndex) {
  final firstItemIndex = rowIndex * _crossAxisCount;
  var extent = 0.0;
  for (var column = 0; column < _crossAxisCount; column++) {
    extent = math.max(
      extent,
      _heightFor(firstItemIndex + column, _Heights.varied),
    );
  }
  return extent;
}
