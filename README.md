# aligned_grid_view

Flutter grids that align every tile in a row to the row's largest main-axis extent.

## Usage

```dart
AlignedGridView.count(
  crossAxisCount: 3,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

Use `SliverAlignedGrid.count` in a `CustomScrollView`. The `extent` and
`custom` constructors support responsive or application-defined column counts.

## Performance

`AlignedGridView` lazily builds only visible rows, so always provide an
`itemCount` for finite lists and leave `shrinkWrap` disabled. Normal flings
through a one-million-item list remained within the UI frame budget on a Moto
G30 profile build.

When every row has a known height, provide `mainAxisExtent`. This uses a
fixed-extent sliver, avoids measuring each tile to determine its row height,
and allows distant scroll positions to be resolved without walking all
intervening rows:

```dart
AlignedGridView.count(
  crossAxisCount: 3,
  mainAxisExtent: 96,
  mainAxisSpacing: 8,
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

`mainAxisExtent` must be at least as large as every tile in the row. It is the
recommended configuration for very large lists that support direct jumps. For
known but varying row heights, provide `mainAxisExtentBuilder`. Its index is the
row index, not the item index:

```dart
AlignedGridView.count(
  crossAxisCount: 3,
  mainAxisExtentBuilder: (rowIndex) => rowExtents[rowIndex],
  mainAxisSpacing: 8,
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

This uses Flutter's varied-extent sliver fast path and requires `itemCount`.
For content-driven row heights, omit both extent options: large `jumpTo`
operations are expensive because Flutter must determine the heights of
intervening rows.

For state-free tiles, consider `addAutomaticKeepAlives: false` to reduce
memory. Keep `addRepaintBoundaries` enabled for visually complex or frequently
changing tiles; benchmark both settings for simple, static tiles. Adjust
`cacheExtent` only after measuring: a larger value can smooth fast flings but
uses more memory.
