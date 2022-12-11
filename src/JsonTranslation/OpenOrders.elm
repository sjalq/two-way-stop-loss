module JsonTranslation.OpenOrders exposing (..)

import Json.Decode
import Json.Encode



-- Required packages:
-- * elm/json


type alias RootObject =
    { clientOrderId : String
    , cummulativeQuoteQty : String
    , executedQty : String
    , icebergQty : String
    , isWorking : Bool
    , orderId : Int
    , orderListId : Int
    , origQty : String
    , origQuoteOrderQty : String
    , price : String
    , side : String
    , status : String
    , stopPrice : String
    , symbol : String
    , time : Int
    , timeInForce : String
    , type_ : String
    , updateTime : Int
    }


rootDecoder : Json.Decode.Decoder (List RootObject)
rootDecoder =
    Json.Decode.list rootObjectDecoder


rootObjectDecoder : Json.Decode.Decoder RootObject
rootObjectDecoder =
    let
        fieldSet0 =
            Json.Decode.map8 RootObject
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


encodedRoot : List RootObject -> Json.Encode.Value
encodedRoot root =
    Json.Encode.list encodedRootObject root


encodedRootObject : RootObject -> Json.Encode.Value
encodedRootObject rootObject =
    Json.Encode.object
        [ ( "clientOrderId", Json.Encode.string rootObject.clientOrderId )
        , ( "cummulativeQuoteQty", Json.Encode.string rootObject.cummulativeQuoteQty )
        , ( "executedQty", Json.Encode.string rootObject.executedQty )
        , ( "icebergQty", Json.Encode.string rootObject.icebergQty )
        , ( "isWorking", Json.Encode.bool rootObject.isWorking )
        , ( "orderId", Json.Encode.int rootObject.orderId )
        , ( "orderListId", Json.Encode.int rootObject.orderListId )
        , ( "origQty", Json.Encode.string rootObject.origQty )
        , ( "origQuoteOrderQty", Json.Encode.string rootObject.origQuoteOrderQty )
        , ( "price", Json.Encode.string rootObject.price )
        , ( "side", Json.Encode.string rootObject.side )
        , ( "status", Json.Encode.string rootObject.status )
        , ( "stopPrice", Json.Encode.string rootObject.stopPrice )
        , ( "symbol", Json.Encode.string rootObject.symbol )
        , ( "time", Json.Encode.int rootObject.time )
        , ( "timeInForce", Json.Encode.string rootObject.timeInForce )
        , ( "type", Json.Encode.string rootObject.type_ )
        , ( "updateTime", Json.Encode.int rootObject.updateTime )
        ]
