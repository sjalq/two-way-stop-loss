module JsonTranslation.SymbolPrices exposing (..)

import Json.Decode
import Json.Encode


-- Required packages:
-- * elm/json


type alias RootObject =
    { price : String
    , symbol : String
    }


rootDecoder : Json.Decode.Decoder (List RootObject)
rootDecoder = 
    Json.Decode.list rootObjectDecoder


rootObjectDecoder : Json.Decode.Decoder RootObject
rootObjectDecoder = 
    Json.Decode.map2 RootObject
        (Json.Decode.field "price" Json.Decode.string)
        (Json.Decode.field "symbol" Json.Decode.string)


encodedRoot : List RootObject -> Json.Encode.Value
encodedRoot root =
    Json.Encode.list encodedRootObject root


encodedRootObject : RootObject -> Json.Encode.Value
encodedRootObject rootObject = 
    Json.Encode.object
        [ ( "price", Json.Encode.string rootObject.price )
        , ( "symbol", Json.Encode.string rootObject.symbol )
        ]