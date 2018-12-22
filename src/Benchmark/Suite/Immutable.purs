-- | Contains functions that operate on `Suite`, which is an immutable
-- | representation of the Benchmark.js' suite object.
-- |
-- | Currently, there are no plans to add functions that modify the immutable
-- | `Suite` as that would require cloning the Suite on each operation.
-- | For this reason, typically you want to use `SuiteM` and
-- | `Benchmark.Suite.Monad`, which provide a monadic interface to a mutable
-- | representation of the suite object (`SuiteST s`).

module Benchmark.Suite.Immutable where

import Prelude (Unit)
import Effect (Effect)
import Unsafe.Coerce (unsafeCoerce)

import Benchmark.Suite (Suite)
import Benchmark.Suite.ST as STS

-- | Executes all benchmarks within the suite.
runSuite :: Suite -> Effect Unit
runSuite suite = STS.run (unsafeCoerce suite)
