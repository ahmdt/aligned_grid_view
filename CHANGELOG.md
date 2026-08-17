## Unreleased

* Avoid rebuilding the grid layout for scroll-only constraint changes.
* Represent row spacing without additional sliver children.
* Add `mainAxisExtentBuilder` for known variable row extents.
* Use direct sliver grid geometry for known fixed and variable row extents.
* Cache variable row extents and prefix offsets across layouts and scrolls.
* Remove trailing main-axis spacing from known-extent scroll geometry.
* Reduce content-driven row layout branches and repeated layout-info objects.
* Index semantics per tile instead of per content-driven row.

## 0.0.1

* Add aligned scroll-view and sliver grid widgets.
