import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../rendering/sliver_simple_grid_delegate.dart';
import 'uniform_track.dart';

/// Builds the known extent of a grid row along the scroll axis.
typedef AlignedGridMainAxisExtentBuilder = double Function(int rowIndex);

/// A sliver grid whose tiles in each row share the same main-axis extent.
class SliverAlignedGrid extends StatefulWidget {
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
       assert(mainAxisExtentBuilder == null || itemCount != null),
       assert(itemCount == null || itemCount >= 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0);

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
  /// and cannot be combined with [mainAxisExtent]. Extents are cached while
  /// this callback's identity remains unchanged, so use a new callback when
  /// its results change.
  final AlignedGridMainAxisExtentBuilder? mainAxisExtentBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  @override
  State<SliverAlignedGrid> createState() => _SliverAlignedGridState();
}

class _SliverAlignedGridState extends State<SliverAlignedGrid> {
  _RowExtentCache? _rowExtentCache;
  int? _firstNullItemIndex;

  @override
  void initState() {
    super.initState();
    _resetRowExtentCache();
  }

  @override
  void didUpdateWidget(SliverAlignedGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemBuilderChanged = !identical(
      oldWidget.itemBuilder,
      widget.itemBuilder,
    );
    if (itemBuilderChanged || oldWidget.itemCount != widget.itemCount) {
      _firstNullItemIndex = null;
    }
    if (!identical(
          oldWidget.mainAxisExtentBuilder,
          widget.mainAxisExtentBuilder,
        ) ||
        oldWidget.mainAxisSpacing != widget.mainAxisSpacing ||
        oldWidget.itemCount != widget.itemCount) {
      _resetRowExtentCache();
    }
  }

  void _resetRowExtentCache() {
    final builder = widget.mainAxisExtentBuilder;
    _rowExtentCache = builder == null
        ? null
        : _RowExtentCache(builder, widget.mainAxisSpacing);
  }

  @override
  Widget build(BuildContext context) {
    final fixedMainAxisExtent = widget.mainAxisExtent;
    if (fixedMainAxisExtent != null) {
      return SliverGrid(
        gridDelegate: _FixedExtentAlignedGridDelegate(
          gridDelegate: widget.gridDelegate,
          mainAxisExtent: fixedMainAxisExtent,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
        ),
        delegate: SliverChildBuilderDelegate(
          widget.itemBuilder,
          childCount: widget.itemCount,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
        ),
      );
    }

    final variedMainAxisExtentBuilder = widget.mainAxisExtentBuilder;
    if (variedMainAxisExtentBuilder != null) {
      return SliverGrid(
        gridDelegate: _VariedExtentAlignedGridDelegate(
          gridDelegate: widget.gridDelegate,
          itemCount: widget.itemCount!,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          cache: _rowExtentCache!,
        ),
        delegate: SliverChildBuilderDelegate(
          widget.itemBuilder,
          childCount: widget.itemCount,
          addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
          addRepaintBoundaries: widget.addRepaintBoundaries,
        ),
      );
    }

    return _SliverGridLayoutBuilder(
      gridDelegate: widget.gridDelegate,
      crossAxisSpacing: widget.crossAxisSpacing,
      builder: (context, layout) {
        final crossAxisCount = layout.crossAxisCount;
        final count = widget.itemCount;
        final rowCount = count == null
            ? null
            : (count + crossAxisCount - 1) ~/ crossAxisCount;
        double spacingAfterRow(int rowIndex) {
          return rowCount != null && rowIndex == rowCount - 1
              ? 0
              : widget.mainAxisSpacing;
        }

        Widget? buildTrack(BuildContext context, int rowIndex) {
          final startIndex = rowIndex * crossAxisCount;
          final firstNullItemIndex = _firstNullItemIndex;
          if (firstNullItemIndex != null && startIndex >= firstNullItemIndex) {
            return null;
          }
          final children = <Widget>[];
          for (var i = 0; i < crossAxisCount; i++) {
            final childIndex = startIndex + i;
            if (count != null && childIndex >= count) {
              break;
            }
            final child = widget.itemBuilder(context, childIndex);
            if (child == null) {
              if (_firstNullItemIndex == null ||
                  childIndex < _firstNullItemIndex!) {
                _firstNullItemIndex = childIndex;
              }
              break;
            }
            children.add(IndexedSemantics(index: childIndex, child: child));
          }
          if (children.isEmpty) {
            return null;
          }
          return UniformTrack(
            division: crossAxisCount,
            direction: layout.crossAxisDirection,
            spacing: widget.crossAxisSpacing,
            mainAxisSpacing: spacingAfterRow(rowIndex),
            children: children,
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            buildTrack,
            childCount: rowCount,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addSemanticIndexes: false,
          ),
        );
      },
    );
  }
}

