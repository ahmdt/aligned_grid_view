import 'package:flutter/widgets.dart';

import '../rendering/sliver_simple_grid_delegate.dart';
import 'uniform_track.dart';

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
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
  }) : assert(mainAxisExtent == null || mainAxisExtent > 0);

  SliverAlignedGrid.count({
    Key? key,
    required NullableIndexedWidgetBuilder itemBuilder,
    required int crossAxisCount,
    int? itemCount,
    double mainAxisSpacing = 0,
    double crossAxisSpacing = 0,
    double? mainAxisExtent,
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
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = gridDelegate.getCrossAxisCount(
          constraints,
          crossAxisSpacing,
        );
        final count = itemCount;
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
          return UniformTrack(
            division: crossAxisCount,
            direction: constraints.crossAxisDirection,
            spacing: crossAxisSpacing,
            mainAxisExtent: mainAxisExtent,
            children: children,
          );
        }

        final fixedMainAxisExtent = mainAxisExtent;
        if (fixedMainAxisExtent != null) {
          final rowCount = count == null
              ? null
              : (count + crossAxisCount - 1) ~/ crossAxisCount;
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

        final rowAndGapCount = count == null
            ? null
            : ((count + crossAxisCount - 1) ~/ crossAxisCount) * 2 - 1;
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index.isOdd) {
                return _Gap(mainAxisExtent: mainAxisSpacing);
              }
              return buildTrack(context, index ~/ 2);
            },
            childCount: rowAndGapCount,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
          ),
        );
      },
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap({required this.mainAxisExtent});

  final double mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    final axis = axisDirectionToAxis(Scrollable.of(context).axisDirection);
    return axis == Axis.vertical
        ? SizedBox(height: mainAxisExtent)
        : SizedBox(width: mainAxisExtent);
  }
}
