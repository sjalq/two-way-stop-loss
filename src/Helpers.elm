module Helpers exposing (..)

import Decimal exposing (Decimal)
import Html exposing (text)
import Html exposing (Html)

mapWithDefault : (a -> b) -> b -> Maybe a -> b
mapWithDefault fn def =
    Maybe.map fn >> Maybe.withDefault def

mapStringOrBlank : (String -> b) -> String -> Maybe String -> b
mapStringOrBlank fn =
    mapWithDefault fn ""

mapDecimalDefault : (a -> Decimal) -> String -> Maybe a -> String
mapDecimalDefault fn def =
    mapWithDefault (fn >> Decimal.toString) def

mapDecimalOrZero : (a -> Decimal) -> Maybe a -> String
mapDecimalOrZero fn =
    mapDecimalDefault fn "0"

mapDecimalOrBlank : (a -> String) -> Maybe a -> String
mapDecimalOrBlank fn =
    mapWithDefault fn ""
