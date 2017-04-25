module Benchmark.Suite.ST where

import Prelude (Unit)
import Control.Monad.Eff (Eff)
import Control.Monad.ST (ST)

foreign import data STSuite :: Type -> Type
foreign import data BenchmarkEvent :: Type

foreign import new :: forall h r. Eff (st :: ST h | r) (STSuite h)

foreign import add :: forall a b h e.
  STSuite h -> String -> (Eff e Unit) -> Eff (st :: ST h | e) Unit

foreign import run :: forall h e. STSuite h -> Eff (st :: ST h | e) Unit

foreign import on :: forall a b h e.
  STSuite h -> String -> (BenchmarkEvent -> Eff e Unit) -> Eff (st :: ST h | e) Unit
