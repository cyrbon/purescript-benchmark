module Benchmark.Function where

import Prelude (Unit)
import Control.Monad.Eff (Eff)

foreign import fn1 :: forall a b e. (a -> b) -> a -> Eff e Unit
