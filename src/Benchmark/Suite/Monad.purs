module Benchmark.Suite.Monad
  (
  -- Types
    SuiteM
  , SuiteT
  -- General
  , runSuiteT
  -- API Wrappers
  , add
  , on
  , run
  , accumulateResults
  , runSuiteM
  ) where

import Prelude
import Control.Monad.ST as ST
import Control.Monad.Reader (runReaderT, ReaderT, class MonadReader, ask)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (class MonadEff, liftEff)
import Data.Newtype (class Newtype)
import Unsafe.Coerce (unsafeCoerce)

import Benchmark.Event (toString, BenchmarkEventName)
import Benchmark.Suite.ST as STS
import Benchmark.Suite.ST (STSuite, BenchmarkResult)
import Benchmark.Suite (Suite, pureST)
import Benchmark.Suite.Immutable as Immutable

-- Types
--------------------

type SuiteM s e m a =
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

-- | Runs SuiteM transformer stack. This is equal to executing `suite.run()`,
-- | where suite is constructed via the monad interface:
-- | >>> runSuiteM $ do
-- | >>>   add "functionOne" myFunction
-- | >>>   add "functionTwo" myFunctionTwo
-- |
-- | The code above will construct a suite with two functions to benchmark and
-- | run those benchmarks.
runSuiteM :: forall s e a.
  SuiteT s (st :: ST.ST s | e ) a -> Eff (st :: ST.ST s | e ) Unit
runSuiteM m = Immutable.runSuite $ runSuiteT m

-- Internal helpers
--------------------

-- | Converts an `f` with two argumens (first accepting `STSuite s`) into an `f`
-- | that uses SuiteM
asksSTSuiteA2 :: forall s m e a2 b.
     (STSuite s -> a2 -> Eff ( st :: ST.ST s | e ) b)
  -> (SuiteM s e m (a2 -> m b))
asksSTSuiteA2 fA2 a2 = do
  s <- ask
  liftEff $ fA2 s a2

-- | Converts an `f` with three arguments (first accepting `STSuite s`) into an i
-- | `f` that uses SuiteM
asksSTSuiteA3 :: forall s m e a2 a3 b.
     (STSuite s -> a2 -> a3 -> Eff ( st :: ST.ST s | e ) b)
  -> (SuiteM s e m (a2 -> a3 -> m b))
asksSTSuiteA3 fA3 a2 a3 = do
  s <- ask
  liftEff $ fA3 s a2 a3

-- Suite API wrappers
--------------------

-- | Adds a test to the benchmark suite. Takes a name to identify the benchmark,
-- | and the test to benchmark.
add :: forall s m e anyEff a. SuiteM s e m (String -> Eff anyEff a -> m Unit)
add = asksSTSuiteA3 STS.add

-- | Registers a listener for the specified event type(s).
on :: forall s m e anyEff.
  SuiteM s e m (BenchmarkEventName -> (STS.BenchmarkEvent -> Eff anyEff Unit) -> m Unit)
on evName cb = do
  s <- ask
  liftEff $ STS.on s (toString evName) cb

-- | Accumulates results of each cycle in an array. `onComplete` calls the
-- | provided callback with the array containing accumulated results.
accumulateResults :: forall s m e anyEff.
  SuiteM s e m ((Array BenchmarkResult -> Eff anyEff Unit) -> m Unit)
accumulateResults = asksSTSuiteA2 STS.accumulateResults

-- | Runs the suite. This can be used inside SuiteM. Most often, you want to use
-- | `runSuiteM` instead, because SuiteM is usually used to construct the suite
-- | and then once the suite is constructed it's run using `runSuiteM`. Using
-- | `run` will run the suite during the construction process.
run :: forall s m e. SuiteM s e m (m Unit)
run = do
  s <- ask
  liftEff $ STS.run s
