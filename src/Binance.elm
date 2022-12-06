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
import JsonTranslation.SymbolPrices exposing (..)
import JsonTranslation.DeleteOpenOrders exposing (..)
import JsonTranslation.OpenOrders exposing (..)
import JsonTranslation.PlaceOrder exposing (..)
import List.Extra exposing (..)
import Element exposing (Device)

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


getAccountInfoTask : ApiConnection -> Task Http.Error JsonTranslation.AccountInfo.Root
getAccountInfoTask apiConnection =
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

getSymbolPriceTask : String -> Task Http.Error JsonTranslation.SymbolPrices.RootObject
getSymbolPriceTask symbol =
    Http.task
        { method = "GET"
        , headers = []
        , url = proxy ++ baseUrl ++ "ticker/price?symbol=" ++ symbol
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.SymbolPrices.rootObjectDecoder
        , timeout = Nothing
        }

cancelAllOpenOrdersTask : ApiConnection -> String -> Task Http.Error (List JsonTranslation.DeleteOpenOrders.Root)
cancelAllOpenOrdersTask apiConnection symbol =
    let
        signedParams timestamp = signParams apiConnection.secret timestamp ("symbol=" ++ symbol)
        cancelAllOpenOrdersTask_ timestamp = 
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
        |> Task.andThen cancelAllOpenOrdersTask_

getOpenOrdersTask : ApiConnection -> String -> Task Http.Error (List JsonTranslation.OpenOrders.RootObject)
getOpenOrdersTask apiConnection symbol =
    let
        signedParams timestamp = signParams apiConnection.secret timestamp ("symbol=" ++ symbol)
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

placeStopLossOrderTask : 
    ApiConnection 
    -> TwoWayStop
    -> OrderSide
    -> Decimal 
    -> Task Http.Error JsonTranslation.PlaceOrder.Root
placeStopLossOrderTask apiConnection stopOrder side quantity =
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
            ++ "&quantity=" ++ (quantity |> Decimal.truncate -4 |> Decimal.toString)
            ++ "&stopPrice=" ++ (stopOrder.stopPrice |> Decimal.truncate -4 |> Decimal.toString)
            ++ "&price=" ++ (Decimal.toString limitPrice)
            ++ "&timeInForce=GTC"
        signedParams timestamp = signParams apiConnection.secret timestamp params
        placeStopLossOrderTask_ timestamp = 
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
        |> Task.andThen placeStopLossOrderTask_

placeMarketOrderTask : 
    ApiConnection 
    -> TwoWayStop
    -> OrderSide
    -> Decimal 
    -> Decimal
    -> Task Http.Error JsonTranslation.PlaceOrder.Root
placeMarketOrderTask apiConnection stopOrder side quantity quoteOrderQty =
    let
        _ = Debug.log "-----------------------------quoteOrderQty" (quoteOrderQty |> Decimal.toString)
        _ = Debug.log "-----------------------------quantity" (quantity |> Decimal.toString)
        _ = Debug.log "-----------------------------side" side
        quoteOrQuantityParam = 
            case side of
                Buy ->
                    "&quoteOrderQty=" ++ (quoteOrderQty |> Decimal.truncate -4 |> Decimal.toString)

                Sell ->
                    "&quantity=" ++ (quantity |> Decimal.truncate -4 |> Decimal.toString)
        params = 
            "symbol=" ++ stopOrder.symbol
            ++ "&side=" ++ sideToString side
            ++ "&type=MARKET"
            ++ quoteOrQuantityParam
        signedParams timestamp = signParams apiConnection.secret timestamp params
        placeLimitOrderTask timestamp = 
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
        |> Task.andThen placeLimitOrderTask

placeBestOrderTask : 
    ApiConnection 
    -> TwoWayStop
    -> OrderSide
    -> Decimal 
    -> Decimal
    -> Decimal
    -> Task Http.Error JsonTranslation.PlaceOrder.Root
placeBestOrderTask apiConnection stopOrder side quantity quoteOrderQty currentPrice =
    let 
        priceCmprStopPrice = Decimal.compare currentPrice stopOrder.stopPrice 
    in
        case (priceCmprStopPrice, side) of
            (GT, Buy) ->
                placeMarketOrderTask apiConnection stopOrder side quantity quoteOrderQty

            (LT, Sell) ->
                placeMarketOrderTask apiConnection stopOrder side quantity quoteOrderQty

            (_, _) ->
                placeStopLossOrderTask apiConnection stopOrder side quantity


