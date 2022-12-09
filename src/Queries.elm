module Queries exposing (..)

import Types exposing (BackendModel)
import Decimal exposing (Decimal)
import List.Extra
import Types exposing (AccountValueAtTime)
import Html.Attributes exposing (datetime)
import Iso8601 exposing (..)
import Time

assetValueChange : BackendModel -> Decimal
assetValueChange model =
    let
        firstValue = 
            model.accountValueOverTime 
            |> List.map .value 
            |> List.filter (\value -> (value |> Decimal.toFloat) > 100000.0)
            |> List.head 
            |> Maybe.withDefault Decimal.zero
        lastValue = 
            model.accountValueOverTime 
            |> List.map .value 
            |> List.Extra.last 
            |> Maybe.withDefault Decimal.zero
    in
        firstValue |> Decimal.sub lastValue


getAccountValuesOverTime : BackendModel -> Time.Posix -> Time.Posix -> List AccountValueAtTime
getAccountValuesOverTime model from to =
    model.accountValueOverTime 
        |> List.filter (
            \accountValue -> 
                (Time.posixToMillis accountValue.time) >= (Time.posixToMillis from)
                && (Time.posixToMillis accountValue.time) <= (Time.posixToMillis to)
        )

getPnL : BackendModel -> String
getPnL model =
    let
        firstValue = 
            model.accountValueOverTime 
            |> List.map .value 
            |> List.filter (\value -> (value |> Decimal.toFloat) > 100000.0)
            |> List.head 
            |> Maybe.withDefault Decimal.zero
        lastValue = 
            model.accountValueOverTime 
            |> List.map .value 
            |> List.Extra.last 
            |> Maybe.withDefault Decimal.zero
    in
        firstValue |> Decimal.sub lastValue |> Decimal.toString