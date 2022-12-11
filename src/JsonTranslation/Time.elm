module JsonTranslation.Time exposing (..)

import Json.Decode
import Json.Encode



-- Required packages:
-- * elm/json


type alias Root =
    { serverTime : Int
    }


rootDecoder : Json.Decode.Decoder Root
rootDecoder =
    Json.Decode.map Root
        (Json.Decode.field "serverTime" Json.Decode.int)


encodedRoot : Root -> Json.Encode.Value
encodedRoot root =
    Json.Encode.object
        [ ( "serverTime", Json.Encode.int root.serverTime )
        ]
