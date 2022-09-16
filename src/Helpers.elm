module Helpers exposing (..)

import Decimal exposing (Decimal)
import Html exposing (text)
import Html exposing (Html)
import Html exposing (a)

mapWithDefault : (a -> b) -> b -> Maybe a -> b
mapWithDefault fn def =
    Maybe.map fn >> Maybe.withDefault def

mapStringOrBlank : (a -> String) -> Maybe a -> String
mapStringOrBlank fn =
    mapWithDefault fn ""

mapDecimalDefault : (a -> Decimal) -> String -> Maybe a -> String
mapDecimalDefault fn def =
    mapWithDefault (fn >> Decimal.toString) def

mapDecimalOrZero : (a -> Decimal) -> Maybe a -> String
mapDecimalOrZero fn =
    mapDecimalDefault fn "0"

mapDecimalOrBlank : (a -> Decimal) -> Maybe a -> String
mapDecimalOrBlank fn =
    mapWithDefault (fn >> Decimal.toString) ""