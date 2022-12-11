module RPC exposing (..)

import Decimal
import Http
import Iso8601
import Json.Decode as D
import Json.Decode.Pipeline exposing (required)
import Json.Encode as E
import JsonTranslation.AccountValueAtTimeJson exposing (..)
import JsonTranslation.DateRange
import Lamdera exposing (SessionId)
import Lamdera.Wire3 as Wire3
import LamderaRPC exposing (RPC(..))
import Queries exposing (getAccountValuesOverTime)
import Task exposing (Task)
import Time
import Types exposing (..)


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

        "accountValueHistory" ->
            LamderaRPC.handleEndpointJson accountValueHistory args model

        "getPnL" ->
            LamderaRPC.handleEndpointJson getPnL args model

        _ ->
            ( LamderaRPC.ResultFailure <| Http.BadBody <| "Unknown endpoint " ++ args.endpoint, model, Cmd.none )


getPnL : SessionId -> BackendModel -> E.Value -> ( Result Http.Error E.Value, BackendModel, Cmd msg )
getPnL sessionId model jsonArg =
    ( Queries.getPnL model |> E.string |> Ok, model, Cmd.none )


accountValueHistory : SessionId -> BackendModel -> E.Value -> ( Result Http.Error E.Value, BackendModel, Cmd msg )
accountValueHistory sessionId model jsonArg =
    let
        decoder =
            JsonTranslation.DateRange.rootDecoder

        encoder =
            JsonTranslation.AccountValueAtTimeJson.encodedRoot
    in
    case D.decodeValue decoder jsonArg of
        Ok dateRange ->
            let
                iso8601ToPosix err =
                    Iso8601.toTime
                        >> Result.mapError (\_ -> err)

                result =
                    Result.map2
                        (getAccountValuesOverTime model)
                        (iso8601ToPosix "Invalid fromDate" dateRange.from)
                        (iso8601ToPosix "Invalid toDate" dateRange.to)

                accountValuesToResultType valAtTime =
                    { posixTime = Time.posixToMillis valAtTime.time
                    , usdtValue = Decimal.toFloat valAtTime.value
                    }
            in
            case result of
                Ok accountValues ->
                    ( Ok <| encoder <| (accountValues |> List.map accountValuesToResultType)
                    , model
                    , Cmd.none
                    )

                Err err ->
                    ( Err <|
                        Http.BadBody <|
                            "Failed to decode arg for [json] "
                                ++ "accountValueHistory "
                                ++ err
                    , model
                    , Cmd.none
                    )

        Err err ->
            ( Err <|
                Http.BadBody <|
                    "Failed to decode arg for [json] "
                        ++ "accountValueHistory "
                        ++ D.errorToString err
            , model
            , Cmd.none
            )



-- Define the handler


exampleJson : SessionId -> BackendModel -> E.Value -> ( Result Http.Error E.Value, BackendModel, Cmd msg )
exampleJson sessionId model jsonArg =
    let
        _ =
            Debug.log "exampleJson" jsonArg

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
            ( Err <|
                Http.BadBody <|
                    "Failed to decode arg for [json] "
                        ++ "exampleJson "
                        ++ D.errorToString err
            , model
            , Cmd.none
            )
