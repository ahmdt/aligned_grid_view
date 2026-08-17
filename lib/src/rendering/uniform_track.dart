import 'package:flutter/rendering.dart';

class UniformTrackParentData extends ContainerBoxParentData<RenderBox> {}

class RenderUniformTrack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, UniformTrackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, UniformTrackParentData> {
  RenderUniformTrack({
    List<RenderBox>? children,
    double spacing = 0,
    double mainAxisSpacing = 0,
    required int division,
    required AxisDirection direction,
  }) : assert(spacing >= 0),
       assert(mainAxisSpacing >= 0),
       assert(division > 0),
       _spacing = spacing,
       _mainAxisSpacing = mainAxisSpacing,
       _direction = direction,
       _isHorizontal = axisDirectionToAxis(direction) == Axis.horizontal,
       _isDirectionReversed = axisDirectionIsReversed(direction),
       _division = division {
    addAll(children);
  }

  double _spacing;
  double _mainAxisSpacing;
  AxisDirection _direction;
  bool _isHorizontal;
  bool _isDirectionReversed;
  int _division;

  set spacing(double value) {
    assert(value >= 0);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  set mainAxisSpacing(double value) {
    assert(value >= 0);
    if (_mainAxisSpacing != value) {
      _mainAxisSpacing = value;
      markNeedsLayout();
    }
  }

  set direction(AxisDirection value) {
    if (_direction != value) {
      _direction = value;
      _isHorizontal = axisDirectionToAxis(value) == Axis.horizontal;
      _isDirectionReversed = axisDirectionIsReversed(value);
      markNeedsLayout();
    }
  }

  set division(int value) {
    assert(value > 0);
    if (_division != value) {
      _division = value;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! UniformTrackParentData) {
      child.parentData = UniformTrackParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _computeSize(constraints, ChildLayoutHelper.dryLayoutChild);
  }

  Size _computeSize(BoxConstraints constraints, ChildLayouter layoutChild) {
    final mainAxisExtent = _isHorizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final childMainAxisExtent =
        ((mainAxisExtent + _spacing) / _division) - _spacing;
    final childConstraints = _isHorizontal
        ? BoxConstraints.tightFor(width: childMainAxisExtent)
        : BoxConstraints.tightFor(height: childMainAxisExtent);
    var maxChildCrossAxisExtent = 0.0;
    var child = firstChild;
    while (child != null) {
      final size = layoutChild(child, childConstraints);
      final childCrossAxisExtent = _isHorizontal ? size.height : size.width;
      if (childCrossAxisExtent > maxChildCrossAxisExtent) {
        maxChildCrossAxisExtent = childCrossAxisExtent;
      }
      final parentData = child.parentData! as UniformTrackParentData;
      child = parentData.nextSibling;
    }
    final trackCrossAxisExtent = maxChildCrossAxisExtent + _mainAxisSpacing;
    return constraints.constrain(
      _isHorizontal
          ? Size(mainAxisExtent, trackCrossAxisExtent)
          : Size(trackCrossAxisExtent, mainAxisExtent),
    );
  }

  @override
  void performLayout() {
    size = _computeSize(constraints, ChildLayoutHelper.layoutChild);
    final mainAxisExtent = _isHorizontal
        ? constraints.maxWidth
        : constraints.maxHeight;
    final childMainAxisExtent =
        ((mainAxisExtent + _spacing) / _division) - _spacing;
    final crossAxisExtent =
        (_isHorizontal ? size.height : size.width) - _mainAxisSpacing;
    final childConstraints = _isHorizontal
        ? BoxConstraints.tightFor(
            width: childMainAxisExtent,
            height: crossAxisExtent,
          )
        : BoxConstraints.tightFor(
            height: childMainAxisExtent,
            width: crossAxisExtent,
          );
    final stride = childMainAxisExtent + _spacing;
    var childOffset = _isDirectionReversed ? (_division - 1) * stride : 0.0;
    final offsetDelta = _isDirectionReversed ? -stride : stride;
    var child = firstChild;
    while (child != null) {
      final childExtent = _isHorizontal ? child.size.height : child.size.width;
      if (childExtent != crossAxisExtent) {
        child.layout(childConstraints, parentUsesSize: true);
      }
      final parentData = child.parentData! as UniformTrackParentData;
      parentData.offset = _isHorizontal
          ? Offset(childOffset, 0)
          : Offset(0, childOffset);
      childOffset += offsetDelta;
      child = parentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