class _FixedExtentAlignedGridDelegate extends SliverGridDelegate {
  const _FixedExtentAlignedGridDelegate({
    required this.gridDelegate,
    required this.mainAxisExtent,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
  });

  final SliverSimpleGridDelegate gridDelegate;
  final double mainAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final crossAxisCount = gridDelegate.getCrossAxisCount(
      constraints,
      crossAxisSpacing,
    );
    final usableCrossAxisExtent = math.max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: mainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: mainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(_FixedExtentAlignedGridDelegate oldDelegate) {
    return _gridDelegateNeedsLayout(gridDelegate, oldDelegate.gridDelegate) ||
        oldDelegate.mainAxisExtent != mainAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }
}

class _VariedExtentAlignedGridDelegate extends SliverGridDelegate {
  const _VariedExtentAlignedGridDelegate({
    required this.gridDelegate,
    required this.itemCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.cache,
  });

  final SliverSimpleGridDelegate gridDelegate;
  final int itemCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final _RowExtentCache cache;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final crossAxisCount = gridDelegate.getCrossAxisCount(
      constraints,
      crossAxisSpacing,
    );
    final usableCrossAxisExtent = math.max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final rowCount = (itemCount + crossAxisCount - 1) ~/ crossAxisCount;
    cache.configureRowCount(rowCount);
    return _VariedExtentAlignedGridLayout(
      crossAxisCount: crossAxisCount,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
      rowCount: rowCount,
      cache: cache,
    );
  }

  @override
  bool shouldRelayout(_VariedExtentAlignedGridDelegate oldDelegate) {
    return _gridDelegateNeedsLayout(gridDelegate, oldDelegate.gridDelegate) ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        !identical(oldDelegate.cache, cache);
  }
}

class _VariedExtentAlignedGridLayout extends SliverGridLayout {
  const _VariedExtentAlignedGridLayout({
    required this.crossAxisCount,
    required this.crossAxisStride,
    required this.childCrossAxisExtent,
    required this.reverseCrossAxis,
    required this.rowCount,
    required this.cache,
  });

  final int crossAxisCount;
  final double crossAxisStride;
  final double childCrossAxisExtent;
  final bool reverseCrossAxis;
  final int rowCount;
  final _RowExtentCache cache;

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    if (rowCount == 0) {
      return 0;
    }
    cache.computeThroughScrollOffset(scrollOffset);
    return cache.rowAtOrBefore(scrollOffset) * crossAxisCount;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    if (rowCount == 0) {
      return 0;
    }
    cache.computeThroughScrollOffset(scrollOffset);
    return math.max(
      0,
      cache.firstRowAtOrAfter(scrollOffset) * crossAxisCount - 1,
    );
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final rowIndex = index ~/ crossAxisCount;
    if (rowCount == 0) {
      return SliverGridGeometry(
        scrollOffset: 0,
        crossAxisOffset: 0,
        mainAxisExtent: 0,
        crossAxisExtent: childCrossAxisExtent,
      );
    }
    final columnIndex = index % crossAxisCount;
    final crossAxisStart = columnIndex * crossAxisStride;
    return SliverGridGeometry(
      scrollOffset: cache.offsetOf(rowIndex),
      crossAxisOffset: reverseCrossAxis
          ? crossAxisCount * crossAxisStride -
                crossAxisStart -
                childCrossAxisExtent -
                (crossAxisStride - childCrossAxisExtent)
          : crossAxisStart,
      mainAxisExtent: cache.extentOf(rowIndex),
      crossAxisExtent: childCrossAxisExtent,
    );
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0) {
      return 0;
    }
    return cache.maxScrollExtent;
  }
}

class _RowExtentCache {
  _RowExtentCache(this._builder, this._mainAxisSpacing);