stringToDecimal : String -> Decimal
stringToDecimal str =
    Decimal.fromIntString str |> Maybe.withDefault Decimal.zero

isSymbolAsset : String -> String -> Bool
isSymbolAsset symbol asset =
    String.startsWith asset symbol

isDenominatingAsset : String -> String -> Bool
isDenominatingAsset symbol asset =
    String.endsWith asset symbol


resetStopOrderTask : ApiConnection -> TwoWayStop -> OrderSide -> Task Http.Error JsonTranslation.PlaceOrder.Root
resetStopOrderTask apiConnection twoWayStop orderSide =
    let
        sumFreeBalances filter accountInfo=
            accountInfo.balances
            |> List.filter (\balance -> filter balance.asset)
            |> List.map (\balance -> stringToDecimal balance.free)
            |> List.foldl Decimal.add Decimal.zero

        assetQuantityToSell =
            sumFreeBalances (isSymbolAsset twoWayStop.symbol)

        assetQuantityToBuy price accountInfo =  
            price
            |> Decimal.fastdiv (sumFreeBalances (isDenominatingAsset twoWayStop.symbol) accountInfo)
            |> Maybe.withDefault Decimal.zero
    in
        getAccountInfoTask apiConnection
        |> Task.andThen (\accountInfo ->
            case orderSide of 
                Buy ->
                    placeStopLossOrderTask apiConnection twoWayStop orderSide (assetQuantityToBuy twoWayStop.limitPriceUp accountInfo)
                Sell ->
                    placeStopLossOrderTask apiConnection twoWayStop orderSide (assetQuantityToSell accountInfo)
        )


fetchUsdtSymbolPricesTask : List String -> Task Http.Error (List JsonTranslation.SymbolPrices.RootObject)
fetchUsdtSymbolPricesTask symbols =
    let
        symbolsString = 
            "[" ++
            (symbols
            |> List.filter (\symbol -> ["USDT", "BUSD"] |> List.member symbol |> not)
            |> List.map (\symbol -> "\"" ++ symbol ++ "USDT\"")
            |> String.join ",")
            ++ "]"

        _ = Debug.log "symbolsString" (symbolsString |> String.replace "\\" "")

        params = "symbols=" ++ symbolsString

    in
        Http.task
            { method = "GET"
            , headers = 
                [ Http.header "Content-Type" "application/json" 
                ]
            , url = proxy ++ baseUrl ++ "ticker/price" ++ "?" ++ params
            , body = Http.emptyBody
            , resolver = Http.stringResolver <| handleJsonResponse <| JsonTranslation.SymbolPrices.rootDecoder
            , timeout = Nothing
            }

calculateAccountValueTask : ApiConnection -> Task Http.Error Decimal
calculateAccountValueTask apiConnection =
    let
        assetTotal balance price =
            stringToDecimal balance.free
            |> Decimal.add (stringToDecimal balance.locked)
            |> Decimal.mul (stringToDecimal price)

        totalValue : JsonTranslation.AccountInfo.Root -> List JsonTranslation.SymbolPrices.RootObject -> Decimal
        totalValue accountInfo symbolPrices = 
            List.Extra.joinOn 
                (\balance symbolPrice -> { key = symbolPrice.symbol, value = assetTotal balance symbolPrice.price } )
                (\balance -> balance.asset ++ "USDT")
                (\symbolPrice -> symbolPrice.symbol)
                accountInfo.balances
                symbolPrices
            |> List.map (\{ key, value } -> value)
            |> List.foldl Decimal.add Decimal.zero
            |> Decimal.add (usdtValue accountInfo)

        usdtValue accountInfo =
            accountInfo.balances
            |> List.filter (\balance -> ["USDT", "BUSD"] |> List.member balance.asset)
            |> List.map (\balance -> assetTotal balance "1")
            |> List.foldl Decimal.add Decimal.zero
    in
        getAccountInfoTask apiConnection
        |> Task.andThen (\accountInfo ->
            accountInfo.balances 
            |> List.map (\balance -> balance.asset) 
            |> fetchUsdtSymbolPricesTask
            |> Task.andThen (\symbolPrices ->
                let
                    _ = Debug.log "accountInfo" accountInfo
                    _ = Debug.log "symbolPrices" symbolPrices
                in
                    totalValue accountInfo symbolPrices
                    |> Task.succeed
            )
        )



