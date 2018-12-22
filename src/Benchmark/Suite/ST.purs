module Benchmark.Suite.ST where

import Prelude (Unit)
import Effect (Effect)

foreign import data STSuite :: Type -> Type
foreign import data BenchmarkEvent :: Type

-- API
--------------------

foreign import new :: forall h. Effect (STSuite h)

foreign import add :: forall s a.
  STSuite s -> String -> (Effect a) -> Effect Unit

foreign import run :: forall h. STSuite h -> Effect Unit

foreign import on :: forall h.
  STSuite h -> String -> (BenchmarkEvent -> Effect Unit) -> Effect Unit

-- Extra
--------------------

type BenchmarkResult =
  { name :: String
  , hz :: Number
  , stats :: {
      rme :: Number
    }
  }

foreign import accumulateResults :: forall s.
  STSuite s -> (Array BenchmarkResult -> Effect Unit) -> Effect Unit
