module BinanceDecoders.BinanceDecoder exposing (..)

import Json.Decode
import Json.Encode
import Decimal exposing (Decimal)

-- Required packages:
-- * elm/json


type alias AccountInfo =
    { accountType : String
    , balances : List BalanceObject
    , brokered : Bool
    , buyerCommission : Int
    , canDeposit : Bool
    , canTrade : Bool
    , canWithdraw : Bool
    , makerCommission : Int
    , permissions : List String
    , sellerCommission : Int
    , takerCommission : Int
    , updateTime : Int
    }


type alias BalanceObject =
    { asset : String
    , free : Decimal
    , locked : Decimal
    }


type alias SymbolPrice =
    { price : Decimal
    , symbol : String
    }

type alias Order =
    { clientOrderId : String
    , cummulativeQuoteQty : Decimal
    , executedQty : Decimal
    , icebergQty : Decimal
    , isWorking : Bool
    , orderId : Int
    , orderListId : Int
    , origQty : Decimal
    , origQuoteOrderQty : Decimal
    , price : Decimal
    , side : OrderSide
    , status : String
    , stopPrice : Decimal
    , symbol : String
    , time : Int
    , timeInForce : String
    , type_ : String
    , updateTime : Int
    }


accountInfoDecoder : Json.Decode.Decoder AccountInfo
accountInfoDecoder = 
    let
        fieldSet0 = 
            Json.Decode.map8 AccountInfo
                (Json.Decode.field "accountType" Json.Decode.string)
                (Json.Decode.field "balances" <| Json.Decode.list accountInfoBalancesObjectDecoder)
                (Json.Decode.field "brokered" Json.Decode.bool)
                (Json.Decode.field "buyerCommission" Json.Decode.int)
                (Json.Decode.field "canDeposit" Json.Decode.bool)
                (Json.Decode.field "canTrade" Json.Decode.bool)
                (Json.Decode.field "canWithdraw" Json.Decode.bool)
                (Json.Decode.field "makerCommission" Json.Decode.int)
    in
    Json.Decode.map5 (<|)
        fieldSet0
        (Json.Decode.field "permissions" <| Json.Decode.list Json.Decode.string)
        (Json.Decode.field "sellerCommission" Json.Decode.int)
        (Json.Decode.field "takerCommission" Json.Decode.int)
        (Json.Decode.field "updateTime" Json.Decode.int)


accountInfoBalancesObjectDecoder : Json.Decode.Decoder BalanceObject
accountInfoBalancesObjectDecoder = 
    Json.Decode.map3 BalanceObject
        (Json.Decode.field "asset" Json.Decode.string)
        (Json.Decode.field "free" Json.Decode.string)
        (Json.Decode.field "locked" Json.Decode.string)


encodedAccountInfo : AccountInfo -> Json.Encode.Value
encodedAccountInfo accountInfo = 
    Json.Encode.object
        [ ( "accountType", Json.Encode.string accountInfo.accountType )
        , ( "balances", Json.Encode.list encodedAccountInfoBalancesObject accountInfo.balances )
        , ( "brokered", Json.Encode.bool accountInfo.brokered )
        , ( "buyerCommission", Json.Encode.int accountInfo.buyerCommission )
        , ( "canDeposit", Json.Encode.bool accountInfo.canDeposit )
        , ( "canTrade", Json.Encode.bool accountInfo.canTrade )
        , ( "canWithdraw", Json.Encode.bool accountInfo.canWithdraw )
        , ( "makerCommission", Json.Encode.int accountInfo.makerCommission )
        , ( "permissions", Json.Encode.list Json.Encode.string accountInfo.permissions )
        , ( "sellerCommission", Json.Encode.int accountInfo.sellerCommission )
        , ( "takerCommission", Json.Encode.int accountInfo.takerCommission )
        , ( "updateTime", Json.Encode.int accountInfo.updateTime )
        ]


encodedAccountInfoBalancesObject : BalanceObject -> Json.Encode.Value
encodedAccountInfoBalancesObject accountInfoBalancesObject = 
    Json.Encode.object
        [ ( "asset", Json.Encode.string accountInfoBalancesObject.asset )
        , ( "free", Json.Encode.string accountInfoBalancesObject.free )
        , ( "locked", Json.Encode.string accountInfoBalancesObject.locked )
        ]

