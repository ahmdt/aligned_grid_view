import 'package:flutter/widgets.dart';

import '../rendering/uniform_track.dart';

class UniformTrack extends MultiChildRenderObjectWidget {
  const UniformTrack({
    super.key,
    required this.division,
    required this.direction,
    required super.children,
    this.spacing = 0,
    this.mainAxisExtent,
  }) : assert(division > 0),
       assert(spacing >= 0),
       assert(mainAxisExtent == null || mainAxisExtent > 0),
       assert(children.length <= division);

  final int division;
  final AxisDirection direction;
  final double spacing;
  final double? mainAxisExtent;

  @override
  RenderUniformTrack createRenderObject(BuildContext context) {
    return RenderUniformTrack(
      division: division,
      direction: direction,
      spacing: spacing,
      mainAxisExtent: mainAxisExtent,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderUniformTrack renderObject,
  ) {
    renderObject
      ..division = division
      ..direction = direction
      ..spacing = spacing
      ..mainAxisExtent = mainAxisExtent;
  }
}
