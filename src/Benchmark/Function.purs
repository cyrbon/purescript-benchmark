module Benchmark.Function where

import Prelude (Unit)
import Effect (Effect)

foreign import fn1 :: forall a b. (a -> b) -> a -> Effect Unit
