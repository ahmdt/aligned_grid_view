import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../rendering/sliver_simple_grid_delegate.dart';
import 'uniform_track.dart';

/// Builds the known extent of a grid row along the scroll axis.
typedef AlignedGridMainAxisExtentBuilder = double Function(int rowIndex);

/// A sliver grid whose tiles in each row share the same main-axis extent.
class SliverAlignedGrid extends StatelessWidget {
  const SliverAlignedGrid({
    super.key,
    required this.itemBuilder,
    required this.gridDelegate,
    this.itemCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.mainAxisExtent,
    this.mainAxisExtentBuilder,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
  }) : assert(mainAxisExtent == null || mainAxisExtent > 0),
       assert(mainAxisExtent == null || mainAxisExtentBuilder == null),
       assert(mainAxisExtentBuilder == null || itemCount != null);

  SliverAlignedGrid.count({
    Key? key,
    required NullableIndexedWidgetBuilder itemBuilder,
    required int crossAxisCount,
    int? itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    double? mainAxisExtent,
    AlignedGridMainAxisExtentBuilder? mainAxisExtentBuilder,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
  }) : this(
         key: key,
         itemBuilder: itemBuilder,
         itemCount: itemCount,
         gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: crossAxisCount,
         ),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         mainAxisExtent: mainAxisExtent,
         mainAxisExtentBuilder: mainAxisExtentBuilder,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
       );

  SliverAlignedGrid.extent({
    Key? key,
    required NullableIndexedWidgetBuilder itemBuilder,
    required double maxCrossAxisExtent,
    int? itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    double? mainAxisExtent,
    AlignedGridMainAxisExtentBuilder? mainAxisExtentBuilder,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
  }) : this(
         key: key,
         itemBuilder: itemBuilder,
         itemCount: itemCount,
         gridDelegate: SliverSimpleGridDelegateWithMaxCrossAxisExtent(
           maxCrossAxisExtent: maxCrossAxisExtent,
         ),
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         mainAxisExtent: mainAxisExtent,
         mainAxisExtentBuilder: mainAxisExtentBuilder,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
       );

  final NullableIndexedWidgetBuilder itemBuilder;
  final int? itemCount;
  final SliverSimpleGridDelegate gridDelegate;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// The known extent of each row along the scroll axis.
  ///
  /// Supplying this enables a fixed-extent sliver fast path, which is
  /// substantially more efficient for large lists and direct scroll jumps.
  final double? mainAxisExtent;

  /// Supplies a known extent for each row along the scroll axis.
  ///
  /// This enables a varied-extent sliver fast path. It requires [itemCount]
  /// and cannot be combined with [mainAxisExtent].
  final AlignedGridMainAxisExtentBuilder? mainAxisExtentBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  @override
  Widget build(BuildContext context) {
    return _SliverGridLayoutBuilder(
      gridDelegate: gridDelegate,
      crossAxisSpacing: crossAxisSpacing,
      builder: (context, layout) {
        final crossAxisCount = layout.crossAxisCount;
        final count = itemCount;
        final rowCount = count == null
            ? null
            : (count + crossAxisCount - 1) ~/ crossAxisCount;
        double spacingAfterRow(int rowIndex) {
          return rowCount != null && rowIndex == rowCount - 1
              ? 0
              : mainAxisSpacing;
        }

        Widget? buildTrack(BuildContext context, int rowIndex) {
          final startIndex = rowIndex * crossAxisCount;
          final children = <Widget>[];
          for (var i = 0; i < crossAxisCount; i++) {
            final childIndex = startIndex + i;
            if (count != null && childIndex >= count) {
              break;
            }
            final child = itemBuilder(context, childIndex);
            if (child != null) {
              children.add(child);
            }
          }
          if (children.isEmpty) {
            return null;
          }
          final variedMainAxisExtent = mainAxisExtentBuilder?.call(rowIndex);
          assert(
            variedMainAxisExtent == null || variedMainAxisExtent > 0,
            'mainAxisExtentBuilder must return a positive extent.',
          );
          return UniformTrack(
            division: crossAxisCount,
            direction: layout.crossAxisDirection,
            spacing: crossAxisSpacing,
            mainAxisSpacing: spacingAfterRow(rowIndex),
            mainAxisExtent: mainAxisExtent ?? variedMainAxisExtent,
            children: children,
          );
        }

        final fixedMainAxisExtent = mainAxisExtent;
        if (fixedMainAxisExtent != null) {
          return SliverFixedExtentList(
            itemExtent: fixedMainAxisExtent + mainAxisSpacing,
            delegate: SliverChildBuilderDelegate(
              buildTrack,
              childCount: rowCount,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addRepaintBoundaries: addRepaintBoundaries,
            ),
          );
        }

        final variedMainAxisExtentBuilder = mainAxisExtentBuilder;
        if (variedMainAxisExtentBuilder != null) {
          return SliverVariedExtentList.builder(
            itemCount: rowCount,
            itemBuilder: buildTrack,
            itemExtentBuilder: (rowIndex, dimensions) {
              final extent = variedMainAxisExtentBuilder(rowIndex);
              assert(
                extent > 0,
                'mainAxisExtentBuilder must return a positive extent.',
              );
              return extent + spacingAfterRow(rowIndex);
            },
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            buildTrack,
            childCount: rowCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
          ),
        );
      },
    );
  }
}

