module JsonTranslation.DateRange exposing (..)

import Json.Decode
import Json.Encode


-- Required packages:
-- * elm/json


type alias Root =
    { from : String
    , to : String
    }


rootDecoder : Json.Decode.Decoder Root
rootDecoder = 
    Json.Decode.map2 Root
        (Json.Decode.field "from" Json.Decode.string)
        (Json.Decode.field "to" Json.Decode.string)


encodedRoot : Root -> Json.Encode.Value
encodedRoot root = 
    Json.Encode.object
        [ ( "from", Json.Encode.string root.from )
        , ( "to", Json.Encode.string root.to )
        ]