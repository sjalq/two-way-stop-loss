module Queries exposing (..)

import Decimal exposing (Decimal)
import Html.Attributes exposing (datetime)
import Iso8601 exposing (..)
import List.Extra
import Time
import Types exposing (AccountValueAtTime, BackendModel)


assetValueChange : BackendModel -> Decimal
assetValueChange model =
    let
        firstValue =
            model.accountValueOverTime
                |> List.map .value
                |> List.head

        lastValue =
            model.accountValueOverTime
                |> List.map .value
                |> List.Extra.last
    in
    Maybe.map2
        Decimal.sub
        lastValue
        firstValue
        |> Maybe.withDefault Decimal.zero


getAccountValuesOverTime : BackendModel -> Time.Posix -> Time.Posix -> List AccountValueAtTime
getAccountValuesOverTime model from to =
    model.accountValueOverTime
        |> List.filter
            (\accountValue ->
                Time.posixToMillis accountValue.time
                    >= Time.posixToMillis from
                    && Time.posixToMillis accountValue.time
                    <= Time.posixToMillis to
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
