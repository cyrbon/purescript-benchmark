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
import Control.Monad.Reader (runReaderT, ask, ReaderT, class MonadReader, class MonadAsk)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Data.Newtype (class Newtype)
import Unsafe.Coerce (unsafeCoerce)

import Benchmark.Event (toString, BenchmarkEventName)
import Benchmark.Suite.ST as STS
import Benchmark.Suite.ST (STSuite, BenchmarkResult)
import Benchmark.Suite (Suite, pureST)
import Benchmark.Suite.Immutable as Immutable

-- Types
--------------------

type SuiteM s m a =
  MonadReader (STSuite s) m => MonadEffect m => a

newtype SuiteT s a = SuiteT (ReaderT (STSuite s) Effect a)

-- Generalized Newtype Deriving Instances
--------------------

derive instance newtypeT :: Newtype (SuiteT s a ) _
derive newtype instance functorSuiteT :: Functor (SuiteT s)
derive newtype instance applySuiteT :: Apply (SuiteT s)
derive newtype instance applicativeSuiteT :: Applicative (SuiteT s)
derive newtype instance bindSuiteT :: Bind (SuiteT s)
derive newtype instance monadSuiteT :: Monad (SuiteT s)
derive newtype instance monadAskSuiteT :: MonadAsk (STSuite s) (SuiteT s)
derive newtype instance monadReaderSuiteT :: MonadReader (STSuite s) (SuiteT s)
derive newtype instance monadEffSuiteT :: MonadEffect (SuiteT s)

-- General
--------------------

runSuiteT :: forall s a. SuiteT s a -> Suite
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
runSuiteM :: forall s a.
  SuiteT s a -> Effect Unit
runSuiteM m = Immutable.runSuite $ runSuiteT m

-- Internal helpers
--------------------

-- | Converts an `f` with two argumens (first accepting `STSuite s`) into an `f`
-- | that uses SuiteM
asksSTSuiteA2 :: forall s m a2 b.
     (STSuite s -> a2 -> Effect b)
  -> (SuiteM s m (a2 -> m b))
asksSTSuiteA2 fA2 a2 = do
  s <- ask
  liftEffect $ fA2 s a2

-- | Converts an `f` with three arguments (first accepting `STSuite s`) into an i
-- | `f` that uses SuiteM
asksSTSuiteA3 :: forall s m a2 a3 b.
     (STSuite s -> a2 -> a3 -> Effect b)
  -> (SuiteM s m (a2 -> a3 -> m b))
asksSTSuiteA3 fA3 a2 a3 = do
  s <- ask
  liftEffect $ fA3 s a2 a3

-- Suite API wrappers
--------------------

-- | Adds a test to the benchmark suite. Takes a name to identify the benchmark,
-- | and the test to benchmark.
add :: forall s m a. SuiteM s m (String -> Effect a -> m Unit)
add = asksSTSuiteA3 STS.add

-- | Registers a listener for the specified event type(s).
on :: forall s m.
  SuiteM s m (BenchmarkEventName -> (STS.BenchmarkEvent -> Effect Unit) -> m Unit)
on evName cb = do
  s <- ask
  liftEffect $ STS.on s (toString evName) cb

-- | Accumulates results of each cycle in an array. `onComplete` calls the
-- | provided callback with the array containing accumulated results.
accumulateResults :: forall s m.
  SuiteM s m ((Array BenchmarkResult -> Effect Unit) -> m Unit)
accumulateResults = asksSTSuiteA2 STS.accumulateResults

-- | Runs the suite. This can be used inside SuiteM. Most often, you want to use
-- | `runSuiteM` instead, because SuiteM is usually used to construct the suite
-- | and then once the suite is constructed it's run using `runSuiteM`. Using
-- | `run` will run the suite during the construction process.
run :: forall s m. SuiteM s m (m Unit)
run = do
  s <- ask
  liftEffect $ STS.run s
