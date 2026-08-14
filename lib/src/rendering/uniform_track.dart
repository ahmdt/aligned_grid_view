import 'dart:math' as math;

import 'package:flutter/rendering.dart';

class UniformTrackParentData extends ContainerBoxParentData<RenderBox> {}

class RenderUniformTrack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, UniformTrackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, UniformTrackParentData> {
  RenderUniformTrack({
    List<RenderBox>? children,
    double spacing = 0,
    this._mainAxisExtent,
    required int division,
    required AxisDirection direction,
  }) : assert(spacing >= 0),
       assert(division > 0),
       _spacing = spacing,
       _direction = direction,
       _isHorizontal = axisDirectionToAxis(direction) == Axis.horizontal,
       _isDirectionReversed = axisDirectionIsReversed(direction),
       _division = division {
    addAll(children);
  }

  double _spacing;
  double? _mainAxisExtent;
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

  set mainAxisExtent(double? value) {
    assert(value == null || value > 0);
    if (_mainAxisExtent != value) {
      _mainAxisExtent = value;
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
    if (_mainAxisExtent != null) {
      return constraints.biggest;
    }
    return _computeSize(constraints, ChildLayoutHelper.dryLayoutChild);
  }

  Size _computeSize(BoxConstraints constraints, ChildLayouter layoutChild) {
    final mainAxisExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    final childMainAxisExtent = ((mainAxisExtent + _spacing) / _division) - _spacing;
    final childConstraints = _isHorizontal
        ? BoxConstraints.tightFor(width: childMainAxisExtent)
        : BoxConstraints.tightFor(height: childMainAxisExtent);
    var maxChildCrossAxisExtent = 0.0;
    var child = firstChild;
    while (child != null) {
      final size = layoutChild(child, childConstraints);
      maxChildCrossAxisExtent = math.max(maxChildCrossAxisExtent, _isHorizontal ? size.height : size.width);
      child = childAfter(child);
    }
    return constraints.constrain(
      _isHorizontal ? Size(mainAxisExtent, maxChildCrossAxisExtent) : Size(maxChildCrossAxisExtent, mainAxisExtent),
    );
  }

  @override
  void performLayout() {
    final fixedMainAxisExtent = _mainAxisExtent;
    if (fixedMainAxisExtent != null) {
      size = constraints.biggest;
      final gridMainAxisExtent = _isHorizontal ? size.width : size.height;
      final childMainAxisExtent = ((gridMainAxisExtent + _spacing) / _division) - _spacing;
      final childConstraints = _isHorizontal
          ? BoxConstraints.tightFor(width: childMainAxisExtent, height: fixedMainAxisExtent)
          : BoxConstraints.tightFor(width: fixedMainAxisExtent, height: childMainAxisExtent);
      final stride = childMainAxisExtent + _spacing;
      var index = 0;
      var child = firstChild;
      while (child != null) {
        child.layout(childConstraints, parentUsesSize: true);
        final parentData = child.parentData! as UniformTrackParentData;
        final effectiveIndex = _isDirectionReversed ? _division - index - 1 : index;
        parentData.offset = _isHorizontal ? Offset(effectiveIndex * stride, 0) : Offset(0, effectiveIndex * stride);
        index++;
        child = parentData.nextSibling;
      }
      return;
    }

    size = _computeSize(constraints, ChildLayoutHelper.layoutChild);
    final mainAxisExtent = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    final childMainAxisExtent = ((mainAxisExtent + _spacing) / _division) - _spacing;
    final crossAxisExtent = _isHorizontal ? size.height : size.width;
    final childConstraints = _isHorizontal
        ? BoxConstraints.tightFor(width: childMainAxisExtent, height: crossAxisExtent)
        : BoxConstraints.tightFor(height: childMainAxisExtent, width: crossAxisExtent);
    final stride = childMainAxisExtent + _spacing;
    var index = 0;
    var child = firstChild;
    while (child != null) {
      final childExtent = _isHorizontal ? child.size.height : child.size.width;
      if (childExtent != crossAxisExtent) {
        child.layout(childConstraints, parentUsesSize: true);
      }
      final parentData = child.parentData! as UniformTrackParentData;
      final effectiveIndex = _isDirectionReversed ? _division - index - 1 : index;
      parentData.offset = _isHorizontal ? Offset(effectiveIndex * stride, 0) : Offset(0, effectiveIndex * stride);
      index++;
      child = parentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
