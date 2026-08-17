## 0.1.0

* Add `mainAxisExtentBuilder` for known, variable row extents.
* Improve scrolling and jump performance for known fixed and variable row
  extents by using direct sliver grid geometry and cached prefix offsets.
* Avoid rebuilding layouts for scroll-only constraint changes and reduce
  content-driven row layout work.
* Correct trailing main-axis spacing and expose semantics for each tile.

## 0.0.1

* Add aligned scroll-view and sliver grid widgets.