class _SliverGridLayoutInfo {
  const _SliverGridLayoutInfo({
    required this.crossAxisCount,
    required this.crossAxisDirection,
  });

  final int crossAxisCount;
  final AxisDirection crossAxisDirection;

  @override
  bool operator ==(Object other) {
    return other is _SliverGridLayoutInfo &&
        other.crossAxisCount == crossAxisCount &&
        other.crossAxisDirection == crossAxisDirection;
  }

  @override
  int get hashCode => Object.hash(crossAxisCount, crossAxisDirection);
}

class _SliverGridLayoutBuilder
    extends AbstractLayoutBuilder<_SliverGridLayoutInfo> {
  const _SliverGridLayoutBuilder({
    required this.gridDelegate,
    required this.crossAxisSpacing,
    required this.builder,
  });

  final SliverSimpleGridDelegate gridDelegate;
  final double crossAxisSpacing;

  @override
  final Widget Function(BuildContext, _SliverGridLayoutInfo) builder;

  @override
  _RenderSliverGridLayoutBuilder createRenderObject(BuildContext context) {
    return _RenderSliverGridLayoutBuilder(
      gridDelegate: gridDelegate,
      crossAxisSpacing: crossAxisSpacing,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSliverGridLayoutBuilder renderObject,
  ) {
    renderObject
      ..gridDelegate = gridDelegate
      ..crossAxisSpacing = crossAxisSpacing;
  }
}

class _RenderSliverGridLayoutBuilder extends RenderSliver
    with
        RenderObjectWithChildMixin<RenderSliver>,
        RenderObjectWithLayoutCallbackMixin,
        RenderAbstractLayoutBuilderMixin<_SliverGridLayoutInfo, RenderSliver> {
  _RenderSliverGridLayoutBuilder({
    required SliverSimpleGridDelegate gridDelegate,
    required double crossAxisSpacing,
  }) : _gridDelegate = gridDelegate,
       _crossAxisSpacing = crossAxisSpacing;

  SliverSimpleGridDelegate _gridDelegate;
  double _crossAxisSpacing;

  set gridDelegate(SliverSimpleGridDelegate value) {
    if (identical(value, _gridDelegate)) {
      return;
    }
    final oldDelegate = _gridDelegate;
    _gridDelegate = value;
    if (value.runtimeType != oldDelegate.runtimeType ||
        value.shouldRelayout(oldDelegate)) {
      markNeedsLayout();
    }
  }

  set crossAxisSpacing(double value) {
    if (value != _crossAxisSpacing) {
      _crossAxisSpacing = value;
      markNeedsLayout();
    }
  }

  @override
  _SliverGridLayoutInfo get layoutInfo => _SliverGridLayoutInfo(
    crossAxisCount: _gridDelegate.getCrossAxisCount(
      constraints,
      _crossAxisSpacing,
    ),
    crossAxisDirection: constraints.crossAxisDirection,
  );

  @override
  double childMainAxisPosition(RenderObject child) => 0;

  @override
  void performLayout() {
    runLayoutCallback();
    child?.layout(constraints, parentUsesSize: true);
    geometry = child?.geometry ?? SliverGeometry.zero;
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child?.geometry?.visible ?? false) {
      context.paintChild(child!, offset);
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    return child != null &&
        child!.geometry!.hitTestExtent > 0 &&
        child!.hitTest(
          result,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        );
  }
}
