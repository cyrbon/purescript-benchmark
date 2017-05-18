module Benchmark
  ( module Benchmark.Suite.Monad
  , module Benchmark.Output
  , module Benchmark.Function
  , module Suite
  , module STModule
  , runBench
  , fnEff
  , fn
  ) where

import Benchmark.Suite.Monad (SuiteM, SuiteT, accumulateResults, add, on, run,
         runSuiteM, runSuiteT)
import Benchmark.Suite (Suite) as Suite
import Benchmark.Suite.ST (BenchmarkResult) as STModule
import Benchmark.Output (printResultOnCycle, printResultTableOnComplete)
import Benchmark.Function (fn1)

import Prelude (Unit, ($), (*>))
import Control.Monad.ST as ST
import Control.Monad.Eff (Eff)

-- | Runs the benchmark suite and print results. Use `fn` and `fnEff` inside the 
-- | monadic interface to add functions to the suite.
-- | >>> runBench $ do
-- | >>>   fn    "function name"     (_ + 40) 2
-- | >>>   fnEff "eff function name" (log "eff function executed")
runBench :: forall s e a.
  SuiteT s (st :: ST.ST s | e ) a -> Eff (st :: ST.ST s | e ) Unit
runBench m = runSuiteM $ m *> printResultTableOnComplete

fnEff :: forall s m e anyEff a. SuiteM s e m (String -> Eff anyEff a -> m Unit)
fnEff = add

fn :: forall s m e a b. SuiteM s e m (String -> (a -> b) -> a -> m Unit)
fn s f a = add s (fn1 f a)
