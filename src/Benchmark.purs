module Benchmark
  ( module Benchmark.Suite.Monad
  , module Benchmark.Output
  , module Suite
  , module STModule
  ) where

import Benchmark.Suite.Monad
import Benchmark.Suite (Suite) as Suite
import Benchmark.Suite.ST (BenchmarkResult) as STModule
import Benchmark.Output

import Prelude hiding (add)
import Control.Monad.ST as ST
import Control.Monad.Eff (Eff)

runBench :: forall s m e a.
  SuiteT s (st :: ST.ST s | e ) a -> Eff (st :: ST.ST s | e ) Unit
runBench m = runSuiteM $ m *> printResultTableOnComplete
