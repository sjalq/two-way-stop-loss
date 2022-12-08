module Queries exposing (..)

import Types exposing (BackendModel)
import Decimal exposing (Decimal)
import List.Extra

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
