module Benchmark.Suite.Monad
  (
  -- Types
    SuiteM
  , SuiteT
  -- General
  , runSuiteT
  ) where

import Prelude
import Control.Monad.ST as ST
import Control.Monad.Reader (runReaderT, ReaderT, class MonadReader)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (class MonadEff)
import Benchmark.Suite.ST as STS
import Benchmark.Suite.ST (STSuite)
import Benchmark.Suite (Suite, pureST)
import Data.Newtype (class Newtype)
import Unsafe.Coerce (unsafeCoerce)

-- Types
--------------------

type SuiteM s m e a =
  MonadReader (STSuite s) m => MonadEff (st :: ST.ST s | e) m => a

newtype SuiteT s e a = SuiteT (ReaderT (STSuite s) (Eff e) a)

-- Generalized Newtype Deriving Instances
--------------------

derive instance newtypeT :: Newtype (SuiteT s e a ) _
derive newtype instance functorSuiteT :: Functor (SuiteT s e)
derive newtype instance applySuiteT :: Apply (SuiteT s e)
derive newtype instance applicativeSuiteT :: Applicative (SuiteT s e)
derive newtype instance bindSuiteT :: Bind (SuiteT s e)
derive newtype instance monadSuiteT :: Monad (SuiteT s e)

derive newtype instance monadReaderSuiteT :: MonadReader (STSuite s) (SuiteT s e)
derive newtype instance monadEffSuiteT :: MonadEff e (SuiteT s e)

-- General
--------------------

runSuiteT :: forall s e a. SuiteT s (st :: ST.ST s | e) a -> Suite
runSuiteT (SuiteT m) = pureST do
  s <- STS.new
  let eff = (runReaderT m) (unsafeCoerce s)
  _ <- unsafeCoerce $ eff
  pure s
