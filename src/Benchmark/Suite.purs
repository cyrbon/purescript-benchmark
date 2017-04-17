-- | Benchmark.Suite wrapper

module Benchmark.Suite
  ( Suite
  , copy
  , thawST
  , freezeST
  , runST
  ) where

import Control.Monad.ST as ST
import Control.Monad.Eff (Eff)
import Benchmark.Suite.ST (STSuite)

foreign import data Suite :: Type

foreign import _copy :: forall a b h e. a -> Eff (st :: ST.ST h | e) b

-- | Copy a mutable Suite
copy :: forall h e. STSuite h -> Eff (st :: ST.ST h | e) (STSuite h)
copy = _copy

-- | Convert an immutable Suite to a mutable Suite
thawST :: forall h e. Suite -> Eff (st :: ST.ST h | e) (STSuite h)
thawST = _copy

-- | Convert a mutable Suite to an immutable Suite
freezeST :: forall h e. STSuite h -> Eff (st :: ST.ST h | e) Suite
freezeST = _copy

-- | Freeze a mutable Suite object, creating an immutable object. Use this
-- | function as you would use `Prelude.runST` to freeze a mutable reference.
-- |
-- | The rank-2 type prevents the map from escaping the scope of `runST`.
foreign import runST :: forall e.
  (forall h. Eff (st :: ST.ST h | e) (STSuite h)) -> Eff e Suite
