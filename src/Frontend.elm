module Frontend exposing (Model, app)


import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes


import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Lamdera exposing (sendToBackend)
import Types exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (type_)
import Types exposing (FrontendMsg(..))
import Helpers exposing (..)
import Decimal exposing (Decimal)
import Http
import Time
import Element.Border exposing (widthXY)
import Browser.Dom exposing (blur)


type alias Model =
    FrontendModel


{-| Lamdera applications define 'app' instead of 'main'.

Lamdera.frontend is the same as Browser.application with the
additional update function; updateFromBackend.

-}
app =
    Lamdera.frontend
        { init = \_ _ -> init
        , update = update
        , updateFromBackend = updateFromBackend
        , view =
            \model ->
                { title = "v1"
                , body = [ view model ]
                }
        , subscriptions = \_ -> Sub.none
        , onUrlChange = \_ -> FNoop
        , onUrlRequest = \_ -> FNoop
        }


init : ( Model, Cmd FrontendMsg )
init =
    ( { counter = 0
    , clientId = ""
    , apiConnection = { key = ""
                      , secret = "" }
    , twoWayStop = twoWayStopDefault
    , serverTime = Nothing }
    , Cmd.none )


decimalFromString : String -> Decimal
decimalFromString str = Decimal.fromIntString str |> Maybe.withDefault Decimal.zero


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        CounterChange counterMsg ->
            case counterMsg of 
                Increment ->
                    ( { model | counter = model.counter + 1 }, sendToBackend CounterIncremented )

                Decrement ->
                    ( { model | counter = model.counter - 1 }, sendToBackend CounterDecremented )

        ApiConnectionChange apiMsg ->
            let 
                oldApiConnection= model.apiConnection
            in
                case apiMsg of
                    KeyChanged key ->
                        ( { model | apiConnection = { oldApiConnection | key = key } }, Cmd.none )

                    SecretChanged secret ->
                        ( { model | apiConnection = { oldApiConnection | secret = secret } }, Cmd.none )

                    ChangeApiConnection ->
                        ( model, sendToBackend (ApiConnectionChanged model.apiConnection) )

        
        TwoWayStopChange twoWayStopnMsg ->
            let
                oldTwoWayStop = model.twoWayStop
            in
                case twoWayStopnMsg of
                    SymbolChanged symbol ->      
                        ( 
                            { model 
                            | twoWayStop = { oldTwoWayStop | symbol = symbol } 
                            } , Cmd.none )

                    StopPriceChanged price ->
                        ( 
                            { model 
                            | twoWayStop = { oldTwoWayStop | stopPrice = price |> decimalFromString} 
                            } , Cmd.none )

                    LimitPriceDownChanged price ->
                        ( 
                            { model 
                            | twoWayStop = { oldTwoWayStop | limitPriceDown = price |> decimalFromString } 
                            } , Cmd.none )
                    
                    LimitPriceUpChanged price ->
                        ( 
                            { model 
                            | twoWayStop = { oldTwoWayStop | limitPriceUp = price |> decimalFromString } 
                            } , Cmd.none )

                    ChangeTwoWayStop ->
                        ( model, sendToBackend (TwoWayStopChanged model.twoWayStop) )

        FNoop ->
            ( model, Cmd.none )

        -- ChangeApiConnection apiConnection ->
        --     ( { model | apiConnection = apiConnection }, sendToBackend (ApiConnectionChanged apiConnection) )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        CounterNewValue newValue clientId ->
            ( { model | counter = newValue, clientId = clientId }, Cmd.none )

        NewApiConnection apiConnection ->
            ( { model | apiConnection = apiConnection }, Cmd.none )

        NewTwoWayStop twoWayStop ->
            ( { model | twoWayStop = twoWayStop }, Cmd.none )

        AccountInfoFailure err ->
            let
                _ = 
                    case err of 
                        Http.BadUrl url ->
                            Debug.log "BadUrl" url

                        Http.Timeout ->
                            Debug.log "Timeout" ""

                        Http.NetworkError ->
                            Debug.log "NetworkError" ""

                        Http.BadStatus response ->
                            Debug.log "BadStatus" <| String.fromInt response

                        Http.BadBody body ->
                            Debug.log "BadBody" body
            in
                ( model, Cmd.none )

        AccountInfoSuccess _ ->
            ( model, Cmd.none )

        ResetStopOrderFailure err ->
            let
                _ = 
                    case err of 
                        Http.BadUrl url ->
                            Debug.log "BadUrl" url

                        Http.Timeout ->
                            Debug.log "Timeout" ""

                        Http.NetworkError ->
                            Debug.log "NetworkError" ""

                        Http.BadStatus response ->
                            Debug.log "BadStatus" <| String.fromInt response

                        Http.BadBody body ->
                            Debug.log "BadBody" body
            in
                ( model, Cmd.none )

        ResetStopOrderSuccess _ ->
            ( model, Cmd.none )

        ServerTime posix ->
            ( {model | serverTime = Just posix }, Cmd.none )

        Nope ->
            ( model, Cmd.none )

        

