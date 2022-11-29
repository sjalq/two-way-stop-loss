module Backend exposing (app, init)

import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Set exposing (Set)
import Types exposing (..)
import Binance exposing (..)
import Html exposing (time)
import PrivateConfig
import Task
import Time


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { counter = 0 
      , apiConnection = PrivateConfig.apiConnection
      , twoWayStop = twoWayStopDefault
      , serverTime = Nothing
      }
    , Cmd.none )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            ( model
            , Cmd.batch 
                [ sendToFrontend clientId <| CounterNewValue model.counter clientId
                , sendToFrontend clientId <| NewApiConnection model.apiConnection
                , sendToFrontend clientId <| NewTwoWayStop model.twoWayStop
                ] )

        GetAccountInfo ->
            ( model, getAccountInfo model.apiConnection |> Task.attempt GetAccountInfoResponse)

        GetAccountInfoResponse accountInfo ->
            case accountInfo of
                Ok acc ->
                    ( model, broadcast <| AccountInfoSuccess acc )

                Err error ->
                    ( model, broadcast <| AccountInfoFailure error )

        Tick posix ->
            ( model, broadcast <| ServerTime posix )

        ResetStopOrder _ ->
            ( model, (resetStopOrder model.apiConnection model.twoWayStop) |> Task.attempt ResetStopOrderResponse )

        ResetStopOrderResponse stopOrder ->
            case stopOrder of
                Ok order ->
                    ( model, broadcast <| ResetStopOrderSuccess order )

                Err error ->
                    ( model, broadcast <| ResetStopOrderFailure error ) 

        Noop ->
            ( model, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        CounterIncremented ->
            let
                newCounter =
                    model.counter + 1
            in
            ( { model | counter = newCounter }, broadcast (CounterNewValue newCounter clientId) )

        CounterDecremented ->
            let
                newCounter =
                    model.counter - 1
            in
            ( { model | counter = newCounter }, broadcast (CounterNewValue newCounter clientId) )

        ApiConnectionChanged apiConnection ->
            ( { model | apiConnection = apiConnection }
            , Cmd.batch 
                [ broadcast (NewApiConnection apiConnection)
                , getAccountInfo apiConnection |> Task.attempt GetAccountInfoResponse
                ] )

        TwoWayStopChanged twoWayStop ->
            ( { model | twoWayStop = twoWayStop }
            , broadcast (NewTwoWayStop twoWayStop) 
            )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Time.every 20000 Tick
        , Time.every 10000 ResetStopOrder
        ]
