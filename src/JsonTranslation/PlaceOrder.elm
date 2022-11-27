module JsonTranslation.PlaceOrder exposing (..)


import Json.Decode
import Json.Encode


-- Required packages:
-- * elm/json


type alias Root =
    { clientOrderId : String
    , orderId : Int
    , orderListId : Int
    , symbol : String
    , transactTime : Int
    }


rootDecoder : Json.Decode.Decoder Root
rootDecoder = 
    Json.Decode.map5 Root
        (Json.Decode.field "clientOrderId" Json.Decode.string)
        (Json.Decode.field "orderId" Json.Decode.int)
        (Json.Decode.field "orderListId" Json.Decode.int)
        (Json.Decode.field "symbol" Json.Decode.string)
        (Json.Decode.field "transactTime" Json.Decode.int)


encodedRoot : Root -> Json.Encode.Value
encodedRoot root = 
    Json.Encode.object
        [ ( "clientOrderId", Json.Encode.string root.clientOrderId )
        , ( "orderId", Json.Encode.int root.orderId )
        , ( "orderListId", Json.Encode.int root.orderListId )
        , ( "symbol", Json.Encode.string root.symbol )
        , ( "transactTime", Json.Encode.int root.transactTime )
        ]