  final AlignedGridMainAxisExtentBuilder _builder;
  final double _mainAxisSpacing;
  Float64List _offsets = Float64List(1);
  int _rowCount = 0;
  int _computedRows = 0;

  void configureRowCount(int rowCount) {
    if (rowCount == _rowCount) {
      return;
    }
    _rowCount = rowCount;
    _computedRows = math.min(_computedRows, rowCount);
    if (_offsets.length > rowCount + 1) {
      final offsets = Float64List(rowCount + 1);
      offsets.setRange(0, _computedRows + 1, _offsets);
      _offsets = offsets;
    }
  }

  void computeThroughScrollOffset(double scrollOffset) {
    while (_computedRows < _rowCount &&
        _offsets[_computedRows] <= scrollOffset) {
      _computeNextRow();
    }
  }

  double offsetOf(int rowIndex) {
    _computeThroughRow(rowIndex);
    return _offsets[rowIndex];
  }

  double extentOf(int rowIndex) {
    _computeThroughRow(rowIndex);
    return _offsets[rowIndex + 1] - _offsets[rowIndex] - _mainAxisSpacing;
  }

  int rowAtOrBefore(double scrollOffset) {
    final firstLaterRow = _upperBound(scrollOffset);
    return math.max(0, firstLaterRow - 1);
  }

  int firstRowAtOrAfter(double scrollOffset) => _lowerBound(scrollOffset);

  double get maxScrollExtent {
    if (_rowCount == 0) {
      return 0;
    }
    _computeThroughRow(_rowCount - 1);
    return _offsets[_rowCount] - _mainAxisSpacing;
  }

  void _computeThroughRow(int rowIndex) {
    while (_computedRows <= rowIndex) {
      _computeNextRow();
    }
  }

  void _computeNextRow() {
    final extent = _builder(_computedRows);
    assert(extent > 0, 'mainAxisExtentBuilder must return a positive extent.');
    _ensureCapacity(_computedRows + 2);
    _offsets[_computedRows + 1] =
        _offsets[_computedRows] + extent + _mainAxisSpacing;
    _computedRows++;
  }

  void _ensureCapacity(int requiredLength) {
    if (requiredLength <= _offsets.length) {
      return;
    }
    final capacity = math.min(
      _rowCount + 1,
      math.max(requiredLength, _offsets.length * 2),
    );
    final offsets = Float64List(capacity);
    offsets.setRange(0, _computedRows + 1, _offsets);
    _offsets = offsets;
  }

  int _lowerBound(double value) {
    var low = 0;
    var high = math.min(_computedRows + 1, _rowCount);
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (_offsets[middle] < value) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return low;
  }

  int _upperBound(double value) {
    var low = 0;
    var high = math.min(_computedRows + 1, _rowCount);
    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (_offsets[middle] <= value) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }
    return low;
  }
}

bool _gridDelegateNeedsLayout(
  SliverSimpleGridDelegate delegate,
  SliverSimpleGridDelegate oldDelegate,
) {
  return delegate.runtimeType != oldDelegate.runtimeType ||
      delegate.shouldRelayout(oldDelegate);
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
    return _RenderSliverGridLayoutBuilder(gridDelegate, crossAxisSpacing);
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
  _RenderSliverGridLayoutBuilder(this._gridDelegate, this._crossAxisSpacing);

  SliverSimpleGridDelegate _gridDelegate;
  double _crossAxisSpacing;
  _SliverGridLayoutInfo? _cachedLayoutInfo;

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
  _SliverGridLayoutInfo get layoutInfo {
    final crossAxisCount = _gridDelegate.getCrossAxisCount(
      constraints,
      _crossAxisSpacing,
    );
    final crossAxisDirection = constraints.crossAxisDirection;
    final cachedLayoutInfo = _cachedLayoutInfo;
    if (cachedLayoutInfo != null &&
        cachedLayoutInfo.crossAxisCount == crossAxisCount &&
        cachedLayoutInfo.crossAxisDirection == crossAxisDirection) {
      return cachedLayoutInfo;
    }
    return _cachedLayoutInfo = _SliverGridLayoutInfo(
      crossAxisCount: crossAxisCount,
      crossAxisDirection: crossAxisDirection,
    );
  }

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
