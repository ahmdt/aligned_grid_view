# Scroll Benchmark

This benchmark compares `AlignedGridView` with a functionally equivalent
Flutter baseline: a lazy `ListView.separated` whose rows use `IntrinsicHeight`
and `Row(crossAxisAlignment: CrossAxisAlignment.stretch)` to align every tile
to the tallest tile in its row.

It uses four columns with constant 96-pixel tiles and deterministic varied tile
heights (56 to 272 pixels). Every variant records two independent frame-timing
reports:

* Six forward flings at 4,000 pixels per second across one million items.
* Direct jumps to 25%, 50%, 90%, and back to 10% across 10,000 items.
* The same jump sequence across one million uniform-height items using
  `mainAxisExtent`.

Run it on the connected Moto G30 in profile mode:

```sh
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/scroll_benchmark_test.dart \
  --profile \
  --no-dds \
  --device-id=ZT3225CDWF
```

The command writes `build/integration_response_data.json`. Compare reports
with matching suffixes, for example `aligned_varied_fling` and
`intrinsicRowBaseline_varied_fling`. The report contains UI and raster frame
averages/P90/P99, missed frame-budget counts, and new/old generation GC counts.
Use DevTools Memory alongside each run to record peak memory. The Moto G30 has
a 90 Hz display, so its frame budget is 11.1 ms.

Run the suite after a cold start, with the device unplugged from unnecessary
debugging tools and without other foreground apps. Repeat each run at least
three times; discard the first run if shader compilation materially affects it.

`AlignedGridView` is intentionally measured against a baseline that preserves
the same row-alignment contract. A stock `GridView` is not an equivalent
baseline because it requires a known tile extent and cannot derive every row's
height from its tallest child.

Do not run far `jumpTo` operations against a one-million-item scenario with
content-driven row heights. `SliverList` has no index-to-offset mapping for
variable row extents and must walk and lay out intervening rows to resolve such
a jump. On the Moto G30, a 25% jump exhausted the Dart heap before completing;
this is a documented scalability limit of that mode, not a benchmark result to
average with normal scrolling.

Use the `aligned_uniform_fixed_extent_large_jump` report to validate the
one-million-item jump fast path. It is intentionally limited to uniform rows;
variable, content-driven row heights still use `SliverList`.

## Previous Moto G30 Result

One profile run on Android 12 produced the following UI build times in
milliseconds. These values are directional only; repeat the run three times
before using them as a release gate.

| Scenario | Aligned avg / P90 / P99 | Baseline avg / P90 / P99 |
| --- | --- | --- |
| 1M uniform fling | 2.24 / 5.49 / 10.10 | 2.65 / 6.09 / 8.90 |
| 1M varied fling | 2.21 / 4.63 / 5.69 | 2.07 / 4.18 / 5.92 |
| 10K uniform jump | 131.03 / 221.85 / 431.53 | 178.73 / 286.13 / 593.48 |
| 10K varied jump | 156.07 / 250.33 / 447.82 | 200.30 / 310.75 / 633.82 |

The fling cases had no missed UI build budget according to Flutter's report.
`AlignedGridView` was comparable to or better than the equivalent baseline for
normal scrolling. Its uniform fling had one 20.07 ms raster outlier; the
varied case had none. Every jump case missed the budget four times because a
large jump requires `SliverList` to traverse intervening variable-height rows.

## Fixed-Extent Result

After enabling `mainAxisExtent`, the four direct jumps across one million
uniform-height items completed without a heap error. UI build time was 6.30 ms
on average, 10.75 ms at P90, and 11.15 ms at P99; no UI or raster frame budget
was missed. The run recorded two new-generation and two old-generation GCs.

## RatPhone17 Large Data Set Result

This benchmark uses the real card structure from the **Large Data Set** example:
1,000 cards, 20-pixel outer padding, a 240-pixel maximum tile extent, and
16-pixel gaps. On the RatPhone17 it produces two columns. The card distribution
is deterministic: one long card, one medium card, then ten short cards. The
baseline is a lazy `ListView.separated` of stretched two-card rows with
`IntrinsicHeight`, preserving the same tallest-card-per-row contract.

Each target performs six 4,000-pixel-per-second forward flings. The following
values are the median of three successful profile runs on an iPhone 17
(`iPhone18,3`, iOS 26.6). Each run captured 335 frames; neither implementation
missed a UI or raster frame budget.

| Implementation | UI avg / P90 / P99 / worst (ms) | Raster avg / P90 / P99 / worst (ms) | New / old GC |
| --- | --- | --- | --- |
| `AlignedGridView.extent` | 2.055 / 3.739 / 4.992 / 5.331 | 1.042 / 1.198 / 1.457 / 1.548 | 110 / 20 |
| `ListView` + `IntrinsicHeight` baseline | 0.858 / 2.224 / 3.558 / 3.688 | 1.055 / 1.207 / 1.481 / 1.633 | 58 / 16 |

This initial result exposed scroll-dependent grid rebuilding and additional
sliver children for row gaps. After removing those costs, disabling automatic
keep-alives for the state-free cards in both targets, and avoiding per-build
card-data allocations, the same benchmark was repeated three times:

| Implementation | UI avg / P90 / P99 / worst (ms) | Raster avg / P90 / P99 / worst (ms) | New / old GC |
| --- | --- | --- | --- |
| Optimized `AlignedGridView.extent` | 0.699 / 1.964 / 3.185 / 3.479 | 0.945 / 1.095 / 1.418 / 1.549 | 46 / 14 |
| Optimized `ListView` + `IntrinsicHeight` baseline | 0.804 / 2.325 / 3.620 / 4.174 | 0.966 / 1.103 / 1.371 / 1.520 | 46 / 14 |

The optimized aligned grid reduced its average UI time by 66% and its
new-generation GC count by 58% compared with the initial run. It was 13% faster
than the equally optimized baseline on average, with 12% lower UI P99. Raster
timings remained nearly identical and neither implementation missed a UI or
raster frame budget. The optional `mainAxisExtentBuilder` fast path was not
used here because the real text cards have content-driven heights.

This result describes this specific viewport and card distribution; retain the
synthetic large-list suite for its separate scrolling and far-jump coverage.

Run the two targets separately, because each command overwrites
`build/integration_response_data.json`:

```sh
flutter drive --no-dds --profile \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/large_data_set_aligned_benchmark_test.dart \
  --device-id=00008150-000649682193401C

flutter drive --no-dds --profile \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/large_data_set_baseline_benchmark_test.dart \
  --device-id=00008150-000649682193401C
```
