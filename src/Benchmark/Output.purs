-- | This module is responsible for printing the result of a benchmark

module Benchmark.Output
  ( printResultOnCycle
  , printResultTableOnComplete
  ) where

import Prelude
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff (Eff)
import Data.Foldable (maximum)
import Data.Traversable (for_, class Foldable)
import Data.Newtype.Operator ((^))

import Benchmark.Suite.Monad (SuiteM, on, accumulateResults)
import Benchmark.Event (BenchmarkEventName(..))
import Unsafe.Coerce (unsafeCoerce)
import Global.Unsafe (unsafeToFixed)
import Data.Int (round)
import Data.Maybe (fromJust)
import Partial.Unsafe (unsafePartial)
import Data.String (length)

-- | Runs `console.log(String(a))`
foreign import toStringAndLog :: forall eff a.
  a -> Eff (console :: CONSOLE | eff) Unit

foreign import fillSpace :: Int -> String -> String
foreign import createLine :: Int -> String

-- | Subscribes to Suite's `on("cycle"` event and outputs `String(event.target)`
-- | to console.
printResultOnCycle :: forall s e m.
  SuiteM s e m (m Unit)
printResultOnCycle = do
  on Cycle $ \e -> toStringAndLog (unsafeCoerce e).target

-- | Accumulate benchmark results on each cycle, and onComplete print a table
-- | containing all results.
printResultTableOnComplete :: forall s e m.
  SuiteM s e m (m Unit)
printResultTableOnComplete = do
  accumulateResults $ \results -> do
    let max :: forall a f. Ord a => Foldable f => f a -> a
        max s = unsafePartial $ fromJust $ maximum s
        highestHz = max $ (_^_.hz) <$> results
        calcPercent n = n / highestHz * 100.0
	strPercent n =
          let n' = calcPercent n
	  in unsafeToFixed (if (round n') < 100 then 2 else 0) n'
        resultRows = flip map results $ \r ->
		        { name: r^_.name
	                , hz: unsafeToFixed 2 (r^_.hz)
		        , percentage: strPercent $ r^_.hz
	                , rme: (unsafeToFixed 2) (r^_.stats.rme)
	                }
	maxLenName = max $ (\s -> length $ s.name ) <$> resultRows
        maxLenHz = max $ (\s -> length $ s.hz ) <$> resultRows
        maxLenPercentage = max $ (\s -> length $ s.percentage ) <$> resultRows
	rmeHeaderName = "+-(%)"
        maxLenRme = let lenRme = max $ (\s -> length $ s.rme ) <$> resultRows
			lenRmeHeaderName = length rmeHeaderName
		    in
                    if lenRme > lenRmeHeaderName then lenRme else lenRmeHeaderName

        nameHeader = fillSpace maxLenName "Name"
        hzHeader = fillSpace maxLenHz "Op/s"
	percentageHeader = fillSpace maxLenPercentage "% max"
	rmeHeader = fillSpace maxLenRme "+-(%)"

	tableLine = "+" <> (createLine $ maxLenName + 2) <> "+" <> (createLine $ maxLenHz + 2)
                    <> "+" <> (createLine $ maxLenPercentage + 2) <> "+"
		    <> (createLine $ maxLenRme + 2) <> "+"

        genRow :: String -> String -> String -> String -> String
	genRow c1 c2 c3 c4 = "| " <> c1 <> " | " <> c2 <> " | " <> c3 <> " | "
                             <> c4 <> " |"

    log tableLine
    log $ genRow nameHeader hzHeader percentageHeader rmeHeader
    log tableLine

    for_ resultRows $ \r -> do
      let nameCol = fillSpace maxLenName r.name
	  hzCol = fillSpace maxLenHz r.hz
          percentageCol = fillSpace maxLenPercentage r.percentage
          rmeCol = fillSpace maxLenRme r.rme
      log $ genRow nameCol hzCol percentageCol rmeCol

    log tableLine
