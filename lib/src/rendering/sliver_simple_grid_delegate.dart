import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Defines the number of tiles in the cross axis of an aligned grid.
abstract class SliverSimpleGridDelegate {
  const SliverSimpleGridDelegate();

  int getCrossAxisCount(SliverConstraints constraints, double crossAxisSpacing);

  bool shouldRelayout(covariant SliverSimpleGridDelegate oldDelegate);
}

/// A delegate with a fixed number of tiles in the cross axis.
class SliverSimpleGridDelegateWithFixedCrossAxisCount
    extends SliverSimpleGridDelegate {
  const SliverSimpleGridDelegateWithFixedCrossAxisCount({
    required this.crossAxisCount,
  }) : assert(crossAxisCount > 0);

  final int crossAxisCount;

  @override
  int getCrossAxisCount(
    SliverConstraints constraints,
    double crossAxisSpacing,
  ) {
    return crossAxisCount;
  }

  @override
  bool shouldRelayout(
    SliverSimpleGridDelegateWithFixedCrossAxisCount oldDelegate,
  ) {
    return oldDelegate.crossAxisCount != crossAxisCount;
  }
}

/// A delegate that limits the extent of each tile in the cross axis.
class SliverSimpleGridDelegateWithMaxCrossAxisExtent
    extends SliverSimpleGridDelegate {
  const SliverSimpleGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
  }) : assert(maxCrossAxisExtent > 0);

  final double maxCrossAxisExtent;

  @override
  int getCrossAxisCount(
    SliverConstraints constraints,
    double crossAxisSpacing,
  ) {
    return math.max(
      1,
      (constraints.crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
          .ceil(),
    );
  }

  @override
  bool shouldRelayout(
    SliverSimpleGridDelegateWithMaxCrossAxisExtent oldDelegate,
  ) {
    return oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent;
  }
}