type alias Timestamp =
    { serverTime : Int
    }


timestampDecoder : Json.Decode.Decoder Timestamp
timestampDecoder = 
    Json.Decode.map Timestamp
        (Json.Decode.field "serverTime" Json.Decode.int)


encodedTimestamp : Timestamp -> Json.Encode.Value
encodedTimestamp timestamp = 
    Json.Encode.object
        [ ( "serverTime", Json.Encode.int timestamp.serverTime )
        ]


symbolPriceDecoder : Json.Decode.Decoder SymbolPrice
symbolPriceDecoder = 
    Json.Decode.map2 SymbolPrice
        (Json.Decode.field "price" Json.Decode.string)
        (Json.Decode.field "symbol" Json.Decode.string)


encodedSymbolPrice : SymbolPrice -> Json.Encode.Value
encodedSymbolPrice symbolPrice = 
    Json.Encode.object
        [ ( "price", Json.Encode.string symbolPrice.price )
        , ( "symbol", Json.Encode.string symbolPrice.symbol )
        ]


orderListDecoder : Json.Decode.Decoder (List Order)
orderListDecoder = 
    Json.Decode.list orderDecoder


orderDecoder : Json.Decode.Decoder Order
orderDecoder = 
    let
        fieldSet0 = 
            Json.Decode.map8 Order
                (Json.Decode.field "clientOrderId" Json.Decode.string)
                (Json.Decode.field "cummulativeQuoteQty" Json.Decode.string)
                (Json.Decode.field "executedQty" Json.Decode.string)
                (Json.Decode.field "icebergQty" Json.Decode.string)
                (Json.Decode.field "isWorking" Json.Decode.bool)
                (Json.Decode.field "orderId" Json.Decode.int)
                (Json.Decode.field "orderListId" Json.Decode.int)
                (Json.Decode.field "origQty" Json.Decode.string)

        fieldSet1 =
            Json.Decode.map8 (<|)
                fieldSet0
                (Json.Decode.field "origQuoteOrderQty" Json.Decode.string)
                (Json.Decode.field "price" Json.Decode.string)
                (Json.Decode.field "side" Json.Decode.string)
                (Json.Decode.field "status" Json.Decode.string)
                (Json.Decode.field "stopPrice" Json.Decode.string)
                (Json.Decode.field "symbol" Json.Decode.string)
                (Json.Decode.field "time" Json.Decode.int)
    in
    Json.Decode.map4 (<|)
        fieldSet1
        (Json.Decode.field "timeInForce" Json.Decode.string)
        (Json.Decode.field "type" Json.Decode.string)
        (Json.Decode.field "updateTime" Json.Decode.int)


encodedOrderList : List Order -> Json.Encode.Value
encodedOrderList orderList =
    Json.Encode.list encodedOrder orderList


encodedOrder : Order -> Json.Encode.Value
encodedOrder order = 
    Json.Encode.object
        [ ( "clientOrderId", Json.Encode.string order.clientOrderId )
        , ( "cummulativeQuoteQty", Json.Encode.string order.cummulativeQuoteQty )
        , ( "executedQty", Json.Encode.string order.executedQty )
        , ( "icebergQty", Json.Encode.string order.icebergQty )
        , ( "isWorking", Json.Encode.bool order.isWorking )
        , ( "orderId", Json.Encode.int order.orderId )
        , ( "orderListId", Json.Encode.int order.orderListId )
        , ( "origQty", Json.Encode.string order.origQty )
        , ( "origQuoteOrderQty", Json.Encode.string order.origQuoteOrderQty )
        , ( "price", Json.Encode.string order.price )
        , ( "side", Json.Encode.string order.side )
        , ( "status", Json.Encode.string order.status )
        , ( "stopPrice", Json.Encode.string order.stopPrice )
        , ( "symbol", Json.Encode.string order.symbol )
        , ( "time", Json.Encode.int order.time )
        , ( "timeInForce", Json.Encode.string order.timeInForce )
        , ( "type", Json.Encode.string order.type_ )
        , ( "updateTime", Json.Encode.int order.updateTime )
        ]