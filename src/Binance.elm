module Binance exposing (..)


import Types exposing (..)  
import Http
import Crypto.HMAC exposing (..)
import Http exposing (Header)
import Task exposing (..)
import Json.Decode exposing (..)
import PrivateConfig exposing (apiConnection)
import Decimal exposing (Decimal)
import JsonTranslation.Time exposing (..)
import JsonTranslation.AccountInfo exposing (..)
import JsonTranslation.SymbolPrice exposing (..)
import JsonTranslation.DeleteOpenOrders exposing (..)
import JsonTranslation.OpenOrders

proxy : String
proxy = 
    --"" 
    "http://localhost:8001/"


baseUrl : String
baseUrl =  
    --"https://api.binance.com/api/v3/"
    "https://testnet.binance.vision/api/v3/"


handleJsonResponse : Decoder a -> Http.Response String -> Result Http.Error a
handleJsonResponse decoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.BadStatus_ { statusCode } _ ->
            Err (Http.BadStatus statusCode)

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.GoodStatus_ _ body ->
            case Json.Decode.decodeString decoder body of
                Err _ ->
                    Err (Http.BadBody body)

                Ok result ->
                    Ok result


signParams : Key -> JsonTranslation.Time.Root -> String -> String
signParams secretKey timestamp paramString = 
    let 
        sign = digest sha256 secretKey
        timestampedParams = 
           paramString 
            ++ (if paramString == "" then "" else "&")
            ++ "recvWindow=60000"
            ++ "&timestamp=" ++ (String.fromInt timestamp.serverTime) 
    in
        timestampedParams ++ "&signature=" ++ sign timestampedParams


getAccountInfo : ApiConnection -> Task Http.Error JsonTranslation.AccountInfo.Root
getAccountInfo apiConnection =
    let
        signedParams timestamp = signParams apiConnection.secret timestamp ""
        fetchAccountTask timestamp = 
            Http.task
                { method = "GET"
                , headers = 
                    [ Http.header "X-MBX-APIKEY" apiConnection.key 
                    , Http.header "Content-Type" "application/json" 
                    ]
                , url = proxy ++ baseUrl ++ "account" ++ "?" ++ signedParams timestamp
                , body = Http.emptyBody
                , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.AccountInfo.rootDecoder
                , timeout = Nothing
                }
    in
        getTimestampTask
        |> Task.andThen fetchAccountTask


getTimestampTask : Task Http.Error JsonTranslation.Time.Root
getTimestampTask =
    Http.task
        { method = "GET"
        , headers = []
        , url = proxy ++ baseUrl ++ "time"
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.Time.rootDecoder
        , timeout = Nothing
        }

getPrice : String -> Task Http.Error JsonTranslation.SymbolPrice.Root
getPrice symbol =
    Http.task
        { method = "GET"
        , headers = []
        , url = proxy ++ baseUrl ++ "ticker/price?symbol=" ++ symbol
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.SymbolPrice.rootDecoder
        , timeout = Nothing
        }

cancelAllOpenOrders : ApiConnection -> String -> Task Http.Error JsonTranslation.DeleteOpenOrders.Root
cancelAllOpenOrders apiConnection symbol =
    let
        signedParams timestamp = signParams apiConnection.secret timestamp ("symbol=" ++ symbol)
        cancelAllOpenOrdersTask timestamp = 
            Http.task
                { method = "DELETE"
                , headers = 
                    [ Http.header "X-MBX-APIKEY" apiConnection.key 
                    , Http.header "Content-Type" "application/json" 
                    ]
                , url = proxy ++ baseUrl ++ "openOrders" ++ "?" ++ signedParams timestamp
                , body = Http.emptyBody
                , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.DeleteOpenOrders.rootDecoder
                , timeout = Nothing
                }
    in
        getTimestampTask
        |> Task.andThen cancelAllOpenOrdersTask

getOpenOrders : ApiConnection -> Task Http.Error (List JsonTranslation.OpenOrders.RootObject)
getOpenOrders apiConnection =
    let
        signedParams timestamp = signParams apiConnection.secret timestamp ""
        fetchOpenOrdersTask timestamp = 
            Http.task
                { method = "GET"
                , headers = 
                    [ Http.header "X-MBX-APIKEY" apiConnection.key 
                    , Http.header "Content-Type" "application/json" 
                    ]
                , url = proxy ++ baseUrl ++ "openOrders" ++ "?" ++ signedParams timestamp
                , body = Http.emptyBody
                , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.OpenOrders.rootObjectDecoder
                , timeout = Nothing
                }
    in
        getTimestampTask
        |> Task.andThen fetchOpenOrdersTask


-- This function makes sure that if the price is below the position config up stop
-- that we are in cash and if the price is above the down stop, that we are in the asset
calculateOrder : PositionConfig -> Decimal -> JsonTranslation.AccountInfo.Root -> Maybe Order
calculateOrder positionConfig price accountInfo =
    let
        -- invariants:
        -- if the price is below the down stop, then need to be in cash
        --      if there is no stop loss, place one at the up stop
        -- if the price is above the up stop, then need to be in the asset
        --      if there is no stop loss, place one at the down stop

        belowDownStop = price < positionConfig.downStop.limitPrice
        aboveUpStop = price > positionConfig.upStop.limitPrice
        
    in
        maybeOrder