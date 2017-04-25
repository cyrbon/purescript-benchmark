module Benchmark.Event where

data BenchmarkEventName = Abort | Complete | Cycle | Error | Start

-- | Defines that the underlying type represents a String. In other words, that
-- | `a` represents a subset of String values. If `Show` is designed to convert a
-- | to a human-readible representation, `IsString` says that this type is just
-- | there to represent a String, in whatever form that String might be.

-- | It might be the case that `show a` and `toString a` will return different
-- | values, especially if the Show instance was generated generically.
class IsString a where
  toString :: a -> String

instance benchmarkEventNameIsString :: IsString BenchmarkEventName where
  toString = case _ of
    Abort    -> "abort"
    Complete -> "complete"
    Cycle    -> "cycle"
    Error    -> "error"
    Start    -> "start"
