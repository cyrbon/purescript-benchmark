module Benchmark.Suite.ST where

import Prelude (Unit)
import Control.Monad.Eff (Eff)
import Control.Monad.ST (ST)

foreign import data STSuite :: Type -> Type
foreign import data BenchmarkEvent :: Type

-- API
--------------------

foreign import new :: forall h r. Eff (st :: ST h | r) (STSuite h)

foreign import add :: forall s e anyEff a.
  STSuite s -> String -> (Eff anyEff a) -> Eff (st :: ST s | e) Unit

foreign import run :: forall h e. STSuite h -> Eff (st :: ST h | e) Unit

foreign import on :: forall h e anyEff.
  STSuite h -> String -> (BenchmarkEvent -> Eff anyEff Unit) -> Eff (st :: ST h | e) Unit

-- Extra
--------------------

type BenchmarkResult =
  { name :: String
  , hz :: Number
  , stats :: {
      rme :: Number
    }
  }

foreign import accumulateResults :: forall s e anyEff.
  STSuite s -> (Array BenchmarkResult -> Eff anyEff Unit) -> Eff (st :: ST s | e) Unit
