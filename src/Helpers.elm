module Helpers exposing (..)

import Decimal exposing (Decimal)

mapWithDefault : (a -> b) -> b -> Maybe a -> b
mapWithDefault fn def =
    Maybe.map fn >> Maybe.withDefault def

mapToDecimalStringOrDefault : (a -> Decimal) -> String -> Maybe a -> String
mapToDecimalStringOrDefault fn def =
    mapWithDefault (fn >> Decimal.toString) def

mapToDecimalStringOrZero : (a -> Decimal) -> Maybe a -> String
mapToDecimalStringOrZero fn =
    mapToDecimalStringOrDefault fn "0"