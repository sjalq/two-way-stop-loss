module BinanceDecoder exposing (..)

import Json.Decode
import Json.Encode


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
    , free : String
    , locked : String
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