view : Model -> Html FrontendMsg
view model =
    let
        input msg value placeholder label = 
            Input.text 
                [] 
                { onChange = msg
                , text = value
                , placeholder = Just (Input.placeholder [] (text placeholder)) 
                , label = Input.labelAbove [] (text label)
                }
        
        apiView = 
            column 
                [ ]     
                [ text "API Connection"
                , input KeyChanged model.apiConnection.key "Enter your API key" "Key"
                , input SecretChanged model.apiConnection.secret "Enter your API secret" "Secret"
                , Element.text model.apiConnection.key
                , Element.text model.apiConnection.secret
                , Input.button buttonStyle { onPress = Just ChangeApiConnection, label = text "Update API Connection" }
                ]

        twoWayStopView = 
            column
                [ spacing 10 ]
                [ text "Position Config"
                , input
                    SymbolChanged
                    model.twoWayStop.symbol
                    "Enter the asset pair" "" 
                , input 
                    StopPriceChanged 
                    (model.twoWayStop.stopPrice |> Decimal.toString) 
                    "Enter the trigger price" "Stop Trigger Price"
                , input 
                    LimitPriceDownChanged 
                    (model.twoWayStop.limitPriceDown |> Decimal.toString) 
                    "Enter the limit price" "Down Limit Price"
                , input
                    LimitPriceUpChanged 
                    (model.twoWayStop.limitPriceUp |> Decimal.toString) 
                    "Enter the trigger price" "Up Stop Trigger Price"
                , Input.button buttonStyle { onPress = Just ChangeTwoWayStop, label = text "Update Two Way Stop" }
                ]

        timeFromServer = 
            case model.serverTime of
                Just posix ->
                    text <| "Server time: " ++ (String.fromInt <| Time.posixToMillis posix)

                Nothing ->
                    text "Server time: Not yet received"


        buttonStyle = 
            [ padding 5
            -- , alignLeft
            , Border.width 2
            , Border.rounded 6
            , Border.color color.blue
            , Background.color color.lightBlue
            ]

        button msg label = 
            Input.button buttonStyle { onPress = Just msg, label = text label }
    in
        layout [ padding 10 ] <|
            -- center align the elements of this column
            
            column [ spacing 10, centerX, centerY ]
                [ button (CounterChange Increment) "+"
                , text (String.fromInt model.counter)
                , button (CounterChange Decrement) "-" 
                , apiView |> Element.map ApiConnectionChange
                , twoWayStopView |> Element.map TwoWayStopChange
                , timeFromServer
                ]

color =
    { blue = rgb255 0x72 0x9F 0xCF
    , darkCharcoal = rgb255 0x2E 0x34 0x36
    , lightBlue = rgb255 0xC5 0xE8 0xF7
    , lightGrey = rgb255 0xE0 0xE0 0xE0
    , white = rgb255 0xFF 0xFF 0xFF
    }