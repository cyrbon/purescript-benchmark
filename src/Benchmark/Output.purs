-- | This module is responsible for printing the result of a benchmark

module Benchmark.Output
  ( printResultOnCycle
  ) where

import Prelude
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff (Eff)

import Benchmark.Suite.Monad (on, SuiteM)
import Benchmark.Event (BenchmarkEventName(..))
import Unsafe.Coerce (unsafeCoerce)

-- | Runs `console.log(String(a))`
foreign import toStringAndLog :: forall eff a.
  a -> Eff (console :: CONSOLE | eff) Unit

-- | Subscribes to Suite's `on("cycle"` event and outputs `String(event.target)`
-- | to console.
printResultOnCycle :: forall s e m.
  SuiteM s e m (m Unit)
printResultOnCycle = do
  on Cycle $ \e -> toStringAndLog (unsafeCoerce e).target
