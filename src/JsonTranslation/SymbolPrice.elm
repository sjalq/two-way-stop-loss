module JsonTranslation.SymbolPrice exposing (..)

import Json.Decode
import Json.Encode


-- Required packages:
-- * elm/json


type alias Root =
    { price : String
    , symbol : String
    }


rootDecoder : Json.Decode.Decoder Root
rootDecoder = 
    Json.Decode.map2 Root
        (Json.Decode.field "price" Json.Decode.string)
        (Json.Decode.field "symbol" Json.Decode.string)


encodedRoot : Root -> Json.Encode.Value
encodedRoot root = 
    Json.Encode.object
        [ ( "price", Json.Encode.string root.price )
        , ( "symbol", Json.Encode.string root.symbol )
        ]