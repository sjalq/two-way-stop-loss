module RPC exposing (..)

import Http
import Lamdera exposing (SessionId)
import Lamdera.Wire3 as Wire3
import LamderaRPC exposing (RPC(..))
import Task exposing (Task)
import Types exposing (..)
import Json.Decode as D
import Json.Encode as E
import Json.Decode.Pipeline exposing (required)
import JsonTranslation.AccountValueAtTimeJson exposing (..)
import JsonTranslation.DateRange
import JsonTranslation.AccountValueAtTimeJson
import Queries exposing (getAccountValuesOverTime)
import Iso8601
import Time
import Decimal

reverse : SessionId -> BackendModel -> String -> ( RPC String, BackendModel, Cmd msg )
reverse sessionId model input =
    ( Response <| String.reverse input, model, Cmd.none )


-- Things that should be auto-generated in future


requestReverse : String -> Task Http.Error String
requestReverse value =
    LamderaRPC.asTask Wire3.encodeString Wire3.decodeString value "reverse"


lamdera_handleEndpoints : LamderaRPC.RPCArgs -> BackendModel -> ( LamderaRPC.RPCResult, BackendModel, Cmd msg )
lamdera_handleEndpoints args model =
    case args.endpoint of
        -- "reverse" ->
        --     LamderaRPC.handleEndpoint reverse Wire3.decodeString Wire3.encodeString args model

        "exampleJson" ->
            LamderaRPC.handleEndpointJson exampleJson args model

        "myCrayCrayQuery" ->
            LamderaRPC.handleEndpointJson myCrayCrayQuery args model

        _ ->
            ( LamderaRPC.ResultFailure <| Http.BadBody <| "Unknown endpoint " ++ args.endpoint, model, Cmd.none )


myCrayCrayQuery : SessionId -> BackendModel -> E.Value -> (Result Http.Error E.Value, BackendModel, Cmd msg)
myCrayCrayQuery sessionId model jsonArg =
    let
        decoder = JsonTranslation.DateRange.rootDecoder
        encoder = JsonTranslation.AccountValueAtTimeJson.encodedRoot
    in
    case D.decodeValue decoder jsonArg of
        Ok dateRange ->
            let
                fromTime = 
                    dateRange.from 
                    |> Iso8601.toTime 
                    |> Result.mapError (\_ -> "Invalid fromDate")
                
                toTime = 
                    dateRange.to
                    |> Iso8601.toTime 
                    |> Result.mapError (\_ -> "Invalid toDate")

                result =
                    Result.map2 
                        (getAccountValuesOverTime model)
                        fromTime
                        toTime

                accountValuesToResultType valAtTime =
                   { posixTime = Time.posixToMillis valAtTime.time, usdtValue = Decimal.toFloat valAtTime.value }

            in
            case result of
                Ok accountValues ->
                    ( Ok <| encoder <| (accountValues |> List.map accountValuesToResultType)
                    , model
                    , Cmd.none
                    )

                Err err ->
                    ( Err <| Http.BadBody <|
                        "Failed to decode arg for [json] "
                            ++ "myCrayCrayQuery "
                            ++ err
                    , model
                    , Cmd.none)
        
        Err err ->
            ( Err <| Http.BadBody <|
                "Failed to decode arg for [json] "
                    ++ "myCrayCrayQuery "
                    ++ D.errorToString err
            , model
            , Cmd.none)
    

-- Define the handler
exampleJson : SessionId -> BackendModel -> E.Value -> ( Result Http.Error E.Value, BackendModel, Cmd msg )
exampleJson sessionId model jsonArg =
    let
        decoder =
            D.succeed identity
                |> required "name" D.string

        encoder =
            E.string
    in
    case D.decodeValue decoder jsonArg of
        Ok name ->
            ( Ok <| encoder <| String.reverse name
            , model
            , Cmd.none
            )


        Err err ->
            ( Err <| Http.BadBody <|
                "Failed to decode arg for [json] "
                    ++ "exampleJson "
                    ++ D.errorToString err
            , model
            , Cmd.none
            )