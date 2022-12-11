module Backend exposing (app, init)

import Binance exposing (..)
import Decimal
import Env
import Html exposing (time)
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Queries
import Set exposing (Set)
import Task
import Time
import Types exposing (..)


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
      , apiConnection =
            { key = Env.apiConnectionKey
            , secret = Env.apiConnectionSecret
            }
      , twoWayStop = twoWayStopDefault
      , serverTime = Nothing
      , orderHistory = []
      , accountValueOverTime = []
      }
    , Cmd.none
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        ClientConnected sessionId clientId ->
            ( model
            , Cmd.batch
                [ sendToFrontend clientId <| CounterNewValue model.counter clientId
                , sendToFrontend clientId <| NewApiConnection model.apiConnection
                , sendToFrontend clientId <| NewTwoWayStop model.twoWayStop
                ]
            )

        GetAccountInfo ->
            ( model, getAccountInfoTask model.apiConnection |> Task.attempt GetAccountInfoResponse )

        GetAccountInfoResponse accountInfo ->
            case accountInfo of
                Ok acc ->
                    ( model, broadcast <| AccountInfoSuccess acc )

                Err error ->
                    ( model, broadcast <| AccountInfoFailure error )

        Tick posix ->
            ( model, broadcast <| ServerTime posix )

        ResetStopOrder _ ->
            ( model
            , Cmd.batch
                [ resetStopOrderTask model.apiConnection model.twoWayStop Buy |> Task.attempt ResetStopOrderResponse
                , resetStopOrderTask model.apiConnection model.twoWayStop Sell |> Task.attempt ResetStopOrderResponse
                ]
            )

        ResetStopOrderResponse stopOrder ->
            case stopOrder of
                Ok order ->
                    ( { model | orderHistory = model.orderHistory ++ [ order ] }
                    , broadcast <| ResetStopOrderSuccess order
                    )

                Err error ->
                    ( model, broadcast <| ResetStopOrderFailure error )

        CancelAllOrders _ ->
            ( model, cancelAllOpenOrdersTask model.apiConnection model.twoWayStop.symbol |> Task.attempt CancelAllOrdersResponse )

        CancelAllOrdersResponse cancelAllOrders ->
            case cancelAllOrders of
                Ok orders ->
                    ( model, broadcast <| Nope )

                Err error ->
                    ( model, broadcast <| Nope )

        CalculateAccountValue time ->
            ( model, calculateAccountValueTask model.apiConnection |> Task.attempt (CalculateAccountValueResponse time) )

        CalculateAccountValueResponse time accountValue ->
            case accountValue of
                Ok value ->
                    let
                        currentValue =
                            { time = time, value = value }

                        _ =
                            Debug.log "Current value" (currentValue.value |> Decimal.toString)

                        _ =
                            Debug.log "Diff" (Queries.assetValueChange model |> Decimal.toString)
                    in
                    ( { model | accountValueOverTime = model.accountValueOverTime ++ [ currentValue ] }
                    , broadcast <| Nope
                    )

                Err error ->
                    ( model, broadcast <| Nope )

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
                , getAccountInfoTask apiConnection |> Task.attempt GetAccountInfoResponse
                ]
            )

        TwoWayStopChanged twoWayStop ->
            ( { model | twoWayStop = twoWayStop }
            , Cmd.batch
                [ broadcast (NewTwoWayStop twoWayStop)
                , cancelAllOpenOrdersTask model.apiConnection twoWayStop.symbol |> Task.attempt CancelAllOrdersResponse
                ]
            )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Time.every 20000 Tick
        , Time.every 20000 ResetStopOrder

        -- , Time.every 30000 CancelAllOrders
        , Time.every 10000 CalculateAccountValue
        ]
