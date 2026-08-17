// `cacheExtent` keeps the package compatible with its older Flutter lower bound.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';

import '../rendering/sliver_simple_grid_delegate.dart';
import 'sliver_aligned_grid.dart';

/// A scrollable aligned grid.
class AlignedGridView extends BoxScrollView {
  const AlignedGridView.custom({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.cacheExtent,
    required this.gridDelegate,
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.mainAxisExtent,
    this.mainAxisExtentBuilder,
  }) : assert(mainAxisExtent == null || mainAxisExtent > 0),
       assert(mainAxisExtent == null || mainAxisExtentBuilder == null),
       assert(mainAxisExtentBuilder == null || itemCount != null),
       assert(itemCount == null || itemCount >= 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0);

  AlignedGridView.count({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.cacheExtent,
    required int crossAxisCount,
    required this.itemBuilder,
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
       assert(crossAxisSpacing >= 0),
       gridDelegate = SliverSimpleGridDelegateWithFixedCrossAxisCount(
         crossAxisCount: crossAxisCount,
       ),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  AlignedGridView.extent({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.padding,
    int? semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
    super.cacheExtent,
    required double maxCrossAxisExtent,
    required this.itemBuilder,
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
       assert(crossAxisSpacing >= 0),
       gridDelegate = SliverSimpleGridDelegateWithMaxCrossAxisExtent(
         maxCrossAxisExtent: maxCrossAxisExtent,
       ),
       super(semanticChildCount: semanticChildCount ?? itemCount);

  final SliverSimpleGridDelegate gridDelegate;
  final NullableIndexedWidgetBuilder itemBuilder;
  final int? itemCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// The known extent of each row along the scroll axis.
  ///
  /// Supplying this enables a fixed-extent sliver fast path for large lists.
  final double? mainAxisExtent;

  /// Supplies a known extent for each row along the scroll axis.
  ///
  /// This requires [itemCount] and cannot be combined with [mainAxisExtent].
  /// Extents are cached while this callback's identity remains unchanged, so
  /// use a new callback when its results change.
  final AlignedGridMainAxisExtentBuilder? mainAxisExtentBuilder;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverAlignedGrid(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisExtent: mainAxisExtent,
      mainAxisExtentBuilder: mainAxisExtentBuilder,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
    );
  }
}
