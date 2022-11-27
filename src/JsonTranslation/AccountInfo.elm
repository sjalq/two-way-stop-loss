module JsonTranslation.AccountInfo exposing (..)

import Json.Decode
import Json.Encode


-- Required packages:
-- * elm/json


type alias Root =
    { accountType : String
    , balances : List RootBalancesObject
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


type alias RootBalancesObject =
    { asset : String
    , free : String
    , locked : String
    }


rootDecoder : Json.Decode.Decoder Root
rootDecoder = 
    let
        fieldSet0 = 
            Json.Decode.map8 Root
                (Json.Decode.field "accountType" Json.Decode.string)
                (Json.Decode.field "balances" <| Json.Decode.list rootBalancesObjectDecoder)
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


rootBalancesObjectDecoder : Json.Decode.Decoder RootBalancesObject
rootBalancesObjectDecoder = 
    Json.Decode.map3 RootBalancesObject
        (Json.Decode.field "asset" Json.Decode.string)
        (Json.Decode.field "free" Json.Decode.string)
        (Json.Decode.field "locked" Json.Decode.string)


encodedRoot : Root -> Json.Encode.Value
encodedRoot root = 
    Json.Encode.object
        [ ( "accountType", Json.Encode.string root.accountType )
        , ( "balances", Json.Encode.list encodedRootBalancesObject root.balances )
        , ( "brokered", Json.Encode.bool root.brokered )
        , ( "buyerCommission", Json.Encode.int root.buyerCommission )
        , ( "canDeposit", Json.Encode.bool root.canDeposit )
        , ( "canTrade", Json.Encode.bool root.canTrade )
        , ( "canWithdraw", Json.Encode.bool root.canWithdraw )
        , ( "makerCommission", Json.Encode.int root.makerCommission )
        , ( "permissions", Json.Encode.list Json.Encode.string root.permissions )
        , ( "sellerCommission", Json.Encode.int root.sellerCommission )
        , ( "takerCommission", Json.Encode.int root.takerCommission )
        , ( "updateTime", Json.Encode.int root.updateTime )
        ]


encodedRootBalancesObject : RootBalancesObject -> Json.Encode.Value
encodedRootBalancesObject rootBalancesObject = 
    Json.Encode.object
        [ ( "asset", Json.Encode.string rootBalancesObject.asset )
        , ( "free", Json.Encode.string rootBalancesObject.free )
        , ( "locked", Json.Encode.string rootBalancesObject.locked )
        ]