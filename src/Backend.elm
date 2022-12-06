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
      , orderHistory = []
      , accountValueOverTime = []
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
            ( model, getAccountInfoTask model.apiConnection |> Task.attempt GetAccountInfoResponse)

        GetAccountInfoResponse accountInfo ->
            case accountInfo of
                Ok acc ->
                    ( model, broadcast <| AccountInfoSuccess acc )

                Err error ->
                    ( model, broadcast <| AccountInfoFailure error )

        Tick posix ->
            ( model, broadcast <| ServerTime posix )

        ResetStopOrder _ ->
            ( model,
                Cmd.batch 
                [ (resetStopOrderTask model.apiConnection model.twoWayStop Buy) |> Task.attempt ResetStopOrderResponse 
                , (resetStopOrderTask model.apiConnection model.twoWayStop Sell) |> Task.attempt ResetStopOrderResponse 
                ]
            )

        ResetStopOrderResponse stopOrder ->
            case stopOrder of
                Ok order ->
                    let 
                        allOrders = Debug.log "All orders" (model.orderHistory ++ [ order ])
                    in 
                        ( { model | orderHistory = allOrders }
                        , broadcast <| ResetStopOrderSuccess order )

                Err error ->
                    let 
                        allOrders = Debug.log "All orders" (model.orderHistory)
                    in 
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
                    ( { model | accountValueOverTime = model.accountValueOverTime ++ [{ time = time, value = value }] }
                    , broadcast <| Nope )

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
                ] )

        TwoWayStopChanged twoWayStop ->
            ( { model | twoWayStop = twoWayStop }
            , Cmd.batch 
                [ broadcast (NewTwoWayStop twoWayStop) 
                , cancelAllOpenOrdersTask model.apiConnection twoWayStop.symbol |> Task.attempt CancelAllOrdersResponse ]
            )


subscriptions model =
    Sub.batch
        [ Lamdera.onConnect ClientConnected
        , Time.every 20000 Tick
        , Time.every 20000 ResetStopOrder
        -- , Time.every 30000 CancelAllOrders
        , Time.every 60000 CalculateAccountValue
        ]
