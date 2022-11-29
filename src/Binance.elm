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
import JsonTranslation.OpenOrders exposing (..)
import JsonTranslation.PlaceOrder exposing (..)

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

getSymbolPrice : String -> Task Http.Error JsonTranslation.SymbolPrice.Root
getSymbolPrice symbol =
    Http.task
        { method = "GET"
        , headers = []
        , url = proxy ++ baseUrl ++ "ticker/price?symbol=" ++ symbol
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.SymbolPrice.rootDecoder
        , timeout = Nothing
        }

cancelAllOpenOrders : ApiConnection -> String -> Task Http.Error (List JsonTranslation.DeleteOpenOrders.Root)
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
                , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.OpenOrders.rootDecoder
                , timeout = Nothing
                }
    in
        getTimestampTask
        |> Task.andThen fetchOpenOrdersTask


sideToString : OrderSide -> String
sideToString side =
    case side of
        Buy ->
            "BUY"

        Sell ->
            "SELL"

placeStopLossOrder : 
    ApiConnection 
    -> TwoWayStop
    -> OrderSide
    -> Decimal 
    -> Task Http.Error JsonTranslation.PlaceOrder.Root
placeStopLossOrder apiConnection stopOrder side quantity =
    let
        limitPrice = 
            case side of
                Buy ->
                    stopOrder.limitPriceUp

                Sell ->
                    stopOrder.limitPriceDown
        params = 
            "symbol=" ++ stopOrder.symbol
            ++ "&side=" ++ sideToString side
            ++ "&type=STOP_LOSS_LIMIT"
            ++ "&quantity=" ++ (Decimal.toString quantity)
            ++ "&stopPrice=" ++ (Decimal.toString stopOrder.stopPrice)
            ++ "&price=" ++ (Decimal.toString limitPrice)
            ++ "&timeInForce=GTC"
        signedParams timestamp = signParams apiConnection.secret timestamp params
        placeStopLossOrderTask timestamp = 
            Http.task
                { method = "POST"
                , headers = 
                    [ Http.header "X-MBX-APIKEY" apiConnection.key 
                    , Http.header "Content-Type" "application/json" 
                    ]
                , url = proxy ++ baseUrl ++ "order" ++ "?" ++ signedParams timestamp
                , body = Http.emptyBody
                , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.PlaceOrder.rootDecoder
                , timeout = Nothing
                }
    in
        getTimestampTask
        |> Task.andThen placeStopLossOrderTask


stringToDecimal : String -> Decimal
stringToDecimal str =
    Decimal.fromIntString str |> Maybe.withDefault Decimal.zero



outcomes upStop downStop price =
    let
        belowUpStop = Decimal.compare price upStop == LT
        aboveDownStop = Decimal.compare price downStop == GT
    in
        case (belowUpStop, aboveDownStop) of
            (True, True) ->
                None

            (False, True) ->
                Up

            (True, False) ->
                Down

            (False, False) ->
                None


-- resetStopOrder
-- logic for this function:
-- * get the price
-- * close existing order for the symbol pair
-- * get the balances from accountInfo
-- * get the price
-- * if the price is below the upStop
--   * place the upStop order for the full cash balance from account info
-- * if the price is above the downStop
--   * place the downStop order for the full asset balance from account info
resetStopOrder : ApiConnection -> TwoWayStop -> Task Http.Error JsonTranslation.PlaceOrder.Root
resetStopOrder apiConnection twoWayStop =
    let
        quantity accountInfo =
            List.filter (\x -> x.asset == twoWayStop.symbol) accountInfo.balances
            |> List.map (\x -> stringToDecimal x.free)
            |> List.foldl Decimal.add Decimal.zero
    in
        getSymbolPrice twoWayStop.symbol
        |> Task.andThen (\symbolPrice ->
            cancelAllOpenOrders apiConnection twoWayStop.symbol
            |> Task.andThen (\_ ->
                getAccountInfo apiConnection
                |> Task.andThen (\accountInfo ->
                    let
                        price = stringToDecimal symbolPrice.price
                    in
                        if Decimal.compare price twoWayStop.stopPrice == LT then
                            placeStopLossOrder apiConnection twoWayStop Buy (quantity accountInfo)
                        else 
                            placeStopLossOrder apiConnection twoWayStop Sell (quantity accountInfo)
                )
            )
        )