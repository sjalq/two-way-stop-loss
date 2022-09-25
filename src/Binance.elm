module Binance exposing (..)

import Types exposing (..)  
import Http
import Crypto.HMAC exposing (..)
import BinanceDecoder exposing (..)
import Http exposing (Header)
import Task exposing (..)
import Json.Decode exposing (..)
import PrivateConfig exposing (apiConnection)
import Decimal exposing (Decimal)



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


signParams : Key -> Timestamp -> String -> String
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


getAccountInfo : ApiConnection -> Task Http.Error AccountInfo
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
                , resolver = Http.stringResolver <| handleJsonResponse <| accountInfoDecoder
                , timeout = Nothing
                }
    in
        getTimestampTask
        |> Task.andThen fetchAccountTask


getTimestampTask : Task Http.Error Timestamp
getTimestampTask =
    Http.task
        { method = "GET"
        , headers = []
        , url = proxy ++ baseUrl ++ "time"
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| timestampDecoder
        , timeout = Nothing
        }

fetchCurrentPostion : ApiConnection -> PositionConfig -> Task Http.Error (List Position)
fetchCurrentPostion apiConnection positionConfig =
    -- should return
    -- how much are in orders
    -- how much is free

--placePositions : ApiConnection -> PositionConfig -> Task Http.Error Position
placePositions apiConnection positionConfig =
    -- goals:
    -- 1. make sure we're on the right side of the market
    -- 2. make sure there's an appropriate stop loss at the right price
    -- logic:
    1

getPrice : String -> Task Http.Error SymbolPrice
getPrice symbol =
    Http.task
        { method = "GET"
        , headers = []
        , url = proxy ++ baseUrl ++ "ticker/price?symbol=" ++ symbol
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| symbalPriceDecoder
        , timeout = Nothing
        }

getOpenOrders : ApiConnection -> Task Http.Error (List OpenOrder)
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
                , resolver = Http.stringResolver <| handleJsonResponse <| openOrdersDecoder
                , timeout = Nothing
                }
    in
        getTimestampTask
        |> Task.andThen fetchOpenOrdersTask