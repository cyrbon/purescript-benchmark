-- | Benchmark.Suite wrapper

module Benchmark.Suite
  ( Suite
  , copy
  , thawST
  , freezeST
  , runST
  , pureST
  , mutate
  ) where

import Prelude
import Effect (Effect)
import Effect.Unsafe (unsafePerformEffect)
import Benchmark.Suite.ST (STSuite)

foreign import data Suite :: Type
foreign import _copy :: forall a b. a -> Effect b

-- | Copy a mutable Suite
copy :: forall h. STSuite h -> Effect (STSuite h)
copy = _copy

-- | Convert an immutable Suite to a mutable Suite
thawST :: forall h. Suite -> Effect (STSuite h)
thawST = _copy

-- | Convert a mutable Suite to an immutable Suite
freezeST :: forall h. STSuite h -> Effect Suite
freezeST = _copy

-- | Freeze a mutable Suite object, creating an immutable object. Use this
-- | function as you would use `Prelude.runST` to freeze a mutable reference.
-- |
-- | The rank-2 type prevents the map from escaping the scope of `runST`.
foreign import runST ::
 (forall h. Effect (STSuite h)) -> Effect Suite

pureST :: (forall s. Effect (STSuite s)) -> Suite
pureST f = unsafePerformEffect (runST f)

mutate :: forall b. (forall s. STSuite s -> Effect b)
  -> Suite
  -> Suite
mutate f suiteST = pureST do
  s <- thawST suiteST
  _ <- f s
  pure s
