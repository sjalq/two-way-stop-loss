module JsonTranslation.AccountValueAtTimeJson exposing (..)

import Json.Decode
import Json.Encode


-- Required packages:
-- * elm/json


type alias RootObject =
    { posixTime : Int
    , usdtValue : Float
    }


rootDecoder : Json.Decode.Decoder (List RootObject)
rootDecoder = 
    Json.Decode.list rootObjectDecoder


rootObjectDecoder : Json.Decode.Decoder RootObject
rootObjectDecoder = 
    Json.Decode.map2 RootObject
        (Json.Decode.field "posixTime" Json.Decode.int)
        (Json.Decode.field "usdtValue" Json.Decode.float)


encodedRoot : List RootObject -> Json.Encode.Value
encodedRoot root =
    Json.Encode.list encodedRootObject root


encodedRootObject : RootObject -> Json.Encode.Value
encodedRootObject rootObject = 
    Json.Encode.object
        [ ( "posixTime", Json.Encode.int rootObject.posixTime )
        , ( "usdtValue", Json.Encode.float rootObject.usdtValue )
        ]