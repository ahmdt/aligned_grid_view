# aligned_grid_view

[![pub package](https://img.shields.io/pub/v/aligned_grid_view.svg)](https://pub.dev/packages/aligned_grid_view)

Flutter grids whose tiles share the height of the tallest tile in their row.

<img src="assets/example.png" alt="Aligned grid with content-driven row heights" width="400">

## Features

* Lazy, content-driven rows with equal tile heights.
* Fixed-column and responsive grid constructors.
* Sliver variants for `CustomScrollView`.
* Fast paths for known fixed or variable row extents.

## Getting started

```sh
flutter pub add aligned_grid_view
```

```dart
import 'package:flutter/material.dart';
import 'package:aligned_grid_view/aligned_grid_view.dart';
```

## Usage

### Fixed columns

Use `AlignedGridView.count` when the number of columns is known.

```dart
final grid = AlignedGridView.count(
  crossAxisCount: 3,
  mainAxisSpacing: 8,
  crossAxisSpacing: 8,
  itemCount: 100,
  itemBuilder: (context, index) => Text('Item $index'),
);
```

### Responsive columns

Use `AlignedGridView.extent` to keep tiles below a maximum width while adapting
the column count to the available space.

```dart
final grid = AlignedGridView.extent(
  maxCrossAxisExtent: 240,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  itemCount: 100,
  itemBuilder: (context, index) => Text('Item $index'),
);
```

### Slivers

Use `SliverAlignedGrid` with other slivers in a `CustomScrollView`.

```dart
final scrollView = CustomScrollView(
  slivers: [
    const SliverAppBar(title: Text('Catalog')),
    SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverAlignedGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: 100,
        itemBuilder: (context, index) => Text('Item $index'),
      ),
    ),
  ],
);
```

## Constructors

| Constructor | Use when |
| --- | --- |
| `AlignedGridView.count` | The cross-axis tile count is fixed. |
| `AlignedGridView.extent` | Tiles have a maximum cross-axis extent. |
| `AlignedGridView.custom` | Column calculation needs a custom `SliverSimpleGridDelegate`. |
| `SliverAlignedGrid.count` | A fixed column-count grid belongs in a `CustomScrollView`. |
| `SliverAlignedGrid.extent` | A responsive grid belongs in a `CustomScrollView`. |
| `SliverAlignedGrid` | A sliver needs a custom `SliverSimpleGridDelegate`. |

The built-in delegates are
`SliverSimpleGridDelegateWithFixedCrossAxisCount` and
`SliverSimpleGridDelegateWithMaxCrossAxisExtent`. Pass either to a `custom` or
default `SliverAlignedGrid` constructor, or implement `SliverSimpleGridDelegate`
for custom column calculation.

```dart
final grid = AlignedGridView.custom(
  gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
  ),
  itemCount: 100,
  itemBuilder: (context, index) => Text('Item $index'),
);
```

## Row sizing

By default, rows are content-driven: every tile is measured and the row uses
the largest resulting extent. This is the appropriate mode when tile content
varies naturally.

When every row has a known extent, provide `mainAxisExtent`. It must be at
least as large as every tile in the row and enables efficient distant jumps.

```dart
final grid = AlignedGridView.count(
  crossAxisCount: 3,
  mainAxisExtent: 96,
  itemCount: 100,
  itemBuilder: (context, index) => Text('Item $index'),
);
```

For known but varying row extents, provide `mainAxisExtentBuilder`. It receives
a row index, requires `itemCount`, and cannot be combined with
`mainAxisExtent`.

```dart
final grid = AlignedGridView.count(
  crossAxisCount: 3,
  mainAxisExtentBuilder: (rowIndex) => rowIndex.isEven ? 96 : 144,
  itemCount: 100,
  itemBuilder: (context, index) => Text('Item $index'),
);
```

The same row-sizing options are available on every `SliverAlignedGrid`
constructor. Extents from `mainAxisExtentBuilder` are cached while its callback,
the item count, and main-axis spacing remain unchanged.


## Options

* `itemBuilder` lazily builds tiles. Supply `itemCount` for finite grids.
* `mainAxisSpacing` and `crossAxisSpacing` control the gaps between tiles.
* `addAutomaticKeepAlives` and `addRepaintBoundaries` default to `true`.
* `AlignedGridView` also supports standard `ScrollView` options such as
  `controller`, `scrollDirection`, `padding`, `physics`, and `shrinkWrap`.

## Additional information

See the [example app](example), [API documentation](https://pub.dev/documentation/aligned_grid_view/latest/), and [benchmark notes](benchmark.md).
Report issues at [GitHub](https://github.com/ahmdt/aligned_grid_view/issues).

This package is licensed under the [MIT License](LICENSE).
