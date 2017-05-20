# purescript-benchmark

Simple to use, cross-platform benchmarking library based on `benchmark.js`.

Supports both node and browser environments. Mobile (JS bridge) support was not
tested, yet.

By default it prints statistics to console as a pretty ASCII table (for
cross-platform compatibility), but it can be easily extended to support more
sophisticated visualization by accumulating stats as JSON.

The monadic interface exposes the `Suite` provided by `Benchmark.js`, making
it simple to start with and extend, if you know `Benchmark.js`. Other primitives
are built on top of that to provide easy-to-use end API.

## Installation

```
bower install purescript-benchmark
```

## Documentation

Module documentation is published on [Pursuit](https://pursuit.purescript.org/packages/purescript-benchmark/).

## Usage

Ready-to-clone environment with a full example can be found in
[purescript-benchmark-template](https://github.com/cyrbon/purescript-benchmark-template).
The template project uses [rollup](https://github.com/Pauan/rollup-plugin-purs)
to provide additional optimizations (like uncurry, inlining and dead-code
elimination) and dramatically reduce bundle size. The example shows how to use it
in both browser and node environments.

It is recommended that you use
[`rollup-plugin-purs`](https://github.com/Pauan/rollup-plugin-purs) to improve
performance and produce accurate benchmarks.

```purescript
import Benchmark
import Control.Monad.ST (ST)

main :: forall s. Eff (st :: ST s) Unit
main = runBench $ do
  fn "simple addition" (_ + 42) 8
  fn "addition and mult" (_ + 42 / 2 * 2 * 2) 8
```

This will print the following table:

```
+-------------------+-------------+-------+-------+
| Name              | Op/s        | % max | +-(%) |
+-------------------+-------------+-------+-------+
| simple addition   | 77591960.67 | 100   | 1.01  |
| addition and mult | 50001106.52 | 64.44 | 0.80  |
+-------------------+-------------+-------+-------+
```

## Comparison to other libraries

Compared to `purescript-benchotron`, it does not force you to use `QuickCheck`
and provides a simpler API that exposes `Benchmark.js`'s primitives like Suite.

Compared to `beautify-benchmark` that requires `node` for printing results,
it does printing itself using only `console.log`, making it work in different
environments. Also, results are printed as a full ASCII table which
improves readability, and percentage values are included in the table by default.
